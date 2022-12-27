//
//  DetailViewViewController.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/7/22.
//

import UIKit

class DetailViewViewController: UIViewController {
    static func instance(_ data: User, currentUser: User) -> DetailViewViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailScreen") as! DetailViewViewController
        vc.presenter = DetailPresenter(with: vc, data: data, currentUser: currentUser)
        return vc
    }
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var tfMessage: UITextField!
    @IBOutlet private weak var btSendMessage: UIButton!
    @IBOutlet private weak var convertiontable: UITableView!
    @IBOutlet private weak var goBack: UIButton!
    @IBOutlet private weak var imgUser: UIImageView!
    @IBOutlet private weak var lbState: UILabel!
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var imgStateUser: CustomImage!
    
    @IBOutlet private weak var bottomTfMessageContrains: NSLayoutConstraint!
    
    private var imgPicker = UIImagePickerController()
    private var presenter: DetailPresenter!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.fetchMessage()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.convertiontable.endEditing(true)
        view.endEditing(true)
    }
   
    private func setupUI() {
        setupMessageTextField()
        setupImage()
        setupBtSend()
        setupConvertionTable()
        setupGoBackButton()
        showStateReciverUser()
        keyBoardObserver()
       
    }
    
     private func keyBoardObserver() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showStateReciverUser() {
        presenter.fetchStateUser {[weak self] user, image  in
            guard let image = image else {return}
            self?.imgStateUser.tintColor = .systemGray
            guard let user = user else {return}
            user.forEach { user in
                self?.lbNameUser.text = user.name
                DispatchQueue.main.async {
                    self?.imgUser.image = image
                }
                self?.lbState.text = user.isActive ? "Active Now" : "Not active"
                self?.imgStateUser.tintColor = user.isActive ? .green : .systemGray
            }
        }
    }
   
    private func setupGoBackButton() {
        goBack.setTitle("", for: .normal)
        goBack.addTarget(self, action: #selector(didTapBackListScreen(_:)), for: .touchUpInside)
    }
    
    private func setupConvertionTable() {
        convertiontable.delegate = self
        convertiontable.dataSource = self
        convertiontable.separatorStyle = .none
        convertiontable.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        let imgCell = UINib(nibName: "ImgCell", bundle: nil)
        convertiontable.register(imgCell, forCellReuseIdentifier: "imgCell")
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleViewEndEditing(_:)))
        convertiontable.addGestureRecognizer(gesture)
        
        
        let messageCell = UINib(nibName: "MessageCell", bundle: nil)
        convertiontable.register(messageCell, forCellReuseIdentifier: "messageCell")
        
        let reciverUser = UINib(nibName: "ReciverUserCell", bundle: nil)
        convertiontable.register(reciverUser, forCellReuseIdentifier: "reciverUser")
    }
    
    private func setupMessageTextField() {
        tfMessage.attributedPlaceholder = NSAttributedString(string: "Aa", attributes: [.foregroundColor:UIColor.white])
        tfMessage.layer.cornerRadius = 6
        tfMessage.delegate = self
        tfMessage.layer.masksToBounds = true
        tfMessage.addTarget(self, action: #selector(handleChangeButton(_:)), for: .editingChanged)
    }
    
    private func setupImage() {
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage(_:))))
        image.isUserInteractionEnabled = true
    }
    
    private func setupBtSend() {
        btSendMessage.setTitle(" ", for: .normal)
        btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        btSendMessage.addTarget(self, action: #selector(didTapSend(_:)), for: .touchUpInside)
    }
    
    private func sendMessage() {
        guard let message = tfMessage.text else {return}
        if message.isEmpty {
            presenter.sendLikeSymbols()
            view.endEditing(true)
            return
        }
        presenter.sendMessage(with: message)
        tfMessage.text = ""
        btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        view.endEditing(true)
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            if self.presenter.getNumberOfMessage() < 1 { return }
            let indexPath = IndexPath(row: self.presenter.getNumberOfMessage() - 1, section: 0)
            self.convertiontable.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //MARK: -Acction
    
    @objc private func handleChangeButton(_ textField: UITextField) {
        if textField === tfMessage {
            guard let message = tfMessage.text else {return}
            if message.isEmpty {
                btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                return
            }
            
            btSendMessage.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        }
        
        
    }
    
    @objc private func didTapSend(_ sender: UIButton) {
        self.sendMessage()
    }
    
    @objc private func chooseImage(_ tapGes: UITapGestureRecognizer) {
        self.imgPicker.delegate = self
        self.imgPicker.sourceType = .photoLibrary
        present(self.imgPicker, animated: true)
    }
    
    @objc private func didTapBackListScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleViewEndEditing(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}
//MARK: -Extension UIImagePickerControllerDelegate
extension DetailViewViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let image = image else { return }
        
        self.presenter.sendImageMessage(with: image)
        
        self.imgPicker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imgPicker.dismiss(animated: true)
    }
    
}


//MARK: -Extension UitableView
extension DetailViewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfMessage()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentUser = presenter.getCurrentUser()
        let message = presenter.getCellForMessage(at: indexPath.row)
        
        if message.text.isEmpty {
            let cell = convertiontable.dequeueReusableCell(withIdentifier: "imgCell", for: indexPath) as! ImgCell
            let message = presenter.getCellForMessage(at: indexPath.row)
            cell.updateUI(message, currentUser: currentUser)
            return cell
        }
        
        if message.sendId == currentUser?.id {
            let cell = convertiontable.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
            cell.updateUI(message)
            return cell
        } else {
            let cell = convertiontable.dequeueReusableCell(withIdentifier: "reciverUser") as! ReciverUserCell
            cell.updateUI(message)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = presenter.getCellForMessage(at: indexPath.row)
        if message.text.isEmpty {
            return 280 / (message.ratioImage)
        } else {
            return UITableView.automaticDimension
        }
    }
    
}

//MARK: Extension UItextFiled
extension DetailViewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessage()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
    }
}

extension DetailViewViewController: DetailPresenterViewDelegate {
    func showMessage() {
        self.convertiontable.reloadData()
        self.scrollToBottom()
    }
}

extension DetailViewViewController {
    @objc func keyboardWillShow(_ sender: NSNotification) {
        let keyboardframe = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
        self.bottomTfMessageContrains.constant = keyboardframe + 10
        self.scrollToBottom()
        self.view.layoutIfNeeded()
    }
    
    
    @objc func keyboardWillHide(_ sender: NSNotification) {
        self.bottomTfMessageContrains.constant = 30
        self.scrollToBottom()
        self.view.layoutIfNeeded()
    }
}

