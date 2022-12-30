//
//  ResgiterPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 12/12/2022.
//

import Firebase

protocol ResgiterPresenterDelegate: NSObject {
    func validateName(_ result: String?)
    func validateEmail(_ result: String?)
    func validatePassword(_ result: String?)
    func validateConfirmPassword(_ result: String?)
    func isEnabledButton(_ result: Bool)
}
class ResgiterPresenterView {
    private weak var view: ResgiterPresenterDelegate?
    private var imgUrl: String = ""
    private var db = Firestore.firestore()
    private var user = [User]()
    private var nameError: String?
    private var emailError: String?
    private var passwordError: String?
    private var confirmPasswordError: String?
    private let _user = "user"
    
    
    init(with view: ResgiterPresenterDelegate) {
        self.view = view
    }
    convenience init(view: ResgiterPresenterDelegate, user: [User]) {
        self.init(with: view)
        self.user = user
    }
     
    func getUrlAvatar(_ image: UIImage) {
        FirebaseService.share.fetchAvatarUrl(image)
    }
    
    func createAccount( email: String,  password: String, name: String) {
        FirebaseService.share.createAccount(email: email, password: password, name: name)
    }
    
    func vaidateName(_ name: String) {
        if name.isEmpty {
            self.view?.validateName(State.emptyName.rawValue)
            return
        }
        
        self.view?.validateName(nil)
        enableButtonResgiter()
    }
    
    func validateEmail(_ email: String)  {
        if email.isEmpty {
         self.view?.validateEmail(State.emptyName.rawValue)
            return
        }
        
        if !isValidEmail(email: email) {
            self.view?.validateEmail(State.emailInvalidate.rawValue)
            return
        }
        
        self.view?.validateEmail(nil)
        enableButtonResgiter()
    }
    func validatePassword(_ password: String) {
        if password.isEmpty {
            self.view?.validatePassword(State.emptPassword.rawValue)
            return
        }
        
        if password.count < 8 {
            self.view?.validatePassword(State.weakPassword.rawValue)
            return
        }
        
        self.view?.validatePassword(nil)
        enableButtonResgiter()
        
    }
    
    func validateConfirmPassword(_ confirmPassword: String, password: String) {
        if confirmPassword != password {
            self.view?.validateConfirmPassword(State.passwordNotincorrect.rawValue)
            return
        }
        
        self.view?.validateConfirmPassword(nil)
        enableButtonResgiter()
    }
    
    func enableButtonResgiter() {
        if nameError == "" && emailError == "" && passwordError == "" && confirmPasswordError == "" {
            self.view?.isEnabledButton(true)
            return
        }
        
        self.view?.isEnabledButton(false)
        
    }
    
   private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func avatarUrl() -> String {
        return imgUrl
    }
    
    func setNameError(_ name: String?) {
        guard let name = name else { return }
        nameError = name
    }
    
    func setEmaiError(_ email: String?) {
        guard let email = email else { return }
        emailError = email
    }
    
    func setPasswordError(_ password: String?) {
        guard let password = password else { return }
        passwordError = password
    }
    
    func setConfirmPassword(_ confirmPassword: String?) {
        guard let confirmPassword = confirmPassword else { return }
        confirmPasswordError = confirmPassword
    }
    
}
