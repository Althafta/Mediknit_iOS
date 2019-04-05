//
//  OFADashboardOtherCoursesCollectionViewCell.swift
//  Mediknit
//
//  Created by Syam PJ on 03/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit

protocol OtherCoursesCollectionDelegate {
    func getRedirectURL(url:String,pageTitle:String)
}

class OFADashboardOtherCoursesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewCourse: UIImageView!
    @IBOutlet weak var labelCourseTitle: UILabel!
    @IBOutlet weak var textViewCourseDescription: UITextView!
    @IBOutlet weak var buttonRedirect: UIButton!
    
    var delegate:OtherCoursesCollectionDelegate!
    var URLString = ""
    var titleString = ""
    
    func customizeCellWithDetails(imageURL:String,courseTitle:String,courseDescription:String,buttonTitle:String,redirectURL:String){
        self.imageViewCourse.sd_setImage(with: URL(string: imageURL)!, placeholderImage: UIImage(named: "Default image"), options: .progressiveDownload)
        self.labelCourseTitle.text = courseTitle
        self.textViewCourseDescription.text = OFAUtils.getHTMLAttributedString(htmlString: courseDescription)
        self.buttonRedirect.setTitle(buttonTitle, for: .normal)
        if redirectURL == ""{
            self.buttonRedirect.isHidden = true
        }else{
            self.buttonRedirect.isHidden = false
        }
        self.URLString = redirectURL
        self.titleString = courseTitle
    }
    
    @IBAction func redirectURLPressed(_ sender: UIButton) {
        self.delegate.getRedirectURL(url: self.URLString, pageTitle: self.titleString)
    }
}
