//
//  OFACourseCurriculumTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFACourseCurriculumTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelDescription: UILabel!
    @IBOutlet var labelCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(curriculumTitle:String,curriculumType:String,count:String){
        self.labelTitle.text = curriculumTitle
        
        let fontVar = UIFont(fa_fontSize: 13)

        
        self.labelDescription.font = fontVar
        self.labelDescription.text = curriculumType
        self.labelCount.text = count
    }
}
