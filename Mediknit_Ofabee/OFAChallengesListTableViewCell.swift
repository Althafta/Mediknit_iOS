//
//  OFAChallengesListTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 10/19/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAChallengesListTableViewCell: UITableViewCell {

    @IBOutlet var labelEndStatus: UILabel!
    @IBOutlet var labelEndDateStatus: UILabel!
    @IBOutlet var labelEndTime: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelMonth: UILabel!
    @IBOutlet var labelChallengeTitle: UILabel!
    @IBOutlet var viewDateBackground: UIView!
    @IBOutlet var viewContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(endStatus:String,endDateStatus:String,endTime:String,endDate:String,endMonth:String,challengeTitle:String){
        self.labelEndStatus.text = endStatus
        self.labelEndDateStatus.text = endDateStatus
        self.labelEndTime.text = endTime
        self.labelDate.text = endDate
        self.labelMonth.text = endMonth
        self.labelChallengeTitle.text = challengeTitle
        self.viewDateBackground.layer.cornerRadius = self.viewDateBackground.frame.height/2
        
    }
}
