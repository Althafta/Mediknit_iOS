//
//  OFAChallengesAssessmentAnswerOptionsTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/3/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAChallengesAssessmentAnswerOptionsTableViewCell: UITableViewCell {

    @IBOutlet var viewBackground: UIView!
    @IBOutlet var labelOptionCount: UILabel!
    @IBOutlet var webViewOptions: UIWebView!
    @IBOutlet var buttonCheckbox: UIButton!
    @IBOutlet var buttonRadioButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
