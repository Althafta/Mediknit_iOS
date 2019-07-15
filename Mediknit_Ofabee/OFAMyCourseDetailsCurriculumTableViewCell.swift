//
//  OFAMyCourseDetailsCurriculumTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAMyCourseDetailsCurriculumTableViewCell: UITableViewCell {

    @IBOutlet var labelCurriculumTitle: UILabel!
    @IBOutlet var labelDetails: UILabel!
    @IBOutlet var buttonProgress: MHProgressButton!
    @IBOutlet var labelSerialNumber: UILabel!
    @IBOutlet var buttonAction: OFACustomButton!
    @IBOutlet var buttonDownload: OFACustomButton!
    @IBOutlet var buttonCompleted: UIButton!
    @IBOutlet var imageViewIcon: UIImageView!
    @IBOutlet weak var labelPercentage: UILabel!
    
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var viewCountBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(curriculumTitle:String,details:String,percentage:CGFloat,serialNumber:String,downloadStatus:String,completeStatus:String,viewText:String,viewStatus:Bool){
        self.labelCurriculumTitle.text = curriculumTitle
        self.labelDetails.text = details
        self.buttonProgress.linearLoadingWith(progress: percentage)
        self.buttonProgress.layer.cornerRadius = self.buttonProgress.frame.height/2
        self.labelSerialNumber.text = serialNumber
        self.viewBackground.dropShadow()
        self.viewCountBG.layer.cornerRadius = self.viewCountBG.frame.height/2
        self.viewCountBG.dropShadow()
        self.labelCount.text = viewText
        self.viewCountBG.isHidden = viewStatus
        if percentage < 100{
            self.buttonCompleted.isHidden = true
            self.buttonDownload.isHidden = true
            self.buttonProgress.isHidden = false
            self.buttonAction.isHidden = false
            
            if downloadStatus == "0"{
                self.buttonDownload.isHidden = true
                self.buttonAction.isHidden = true
                self.buttonProgress.isHidden = false
            }
        }else{
            self.buttonCompleted.isHidden = false
            self.buttonDownload.isHidden = false
            self.buttonProgress.isHidden = true
            self.buttonAction.isHidden = true
            if downloadStatus == "0"{
                self.buttonDownload.isHidden = true
                self.buttonAction.isHidden = true
                self.buttonProgress.isHidden = true
            }
        }
    }
    
    func customizeCellWithDetails(curriculumTitle:String,details:String,percentage:CGFloat,serialNumber:String){
        self.buttonDownload.isHidden = true
        self.buttonAction.isHidden = true
//        self.buttonCompleted.isHidden = true
        self.viewCountBG.isHidden = true
        self.labelCount.isHidden = true
        if percentage >= 100{
            self.buttonCompleted.isHidden = false
            self.buttonProgress.isHidden = true
            self.labelPercentage.isHidden = true
        }else{
            self.buttonCompleted.isHidden = true
            self.buttonProgress.isHidden = false
            self.labelPercentage.isHidden = false
        }
        self.labelPercentage.text = "\(percentage) %"
        self.labelCurriculumTitle.text = curriculumTitle
        self.labelDetails.text = details
        self.buttonProgress.linearLoadingWith(progress: percentage)
        self.buttonProgress.layer.cornerRadius = self.buttonProgress.frame.height/2
        self.labelSerialNumber.text = serialNumber
        self.viewBackground.dropShadow()
    }
    
}
