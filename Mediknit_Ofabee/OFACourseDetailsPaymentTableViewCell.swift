//
//  OFACourseDetailsPaymentTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFACourseDetailsPaymentTableViewCell: UITableViewCell {

    @IBOutlet var labelDiscountedPrice: UILabel!
    @IBOutlet var labelOriginalPrice: UILabel!
    @IBOutlet var buttonBuyNow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizePaymentDetails(discountPrice:String,originalPrice:String){
//        if originalPrice == "<null>" || originalPrice == "0" || discountPrice == "<null>" || discountPrice == "0" {
//            self.buttonBuyNow.setTitle("Free", for: .normal)
//        }else{
//            self.buttonBuyNow.setTitle("Subscribe", for: .normal)
//        }
        var mAmount = ""
        if discountPrice != "<null>" || discountPrice != ""{
            if discountPrice == "0"{
                if originalPrice != "0"{
                    mAmount = originalPrice
                    labelDiscountedPrice.text = "RS. \(originalPrice)"
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "RS. \(discountPrice)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    labelOriginalPrice.attributedText = attributeString
                }else{
                    labelDiscountedPrice.text = ""//"Free"
                    labelOriginalPrice.text = ""
                    buttonBuyNow.setTitle("Get", for: .normal)
                    //isFree
                }
            }else{
                if originalPrice != "0"{
                    mAmount = discountPrice
                    labelDiscountedPrice.text = discountPrice
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "RS. \(originalPrice)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    labelOriginalPrice.attributedText = attributeString
                }else{
                    labelDiscountedPrice.text = ""//"Free"
                    labelOriginalPrice.text = ""
                    buttonBuyNow.setTitle("Get", for: .normal)
                    //isFree
                }
            }
        }else{
            if originalPrice != "0"{
                mAmount = originalPrice
                labelDiscountedPrice.text = "RS. \(originalPrice)"
            }else{
                labelDiscountedPrice.text = ""//"Free"
                labelOriginalPrice.text = ""
                buttonBuyNow.setTitle("Get", for: .normal)
                //isFree
            }
        }
        print("mAmount: = \(mAmount)")
        self.buttonBuyNow.layer.cornerRadius = self.buttonBuyNow.frame.height/2
    }
}
