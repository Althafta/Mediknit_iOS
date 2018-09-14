//
//  OFAMyCourseResultsTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAMyCourseResultsTableViewCell: UITableViewCell {

    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelMonth: UILabel!
    @IBOutlet var labelResultTitle: UILabel!
    @IBOutlet var labelScore: UILabel!
    @IBOutlet var labelTimeTaken: UILabel!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var viewDateBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(dateString:String,resultTitle:String,score:String,timeTaken:String){
        self.labelResultTitle.text = resultTitle
        self.labelScore.text = score
        self.labelTimeTaken.adjustsFontSizeToFitWidth = true
        self.labelTimeTaken.text = timeTaken
        
        self.viewContainer.dropShadow()
        
        self.viewDateBackground.clipsToBounds = true
        self.viewDateBackground.layer.cornerRadius = self.viewDateBackground.frame.width/2
        
        let arrayDateString = dateString.components(separatedBy: " ")
        self.labelDate.textColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
        self.labelDate.text = arrayDateString[0]
        self.labelMonth.text = arrayDateString[1]
    }
}
