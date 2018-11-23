//
//  OFAQuestionDetailsRepliesTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAQuestionDetailsRepliesTableViewCell: UITableViewCell {

    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelFullName: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var textViewComments: UITextView!
    @IBOutlet var buttonOptions: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //imageURLString is the name of the user who made the comment
    
    func customizeCellWithDetails(imageURLString:String,fullName:String,commentDate:String,comments:String){
//        self.imageViewUser.sd_setImage(with: URL(string: imageURLString), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
        self.imageViewUser.setImageWith(imageURLString, color: OFAUtils.getRandomColor(), circular: true)
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.width/2
        self.imageViewUser.clipsToBounds = true
        self.labelDate.text = commentDate
        self.labelFullName.text = fullName
        self.textViewComments.text = comments
        self.buttonOptions.isHidden = true
    }
}
