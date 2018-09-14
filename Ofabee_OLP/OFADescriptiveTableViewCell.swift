//
//  OFADescriptiveTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/21/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFADescriptiveTableViewCell: UITableViewCell {

    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelFullName: UILabel!
    @IBOutlet var textViewComment: UITextView!
    @IBOutlet var buttonOption: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(imageURLString:String,fullName:String,comment:String){
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.clipsToBounds = true
        
        self.labelFullName.text = fullName
        self.textViewComment.text = comment
        self.imageViewUser.sd_setImage(with: URL(string:imageURLString), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
    }
}
