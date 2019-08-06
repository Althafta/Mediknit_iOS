//
//  OFANotificationTableViewCell.swift
//  Mediknit
//
//  Created by Enfin on 26/07/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit

class OFANotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var labelNotificationTitle: UILabel!
//    @IBOutlet weak var textViewNotificationBody: UITextView!
    @IBOutlet weak var labelNotificationBody: UILabel!
    @IBOutlet weak var labelReadIndicator: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var labelCourseName: UILabel!
    @IBOutlet weak var labelNotificationDate: UILabel!
    @IBOutlet weak var buttonSeeMore: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(notificationTitle:String,notificationBody:String,isRead:Bool,dateString:String,courseName:String){
        self.viewBackground.dropShadow()
        self.viewBackground.layer.cornerRadius = 10.0
        self.labelReadIndicator.layer.cornerRadius = self.labelReadIndicator.frame.height/2
        self.labelNotificationTitle.text = notificationTitle
        
        self.labelNotificationBody.text = OFAUtils.getHTMLAttributedString(htmlString: OFAUtils.trimWhiteSpaceInString(notificationBody))
        self.labelReadIndicator.isHidden = isRead ? true : false
        
        self.labelNotificationDate.text = dateString
        self.labelCourseName.text = courseName
    }
}
