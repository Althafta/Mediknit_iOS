//
//  OFAOfferListTableViewCell.swift
//  Life_Line
//
//  Created by Administrator on 6/28/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAOfferListTableViewCell: UITableViewCell {

    @IBOutlet var labelOfferHeading: UILabel!
    @IBOutlet var textViewDescription: UITextView!
    @IBOutlet var buttonUseCode: UIButton!
    @IBOutlet var labelStaticUseCode: UILabel!
    @IBOutlet var labelExpiry: UILabel!
    @IBOutlet var labelStaticExpiry: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(offerTitle:String,offerDescription:String,offerCode:String,offerExpiry:String){
        self.labelOfferHeading.text = offerTitle
        self.textViewDescription.text = offerDescription
        self.buttonUseCode.setTitle(offerCode, for: .normal)
        self.labelExpiry.text = offerExpiry
        self.buttonUseCode.layer.cornerRadius = self.buttonUseCode.frame.height/2
        self.buttonUseCode.clipsToBounds=true
    }
}
