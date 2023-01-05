//
//  ListUserCollectionViewCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 20/12/2022.
//

import UIKit

class ListUserActiveCollectionCell: UICollectionViewCell {
    @IBOutlet private weak var img: UIImageView!
    @IBOutlet private weak var lbName: UILabel!
    @IBOutlet private weak var imgState: CustomImage!
    
    
    override  func awakeFromNib() {
        img.layer.cornerRadius = img.frame.height / 2
        img.layer.masksToBounds = true
        img.contentMode = .scaleToFill
    }
    
    func updateUI(_ user: User?, text: String) {
        guard let user = user else {return}
        ImageService.share.fetchImage(with: user.picture) {[weak self] image in
            DispatchQueue.main.async {
                self?.img.image = image
            }
        }
        self.lbName.attributedText = ListCellPresenter.shared.setHiglight(text, user.name)
        self.imgState.tintColor = user.isActive ? .green : .systemGray
    }
}
