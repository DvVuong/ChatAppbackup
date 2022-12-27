//
//  SignUpViewcontroller.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit

protocol RegisterViewcontrollerDelegate {
    func callBackAccountResgiter(_ vc: RegisterViewcontroller, email: String, password: String)
}

class RegisterViewcontroller: UIViewController {
    static func instance(_ data: [User]) -> RegisterViewcontroller {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpScreen") as! RegisterViewcontroller
        vc.presenter = ResgiterPresenterView(view: vc, user: data)
        return vc
    }
    
    @IBOutlet private weak var tfEmail: CustomTextField!
    @IBOutlet private weak var tfPassword: CustomTextField!
    @IBOutlet private weak var tfConfirmPassword: CustomTextField!
    @IBOutlet private weak var imgAvtar: CustomImage!
    @IBOutlet private weak var btSignUp: UIButton!
    @IBOutlet private weak var tfName: CustomTextField!
    @IBOutlet private weak var lbErrorEmail: UILabel!
    @IBOutlet private weak var lbPasswordError: UILabel!
    @IBOutlet private weak var lbConfirmPasswordError: UILabel!
    @IBOutlet private weak var lbNameError: UILabel!
    
    var delegate: RegisterViewcontrollerDelegate?
    private var imgPicker = UIImagePickerController()
    lazy private var presenter = ResgiterPresenterView(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    //MARK: Methods
    private func setupUI() {
        setupImgAvatar()
        setupBtSigup()
        setupTextFile()
        setupLable()
    }
    
    private func setupLable() {
        lbNameError.isHidden = true
        lbErrorEmail.isHidden = true
        lbPasswordError.isHidden = true
        lbConfirmPasswordError.isHidden = true
        btSignUp.isEnabled = false
    }
    
    private func setupImgAvatar() {
        imgAvtar.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handelImage(_:)))
        imgAvtar.addGestureRecognizer(tapGes)
    }
    
    private func setupBtSigup() {
        btSignUp.layer.cornerRadius = 6
        btSignUp.layer.masksToBounds = true
        btSignUp.addTarget(self, action: #selector(didTapSignUp(_:)), for: .touchUpInside)
    }
    
   private func showAlertSuccess(_ title: String)  {
        let aler = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Xác nhận", style: .default) { action in
            self.delegate?.callBackAccountResgiter(self, email: self.tfEmail.text!, password: self.tfPassword.text!)
        }
        aler.addAction(action)
        present(aler, animated: true)
    }

    private func setupTextFile() {
        tfName.addTarget(self, action: #selector(handleTextFiledChanges(_:)), for: .editingChanged)
        tfEmail.addTarget(self, action: #selector(handleTextFiledChanges(_:)), for: .editingChanged)
        tfPassword.addTarget(self, action: #selector(handleTextFiledChanges(_:)), for: .editingChanged)
        tfConfirmPassword.addTarget(self, action: #selector(handleTextFiledChanges(_:)), for: .editingChanged)
    }
    
    //MARK: Acction
    @objc private func handleTextFiledChanges(_ textField: CustomTextField) {
        if textField === tfName {
            presenter.vaidateName(textField.text!)
        }else if textField === tfEmail {
            presenter.validateEmail(textField.text!)
        } else if textField === tfPassword {
            presenter.validatePassword(textField.text!)
        } else if textField === tfConfirmPassword {
            presenter.validateConfirmPassword(textField.text!, password: tfPassword.text!)
        }
    }
    
    @objc private func didTapSignUp(_ sender: UIButton) {
        showAlertSuccess("Resigter Success")
        self.presenter.createAccount(email: self.tfEmail.text!, password: self.tfPassword.text!, name: self.tfName.text!)
    }
    
    @objc private func handelImage(_ tapges: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image From", message: nil, preferredStyle: .actionSheet)
        
        let chooseImageFromLibrabriAction = UIAlertAction(title: "From Librabri", style: .default){ action in
            self.imgPicker.delegate = self
            self.imgPicker.sourceType = .photoLibrary
            self.present(self.imgPicker, animated: true)
        }
        let chooseImageFromCamera = UIAlertAction(title: "From Camera", style: .default) { action in
            self.imgPicker.delegate = self
            self.imgPicker.sourceType = .camera
            self.present(self.imgPicker, animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(chooseImageFromLibrabriAction)
        alert.addAction(chooseImageFromCamera)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    
    @IBAction private func didTapbackLogin(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension RegisterViewcontroller: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imgAvtar.image = img
        guard let img = img else { return }
        presenter.getUrlAvatar(img)
        self.imgPicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imgPicker.dismiss(animated: true)
    }
}

extension RegisterViewcontroller: ResgiterPresenterDelegate {
    func isEnabledButton(_ result: Bool) {
        btSignUp.isEnabled = result
    }

    func validateName(_ result: String?) {
        if let result = result {
            lbNameError.text = result
            lbNameError.isHidden = false
            
        } else {
            lbNameError.text = ""
            presenter.setNameError(lbNameError.text!)
        }
    }
    
    func validatePassword(_ result: String?) {
        if let result = result {
            lbPasswordError.text = result
            lbPasswordError.isHidden = false
            
        } else {
            lbPasswordError.text = ""
            presenter.setPasswordError(lbPasswordError.text!)
        }
    }
    
    func validateConfirmPassword(_ result: String?) {
        if let result = result {
            lbConfirmPasswordError.text = result
            lbConfirmPasswordError.isHidden = false
            
        } else {
            lbConfirmPasswordError.text = ""
            presenter.setConfirmPassword(lbConfirmPasswordError.text!)
        }
    }
    
    func validateEmail(_ result: String?) {
        if let result = result {
            lbErrorEmail.text = result
            lbErrorEmail.isHidden = false
            
        } else {
            lbErrorEmail.text = ""
            presenter.setEmaiError(lbNameError.text!) 
        }
    }
}


