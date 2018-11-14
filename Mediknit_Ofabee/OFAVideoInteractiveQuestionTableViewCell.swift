//
//  OFAVideoInteractiveQuestionTableViewCell.swift
//  Mediknit
//
//  Created by Syam PJ on 09/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAVideoInteractiveQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var textViewOption: UITextView!
    @IBOutlet weak var imageViewStatus: UIImageView!
    var optionIndex = ""
    var cellSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
