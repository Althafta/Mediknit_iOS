//
//  OFAMeditationTableViewCell.swift
//  Life_Line
//
//  Created by Syam PJ on 13/09/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAMeditationTableViewCell: UITableViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var labelHeadingName: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(heading:String,instruction:String){
        self.labelHeadingName.text = heading
        self.textViewDescription.text = instruction
    }
}
