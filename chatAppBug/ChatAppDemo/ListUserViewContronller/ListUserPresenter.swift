//
//  ListUserPresenter.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/7/22.
//

import Firebase

protocol ListUserPresenterDelegate: NSObject {
    func showSearchUser()
    func showStateMassage()
    func deleteUser(at index: Int)
    func didFetchUser()
    func didFetchMessageForUser()
    func didGetImageForCurrentUser(_ image: UIImage)
}

class ListUserPresenter {
    //MARK: -Properties
    private weak var view: ListUserPresenterDelegate?
    private var db = Firestore.firestore()
    private var reciverUser = [User]()
    private var finalUser = [User]()
    private var activeUsers = [User]()
    private var currentUser: User?
    private var currenUsers = [User]()
    private var message = [Message]()
    private var allMessages = [String: Message]()
    private var messageByUser = [String: Message]()
    
    //MARK: - Init
    init(with view: ListUserPresenterDelegate, data: User) {
        self.view = view
        self.currentUser = data
        self.activeUsers.insert(data, at: 0)
    }
    
    
    //MARK: - FetchUser
    func fetchUser() {
        guard let currentID = currentUser?.id else { return }
        db.collection("user").addSnapshotListener {[weak self] (querySnapshot, error) in
            if error != nil {return}
            guard let snapshot = querySnapshot else { return }
            self?.reciverUser.removeAll()
            self?.activeUsers.removeAll()
            snapshot.documents.forEach { doc in
                let value = User(dict: doc.data())
                if value.id != currentID {
                    self?.reciverUser.append(value)
                    self?.finalUser = self?.reciverUser ?? []
                }
                if value.id != currentID && value.isActive == true {
                    self?.activeUsers.append(value)
                }
//                if value.id == currentID {
//                    self?.activeUsers.insert(value, at: 0)
//                }
                
            }
            self?.view?.didFetchUser()
            self?.fetchMessageForUser()
        }
    }
    
    //MARK: - FetchMessage
    func fetchMessageForUser() {
        self.message.removeAll()
        guard let currentUser = currentUser else {return}
        reciverUser.forEach { user in
            FirebaseService.share.fetchMessage(user, senderUser: currentUser) {[weak self] message in
                message.forEach { mess in
                    if mess.receiverID == user.id || mess.receiverID == currentUser.id {
                        self?.allMessages[user.id] = mess
                        self?.message = Array((self?.allMessages.values)!)
                        self?.message = self?.message.sorted {
                            return $0.time > $1.time
                        } ?? []
                    }
                }
                self?.view?.didFetchMessageForUser()
            }
        }
    }
    
    //MARK: - ChangeState Active User
    func setState(_ sender: User, reciverUser: User) {
        FirebaseService.share.changeStateReadMessage(sender, revicerUser: reciverUser)
        self.view?.showStateMassage()
    }
    
    //MARK: Search User
    func searchUser(_ text: String) {
        let lowcaseText = text.lowercased()
        if text.isEmpty {
            self.finalUser = self.reciverUser
        } else {
            self.finalUser = self.reciverUser.filter{$0.name
                    .folding(options: .diacriticInsensitive, locale: nil)
                    .lowercased()
                    .contains(lowcaseText)
            }
        }
        view?.showSearchUser()
    }
    //MARK: -Getter,Setter
    
    func getUsers(_ index: Int) -> User? {
        return reciverUser[index]
    }

    func getNumberOfActiveUser() -> Int {
        return activeUsers.count
    }
    
    func getIndexOfActiveUser(_ index: Int) -> User? {
        return activeUsers[index]
    }
    
    
    func getcurrentUser() -> User?{
        return currentUser
    }
    
    
    func getNumberOfMessage() -> Int {
        
        return message.count
    }
    
    func cellForMessage(_ index: Int) -> Message? {
        if index <= 0 && index > getNumberOfMessage() {
            return nil
        }
        return message[index]
    }
    
    func getAllMessage(_ id: String) -> Message? {
        return allMessages[id]
    }
    
    func getNumberOfUser() -> Int {
        return finalUser.count
    }
    
    func getCellForUsers(at index: Int) -> User? {
        if index < 0 && index > getNumberOfUser() {
            return nil
        }
        return finalUser[index]
    }
    
    func getImageForCurrentUser() {
        guard let currentuser = getcurrentUser() else { return }
        ImageService.share.fetchImage(with: currentuser.picture) {[weak self]  image in
            self?.view?.didGetImageForCurrentUser(image)
        }
    }
    
    func deleteUser(_ index: Int, completion:() -> Void) {
        self.finalUser.remove(at: index)
        completion()
    }
//    func getNumberOfItemForCurrentUser() -> Int {
//        return currenUsers.count
//    }
//    func getIndexForCurrentUser(_ index: Int) -> User? {
//        return currenUsers[index]
//    }
    
    
}
