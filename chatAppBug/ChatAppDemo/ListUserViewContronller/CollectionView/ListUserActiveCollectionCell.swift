//
//  ListUserCollectionViewCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 20/12/2022.
//

import UIKit

class ListUserActiveCollectionCell: UICollectionViewCell {
    @IBOutlet private weak var img: CustomImage!
    @IBOutlet private weak var lbName: UILabel!
    @IBOutlet private weak var imgState: UIImageView!
    
    func updateUI(_ user: User?, text: String) {
        guard let user = user else {return}
        ImageService.share.fetchImage(with: user.picture) { image in
            DispatchQueue.main.async {
                self.img.image = image
            }
        }
        if user.isActive == true {
            self.imgState.tintColor = .green
        } else {
            self.imgState.tintColor = .systemGray
        }
        
        lbName.attributedText = ListCellPresenter.shared.setHiglight(text, user.name)
    }
}
