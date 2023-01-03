//
//  SignInPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import Firebase
import FBSDKLoginKit
import RxSwift
import RxCocoa
import Foundation

protocol SignInPresenterDelegate: NSObject {
    func showUserRegiter(_ email: String, password: String)
    func didLoginZalo(_ user: User?)
    func didLoginFacebook(_ user: User?)
    func didLoginGoogle(_ user: User?)
    func didValidateSocialMediaAccount(_ user: User?, bool: Bool)
}

class SignInPresenter {
    //MARK: -Properties
    private weak var view: SignInPresenterDelegate?
    private var users = [User]()
    private var currentUser: User?
    private let db = Firestore.firestore()
    let nameTextPublisherSubjetc = PublishSubject<String>()
    let passwordTextPublisherSubjetc = PublishSubject<String>()
    private var disponeBag = DisposeBag()
    
    //MARK: -Init
    init(with view: SignInPresenterDelegate) {
        self.view = view
        
        nameTextPublisherSubjetc.subscribe { name in
            print("vuongdv",name)
        }.disposed(by: disponeBag)
    }

    //MARK: -Fetch User
    func fetchUser() {
        self.users.removeAll()
        FirebaseService.share.fetchUser { user in
            self.users.append(contentsOf: user)
        }
    }
    
    //MARK: Resgiter
    func registerSocialMediaAccount(_ result: [String: Any]) {
        let email = result["email"] as? String ?? ""
        let name = result["name"] as? String ?? ""
        let id = result["id"] as? String ?? ""
        let pictureData: [String: Any] = result["picture"] as? [String: Any] ?? [:]
        let pictureUrl: [String: Any] = pictureData["data"] as? [String: Any] ?? [:]
        let url = pictureUrl["url"] as? String ?? ""
    
        FirebaseService.share.registerSocialMedia(name, email: email, id: id, picture: url)
    }
    
    
    //MARK: -Login
    func loginZalo(_ vc: SiginViewController) {
        ZaloService.shared.login(vc) {[weak self] email, name, id, url in
            let user = User(name: name, id: id, picture: url, email: email, password: "", isActive: false)
            FirebaseService.share.registerSocialMedia(name, email: email, id: id, picture: url)
            self?.changeStateUser(user)
            self?.view?.didLoginZalo(user)
        }
    }
    
    func loginWithGoogle(_ vc: SiginViewController) {
        GoogleService.shared.login(vc) {[weak self] user in
            FirebaseService.share.registerSocialMedia(user.name, email: user.email, id: user.id, picture: user.picture)
            self?.changeStateUser(user)
            self?.view?.didLoginGoogle(user)
        }
    }
    
    func loginWithFacebook(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        FaceBookService.shared.login(loginButton, didCompleteWith: result, error: error) {[weak self] result, user in
            self?.registerSocialMediaAccount(result)
            self?.changeStateUser(user)
            self?.view?.didLoginFacebook(user)
        }
    }
    
    //MARK: -Validate
    func validateSocialMediaAccount(_ email: String) {
        var currentUser: User?
        var isvalid: Bool = false
        users.forEach { user in
            if user.email == email {
                currentUser = user
                isvalid = true
            }
        }
        view?.didValidateSocialMediaAccount(currentUser, bool: isvalid)
    }
    
    func validateEmailPassword(_ email: String, _ password: String, completion: (_ currentUser: User?, Bool) -> Void) {
        var currentUser: User?
        var isvalid: Bool = false
        users.forEach { user in
            if user.email == email && user.password == password {
                currentUser = user
                isvalid = true
            }
        }
        completion(currentUser, isvalid)
    }
    
    //MARK: Change State User
    func changeStateUser(_ currentUser: User) {
        FirebaseService.share.changeStateActiveForUser(currentUser)
    }
    
    
    func getUserData() -> [User] {
        return users
    }
    
    func showUserInfo() -> (email: String, password: String )  {
        var email: String = ""
        var password: String = ""
//        let info = DataManager.shareInstance.getUser()
//        _ = info.map { item in
//            email = item.email
//            password = item.password
//        }
        return (email, password)
    }
    
    func showUserResgiter(_ email: String, password: String) {
        view?.showUserRegiter(email, password: password)
    }
}
