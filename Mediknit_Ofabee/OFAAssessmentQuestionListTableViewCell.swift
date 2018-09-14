//
//  OFAAssessmentQuestionListTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 10/6/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAAssessmentQuestionListTableViewCell: UITableViewCell {

    @IBOutlet var textViewQuestion: UITextView!
    @IBOutlet var labelQuestionNumber: UILabel!
    @IBOutlet var viewCountBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetail(questionCount:String,questionString:String,questionStatus:String){
        self.textViewQuestion.text = questionString
        self.labelQuestionNumber.text = questionCount
        self.viewCountBackground.layer.cornerRadius = self.viewCountBackground.frame.height/2
        
        /*
         0-Answered, 1-ReviseLater, 2-Attended
         */
        if questionStatus == "0"{
            self.labelQuestionNumber.textColor = .white
            self.viewCountBackground.backgroundColor = OFAUtils.getColorFromHexString("00BFA5")
            self.viewCountBackground.layer.borderColor = UIColor.clear.cgColor
        }else if questionStatus == "1"{
            self.labelQuestionNumber.textColor = .white
            self.viewCountBackground.backgroundColor = OFAUtils.getColorFromHexString("32377A")
            self.viewCountBackground.layer.borderColor = UIColor.clear.cgColor
        }else if questionStatus == "2"{
            self.labelQuestionNumber.textColor = .white
            self.viewCountBackground.backgroundColor = OFAUtils.getColorFromHexString(materialRedColor)
            self.viewCountBackground.layer.borderColor = UIColor.clear.cgColor
        }else{
            self.labelQuestionNumber.textColor = .black
            self.viewCountBackground.backgroundColor = .white
            self.viewCountBackground.layer.borderColor = UIColor.black.cgColor
            self.viewCountBackground.layer.borderWidth = 1.0
        }
    }
}
