//
//  OFALectureDiscussionMyQuestionsTableViewCell.swift
//  Mediknit
//
//  Created by Syam PJ on 15/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFALectureDiscussionMyQuestionsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textViewComment: UITextView!
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
    
    func customizeCellWithDetails(comment:String,author:String,dateString:String,numberOfReplies:String,status:String){
        self.imageViewIcon.layer.cornerRadius = self.imageViewIcon.frame.height/2
        var imageName = ""
        if status == "0"{
            imageName = "DiscussionComment"
        }else if status == "1"{
            imageName = "DiscussionQuestion"
        }
        self.imageViewIcon.image = UIImage(named: imageName)
        self.textViewComment.text = comment
        self.labelAuthor.text = author
        
        self.labelDetails.text = "\(dateString)"//"     \(numberOfReplies) replies"
    }

}
