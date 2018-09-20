//
//  OFAWishListTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/28/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import STRatingControl

class OFAWishListTableViewCell: UITableViewCell {

    @IBOutlet var imageViewCourse: UIImageView!
    @IBOutlet var buttonWishlist: UIButton!
    @IBOutlet var labelCourseTitle: UILabel!
    @IBOutlet var labelCourseAuthors: UILabel!
    @IBOutlet var labelCoursePrice: UILabel!
    @IBOutlet var labelCourseDiscountPrice: UILabel!
    @IBOutlet var starRatingView: STRatingControl!
    
    @IBOutlet var viewBrowseCourse: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func customizeCellWithDetails(imageURL:String,courseTitle:String,courseAuthors:String,coursePrice:String,courseDiscountPrice:String,ratingValue:String){
        self.labelCourseTitle.text = courseTitle
        self.labelCourseAuthors.text = "By "+courseAuthors
        
        self.labelCoursePrice.adjustsFontSizeToFitWidth = true
        self.labelCourseDiscountPrice.adjustsFontSizeToFitWidth = true
        if courseDiscountPrice != "<null>" || courseDiscountPrice != ""{
            if courseDiscountPrice == "0"{
                if coursePrice != "0"{
                    //                    mAmount = coursePrice
                    labelCourseDiscountPrice.text = "RS. \(coursePrice)"
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "RS. \(courseDiscountPrice)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    labelCoursePrice.attributedText = attributeString
                }else{
                    labelCourseDiscountPrice.text = "Free"
                    labelCoursePrice.text = ""
                    
                    //isFree
                }
            }else{
                if coursePrice != "0"{
                    //                    mAmount = courseDiscountPrice
                    labelCourseDiscountPrice.text = courseDiscountPrice
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "RS. \(coursePrice)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    labelCoursePrice.attributedText = attributeString
                }else{
                    labelCourseDiscountPrice.text = "Free"
                    labelCoursePrice.text = ""
                    //isFree
                }
            }
        }else{
            if coursePrice != "0"{
                //                mAmount = coursePrice
                labelCourseDiscountPrice.text = "RS. \(coursePrice)"
            }else{
                labelCourseDiscountPrice.text = "Free"
                labelCoursePrice.text = ""
                //isFree
            }
        }
        //        print("mAmount: = \(mAmount)")
        
        self.imageViewCourse.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
        //        let data = try! Data(contentsOf: URL(string: imageURL)!)
        //        self.imageViewCourse.image = UIImage(data: data)
        
        self.buttonWishlist.layer.cornerRadius = self.buttonWishlist.frame.width/2
        
        let rating = ratingValue.components(separatedBy: ".")[0]
        self.starRatingView.rating = Int(rating)!
        
        self.viewBrowseCourse.dropShadow()
        self.buttonWishlist.dropShadow()
    }
}
