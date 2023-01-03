//
//  ListUserViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit

final class ListUserViewController: UIViewController {
    static func instance(_ currentUser: User) -> ListUserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listUserScreen") as! ListUserViewController
        vc.presenter = ListUserPresenter(with: vc, data: currentUser)
        return vc
    }
    
    private var presenter: ListUserPresenter!
    lazy private var presenterCell = ListCellPresenter()
    
    @IBOutlet private weak var messageTable: UITableView!
    @IBOutlet private weak var searchUser: UITextField!
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var btSetting: UIButton!
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var imgState: UIImageView!
    @IBOutlet private weak var listUserActive: UICollectionView!
    @IBOutlet private weak var lbNewMessageNotification: UILabel!
    @IBOutlet private weak var listAllUser: UITableView!
    @IBOutlet private weak var viewUser: UIView!
    @IBOutlet private weak var btCancelSearchUser: UIButton!
    @IBOutlet private weak var listAllUserTopContrain: NSLayoutConstraint!
    @IBOutlet private weak var heightSearchUserContrains: NSLayoutConstraint!
    @IBOutlet private weak var trailingSearchUserContrains: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        setupMessagetable()
        setupSearchUser()
        setupImageForCurrentUser()
        setupBtSetting()
        setupLbNameUser()
        setuplbNewMessageNotification()
        setupListUserCollectionTable()
        setupListUserTableView()
        setupBtCacncelSearchUser()
    }
    
    private func setupListUserTableView() {
        listAllUser.isHidden = true
        listAllUser.delegate = self
        listAllUser.dataSource = self
    }
    
    private func setupData() {
        presenter.fetchUser()
        presenter.getImageForCurrentUser()
    }
    
    private func setupBtCacncelSearchUser() {
        btCancelSearchUser.isHidden = true
        btCancelSearchUser.addTarget(self, action: #selector(didtapCancel(_:)), for: .touchUpInside)
    }
    
    private func setupMessagetable() {
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.separatorStyle = .none
    }
    
    private func setupListUserCollectionTable() {
        listUserActive.delegate = self
        listUserActive.dataSource = self
        
    }
    
    private func setupSearchUser() {
        searchUser.layer.cornerRadius = 5
        searchUser.layer.masksToBounds = true
        searchUser.layer.borderWidth = 1
        searchUser.layer.borderColor = UIColor.black.cgColor
        searchUser.delegate = self
        searchUser.addTarget(self, action: #selector(handelTextField(_:)), for: .editingChanged)
        
    }
    
    private func setupImageForCurrentUser() {
        avatar.layer.cornerRadius = avatar.frame.height / 2
        avatar.layer.masksToBounds = true
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor.black.cgColor
        avatar.contentMode = .scaleToFill
    }
    
    private func setupLbNameUser() {
        guard let currentuser = presenter.getcurrentUser() else { return }
        lbNameUser.text = currentuser.name
    }
    
    private func setuplbNewMessageNotification() {
        lbNewMessageNotification.isHidden = true
    }
    
    private func setupBtSetting() {
        btSetting.setTitle("", for: .normal)
        btSetting.addTarget(self, action: #selector(didTapSetting(_:)), for: .touchUpInside)
    }
    //MARK: -ACtion
   
    @objc private func handelTextField(_ textfield: UITextField)  {
        presenter.searchUser(textfield.text!)
    }
    
    @objc private func didTapSetting(_ sender: Any) {
       guard let user = presenter.getcurrentUser() else {return}
        let vc = SettingViewController.instance(user)
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func didtapCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.listAllUser.isHidden = true
            self.listUserActive.isHidden = false
            self.messageTable.isHidden = false
            self.viewUser.isHidden = false
            self.listAllUserTopContrain.constant = 640
            self.trailingSearchUserContrains.constant = 20
            self.heightSearchUserContrains.constant = 65
            self.btCancelSearchUser.isHidden = false
        }
        view.endEditing(true)
        
    }
    
}
// MARK: TableView
extension ListUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === messageTable {
            // show Label Message Notification
            if presenter.getNumberOfMessage() == 0 {
                lbNewMessageNotification.isHidden = false
            } else {
                lbNewMessageNotification.isHidden = true
            }
            return presenter.getNumberOfMessage()
        }
        
        else{
            return presenter.getNumberOfUser()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === messageTable {
            let cell  = messageTable.dequeueReusableCell(withIdentifier: "messageforUserCell", for: indexPath) as! MessageForUserCell
            let currentUser = presenter.getcurrentUser()
            let reciverUser = presenter.getUsers(indexPath.row)
            let message = presenter.cellForMessage(indexPath.item)
            cell.updateUI(currentUser, message: message, reciverUser: reciverUser )
            return cell
        }
        
        else if tableView === listAllUser {
            let cell = listAllUser.dequeueReusableCell(withIdentifier: "listUsertableCell", for: indexPath) as! ListAllUserTableCell
            cell.updateUI(presenter.getCellForUsers(at: indexPath.row))
            
            return cell
        }
       return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == messageTable {
            return 100
        } else {
            return 100
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView === messageTable {
            guard let currentUser = presenter.getcurrentUser() else { return }
            guard let reciverUser = presenter.getUsers(indexPath.row) else { return }
            guard let message = presenter.cellForMessage(indexPath.row) else {return}
            
            if message.sendId == currentUser.id || message.receiverID == reciverUser.id {
                let user = User(name: message.receivername, id: message.receiverID, picture: message.avatarReciverUser, email: "", password: "", isActive: false)
                let vc = DetailViewViewController.instance(user, currentUser: currentUser)
                navigationController?.pushViewController(vc, animated: true)
                return
                
            } else {
                let user = User(name: message.nameSender, id: message.sendId, picture: message.avataSender, email: "", password: "", isActive: false)
                let vc = DetailViewViewController.instance(user, currentUser: currentUser)
                navigationController?.pushViewController(vc, animated: true)
            }

            if message.receiverID == currentUser.id {
                //presenter.setState(currentUser, reciverUser: reciverUser)
            }
        }
        else if tableView === listAllUser {
            guard let user = presenter.getcurrentUser() else { return }
            guard let reciver = presenter.getCellForUsers(at: indexPath.row) else {return}
            let vc = DetailViewViewController.instance(reciver, currentUser: user)
            navigationController?.pushViewController(vc, animated: true)
        }
        
               
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, _, _ in
            self.presenter.deleteUser(indexPath.row) { [weak self] in
                self?.messageTable.reloadData()
            }
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}
// MARK: CollectionView

extension ListUserViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return presenter.getNumberOfActiveUser()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let currentUser = presenter.getcurrentUser()
            let cell = listUserActive.dequeueReusableCell(withReuseIdentifier: "listActiveUserCell", for: indexPath) as! ListUserActiveCollectionCell
            cell.updateUI(presenter.getIndexOfActiveUser(indexPath.item), text: searchUser.text ?? "", currentuser: currentUser)
            return cell
     
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.item == 0 {
//            let user = presenter.getcurrentUser()
//            let vc = CreateStatusViewController.instance(user)
//            present(vc, animated: true)
//            return
//        }
//        else {
            guard let user = presenter.getIndexOfActiveUser(indexPath.item) else {return}
            guard let currentUser = presenter.getcurrentUser() else {return}
            let vc = DetailViewViewController.instance(user, currentUser: currentUser)
            navigationController?.pushViewController(vc, animated: true)
//        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}


extension ListUserViewController: ListUserPresenterDelegate {
    func didFetchUser() {
        self.listUserActive.reloadData()
        self.listAllUser.reloadData()
    }
    
    func didFetchMessageForUser() {
        self.messageTable.reloadData()
    }
    
    func didGetImageForCurrentUser(_ image: UIImage) {
        DispatchQueue.main.async {
            self.avatar.image = image
        }
    }
    
    func showSearchUser() {
        self.listAllUser.reloadData()
    }
    func deleteUser(at index: Int) { 
        self.messageTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.messageTable.reloadData()
    }
    func showStateMassage() {
        self.messageTable.reloadData()
        self.listUserActive.reloadData()
        self.listAllUser.reloadData()
    }
    
}

extension ListUserViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === searchUser {
            UIView.animate(withDuration: 0.2) {
                
                self.listAllUser.isHidden = false
                self.listUserActive.isHidden = true
                self.messageTable.isHidden = true
                self.viewUser.isHidden = true
                
                self.listAllUserTopContrain.constant = 40
                self.trailingSearchUserContrains.constant = 100
                self.heightSearchUserContrains.constant = 5
                self.btCancelSearchUser.isHidden = false
            }
            
        }
        
        return true
    }
}


