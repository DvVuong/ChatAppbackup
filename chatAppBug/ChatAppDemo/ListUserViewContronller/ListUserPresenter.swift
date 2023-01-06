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

    func didGetImageForCurrentUser(_ image: UIImage)
}

class ListUserPresenter {
    //MARK: -Properties
    private weak var view: ListUserPresenterDelegate?
    private var db = Firestore.firestore()
    
    //MARK: User Properties
    var reciverUser = BehaviorSubject(value: [User]())
    var finalUser = PublishSubject<[User]>()
    var allOtherUser = PublishSubject<[User]>()
    var activeUsers = PublishSubject<[User]>()
    let currentUser: User?
    let messReciverUer = PublishSubject<User>()
    
   //MARK: Message Properties
    var message = [Message]()
    let messageBehaviorSubject = BehaviorRelay(value: [Message]())
    private var allMessages = [String: Message]()
       
    
    let searchUserPublisher = PublishSubject<String>()
    let observable = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    

    //MARK: - Init
    init(with view: ListUserPresenterDelegate, data: User) {
        self.view = view
        self.currentUser = data
        
        
        //MARK: Search User

        self.allOtherUser.subscribe { user in
            self.finalUser.onNext(user)
        }.disposed(by: self.disposeBag)
        
        searchUserPublisher.subscribe { text in
            if let text = text.element {
                let lowcaseText = text.lowercased()
                if text.isEmpty {
                    self.allOtherUser.subscribe { user in
                        self.finalUser.onNext(user)
                    }.disposed(by: self.disposeBag)
                }else {
                    self.allOtherUser.subscribe { users in
                        if let user = users.element {
                            let searchUser = user.filter{$0.name
                                                .folding(options: .diacriticInsensitive, locale: nil)
                                                .lowercased()
                                                .contains(lowcaseText)
                            }
                            self.finalUser.onNext(searchUser)
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
                self?.activeUsers.onNext(activeUser)
                self?.reciverUser.onNext(user)
            }
        })
        }
    
    //MARK: - FetchMessage
    
    func fectchMessageRxSwift() {
        guard let currentUser = currentUser else {return}
        allMessages.removeAll()
        message.removeAll()
        allOtherUser.subscribe {[weak self] users in
            guard let users = users.element else {return}
            for user in users {
                self?.db.collection("message")
                    .document(currentUser.id)
                    .collection(user.id)
                    .addSnapshotListener {[weak self] querySnapshot, error in
                        if error != nil { return }
                        guard let snapshot = querySnapshot?.documentChanges else {return}
                        for doc in snapshot {
                            if doc.type == .added || doc.type == .removed {
                                let value = Message(dict: doc.document.data())
                                if value.receiverID == currentUser.id || value.receiverID == user.id {
                                    self?.allMessages[user.id] = value
                                    self?.message = Array((self?.allMessages.values)!)
                                    self?.message = self?.message.sorted {
                                        return $0.time > $1.time
                                    } ?? []
                                }
                            }
                        }
                        self?.messageBehaviorSubject.accept(self?.message ?? [])
                    }
            }
        }.disposed(by: disposeBag)
    }
    
    //MARK: - ChangeState Active User
    func setState(_ sender: User, reciverUser: User) {
        FirebaseService.share.changeStateReadMessage(sender, revicerUser: reciverUser)
       
    }
    
    //MARK: -Getter,Setter
    
    func getcurrentUser() -> User?{
        return currentUser
    }
    
    func getImageForCurrentUser() {
        guard let currentuser = getcurrentUser() else { return }
        ImageService.share.fetchImage(with: currentuser.picture) {[weak self]  image in
            self?.view?.didGetImageForCurrentUser(image)
        }
    }
}
