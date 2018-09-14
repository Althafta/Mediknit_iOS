//
//  OFACourseInstructorsTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFACourseInstructorsTableViewCell: UITableViewCell {

    @IBOutlet var imageViewInstructor: UIImageView!
    @IBOutlet var labelFullName: UILabel!
    @IBOutlet var labelDesignation: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(imageURL:String,fullName:String,designation:String){
        self.imageViewInstructor.layer.cornerRadius = self.imageViewInstructor.frame.height/2
        self.imageViewInstructor.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
        self.labelFullName.text = fullName
        self.labelDesignation.text = designation
    }
}
