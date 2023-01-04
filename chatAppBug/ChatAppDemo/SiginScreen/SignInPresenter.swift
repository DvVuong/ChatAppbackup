//
//  SignInPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import Firebase
import FBSDKLoginKit
import RxCocoa
import RxSwift

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
    var currentUser: User?
    private let db = Firestore.firestore()
    let emailtextPublisherSubjetc = PublishSubject<String>()
    let passwordPublisherSubject = PublishSubject<String>()
    
    
    let emailError = BehaviorSubject<String?>(value: "")
    let passwordError = BehaviorSubject<String?>(value: "")
    private let disponeBag = DisposeBag()
    
    //MARK: -Init
    init(with view: SignInPresenterDelegate) {
        self.view = view
        
        emailtextPublisherSubjetc.map{self.validateEmail($0)}.subscribe {[weak self] valiPair in
            if let validate = valiPair.element {
                self?.emailError.onNext(validate.1)
            }
            
        }.disposed(by: disponeBag)
        
        passwordPublisherSubject.map {self.validatePassword($0)}.subscribe {[weak self] valiPair in
            if let validate = valiPair.element {
                self?.passwordError.onNext(validate.1)
            }
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
    
    func validateEmail(_ email: String) -> (Bool, String?) {
        if users.contains(where: {$0.email == email}) {
            users.forEach { user in
                if user.email == email {
                    self.currentUser = user
                }
            }
            return (true, nil)
        } else {
            return (false, "Wrong Email")
        }
    }
    
    func validatePassword(_ password: String) -> (Bool, String?) {
        if users.contains(where: {$0.password == password}) {
            return (true, nil)
        }else  {
            return (false, "Wrong Password" )
        }
    }
    
    
    //MARK: Change State User
    func changeStateUser(_ currentUser: User) {
        FirebaseService.share.changeStateActiveForUser(currentUser)
    }
    
    
    func getUserData() -> [User] {
        return users
    }
    
    func showUserInfo() -> (email: String, password: String )  {
        let email: String = ""
        let password: String = ""
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
