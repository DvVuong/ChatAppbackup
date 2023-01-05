//
//  ListUserPresenter.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/7/22.
//

import Firebase
import RxSwift
import RxCocoa

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
    private var finalUser = PublishSubject<[User]>()
    
    var allOtherUser = PublishSubject<[User]>()
    var activeUsers = BehaviorSubject(value: [User]())
    let currentUser: User?
    
    private var currenUsers = [User]()
    private var message = [Message]()
    let messageBehaviorSubject = BehaviorSubject(value: [Message]())
    private var allMessages = [String: Message]()
    private var messageByUser = [String: Message]()
    
    
    let searchUserPublisher = PublishSubject<String>()
    
    let observable = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    

    //MARK: - Init
    init(with view: ListUserPresenterDelegate, data: User) {
        self.view = view
        self.currentUser = data
        
        self.allOtherUser.subscribe { user in
            print("vuongdv", user)
            self.finalUser.onNext(user)
        }.disposed(by: self.disposeBag)
        
        searchUserPublisher.subscribe { text in
            
            if let text = text.element {
                let lowcaseText = text.lowercased()

                if text.isEmpty {
                    self.allOtherUser.subscribe { user in
                        print("vuongdv", user)
                        self.finalUser.onNext(user)
                    }.disposed(by: self.disposeBag)
                }else {
                    self.allOtherUser.subscribe { users in
                        print("vuongdv", users)
                        if let user = users.element {
                            let searchUser = user.filter{$0.name
                                                .folding(options: .diacriticInsensitive, locale: nil)
                                                .lowercased()
                                                .contains(lowcaseText)
                            }
                            self.finalUser.onNext(searchUser)
                            print("vuongdv", self.finalUser)
                        }
                    }.disposed(by: self.disposeBag)
                }
                
            }
            
            
        }.disposed(by: disposeBag)
       
        
    }
    
    
    //MARK: - FetchUser
    
    func fetchUserRxSwift()  {
         self.db.collection("user").addSnapshotListener({[weak self] querySnapshot, error in
            if error != nil {return}
            if let currentId = self?.currentUser?.id {
                guard let document = querySnapshot?.documents else {return}
                let user = document.map({User(dict: $0.data())}).filter({$0.id != currentId})
                let activeUser = document.map({User(dict: $0.data())}).filter({$0.id != currentId}).filter({$0.isActive == true})
                self?.allOtherUser.onNext(user)
                self?.finalUser = self!.allOtherUser
                self?.activeUsers.onNext(activeUser)
            }
        })
        }
    
    //MARK: - FetchMessage
    
    func fectchMessageRxSwift() {
        guard let currentUser = currentUser else {return}
        allOtherUser.subscribe {[weak self] users in
            guard let users = users.element else {return}
            for user in users {
                self?.db.collection("message")
                    .document(currentUser.id)
                    .collection(user.id)
                    .addSnapshotListener {[weak self] querySnapshot, error in
                        if error != nil { return }
                        guard let snapshot = querySnapshot?.documents else {return}
                        let message = snapshot.map({Message(dict: $0.data())}).filter({$0.receiverID == currentUser.id || $0.receiverID == user.id})
                        let messages = message.sorted {
                            return $0.time > $1.time
                        }
                        self?.messageBehaviorSubject.onNext(messages)
                }
            }
        }.disposed(by: disposeBag)
    }
    
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
//    func searchUser(_ text: String) {
//        let lowcaseText = text.lowercased()
//        if text.isEmpty {
//            self.finalUser = self.reciverUser
//        } else {
//            self.finalUser = self.reciverUser.filter{$0.name
//                    .folding(options: .diacriticInsensitive, locale: nil)
//                    .lowercased()
//                    .contains(lowcaseText)
//            }
//        }
//        view?.showSearchUser()
   // }
    //MARK: -Getter,Setter
    
    func getUsers(_ index: Int) -> User? {
        return reciverUser[index]
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
    
//    func getNumberOfUser() -> Int {
//        return finalUser.count
//    }
//
//    func getCellForUsers(at index: Int) -> User? {
//        if index < 0 && index > getNumberOfUser() {
//            return nil
//        }
//        return finalUser[index]
//    }
    
    func getImageForCurrentUser() {
        guard let currentuser = getcurrentUser() else { return }
        ImageService.share.fetchImage(with: currentuser.picture) {[weak self]  image in
            self?.view?.didGetImageForCurrentUser(image)
        }
    }
    
//    func deleteUser(_ index: Int, completion:() -> Void) {
//        self.finalUser.remove(at: index)
//        completion()
//    }
        
}
