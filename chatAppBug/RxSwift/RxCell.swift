//
//  RxCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 03/01/2023.
//

import UIKit

class RxCell: UITableViewCell {

    @IBOutlet private weak var lbName: UILabel!
    
    @IBOutlet weak var imageUser: UIImageView!
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
        lbName.text = user.name        
        ImageService.share.fetchImage(with: user.picture) {[weak self] image in
            DispatchQueue.main.async {
                self?.imageUser?.image = image
            }
        }
    }

}
