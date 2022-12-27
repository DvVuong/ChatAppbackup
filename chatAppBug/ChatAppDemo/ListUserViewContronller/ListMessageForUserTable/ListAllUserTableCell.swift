//
//  ListAllUserTableCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 27/12/2022.
//

import UIKit

class ListAllUserTableCell: UITableViewCell {
    
    @IBOutlet private weak var avatarUser: CustomImage!
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var imgStateActive: CustomImage!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(_ user: User?) {
        guard let user = user else {return}
        lbNameUser.text = user.name
        
        ImageService.share.fetchImage(with: user.picture) {[weak self] image in
            DispatchQueue.main.async {
                self?.avatarUser.image = image
            }
        }
        
        imgStateActive.tintColor = user.isActive ? .green : .systemGray
        
    }

}
