//
//  OFAContactListTableViewCell.swift
//  Life_Line
//
//  Created by Administrator on 6/26/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAContactListTableViewCell: UITableViewCell {

    @IBOutlet var imageViewContactImage: UIImageView!
    @IBOutlet var labelContactName: UILabel!
    @IBOutlet var labelContactPhone: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(imageDetails:UIImage,name:String,phoneNumber:String){
        self.imageViewContactImage.layer.cornerRadius = self.imageViewContactImage.frame.height/2
        
        self.imageViewContactImage.image = imageDetails
        self.labelContactName.text = name
        self.labelContactPhone.text = phoneNumber
    }
}
