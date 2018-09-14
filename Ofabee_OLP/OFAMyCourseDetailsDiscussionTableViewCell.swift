//
//  OFAMyCourseDetailsDiscussionTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAMyCourseDetailsDiscussionTableViewCell: UITableViewCell {

    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelAuthor: UILabel!
    @IBOutlet var labelDetails: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(comment:String,author:String,dateString:String,numberOfReplies:String){
        self.labelComment.text = comment
        self.labelAuthor.text = author
        
        self.labelDetails.text = "\(dateString)     \(numberOfReplies) replies"
    }
}
