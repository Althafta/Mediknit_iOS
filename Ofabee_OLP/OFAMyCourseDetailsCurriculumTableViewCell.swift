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
    
    @IBOutlet var viewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(curriculumTitle:String,details:String,percentage:CGFloat,serialNumber:String,downloadStatus:String,completeStatus:String){
        self.labelCurriculumTitle.text = curriculumTitle
        self.labelDetails.text = details
        self.buttonProgress.linearLoadingWith(progress: percentage)
        self.buttonProgress.layer.cornerRadius = self.buttonProgress.frame.height/2
        self.labelSerialNumber.text = serialNumber
        self.viewBackground.dropShadow()
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
    
}
