//
//  OFACourseReviewsTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import STRatingControl

class OFACourseReviewsTableViewCell: UITableViewCell {

    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelFullName: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var starRatingView: STRatingControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(imageURL:String,fullName:String,comment:String,timeDuration:String,rating:String){
        self.labelDate.text = timeDuration
        self.labelFullName.text = fullName
        self.labelComment.text = comment
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
        if rating == "" {
            self.starRatingView.rating = 0
        }else{
            self.starRatingView.rating = Int(rating)!
        }
    }
}
