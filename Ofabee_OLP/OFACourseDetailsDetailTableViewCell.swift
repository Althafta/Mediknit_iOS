//
//  OFACourseDetailsDetailTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import STRatingControl

class OFACourseDetailsDetailTableViewCell: UITableViewCell {

    @IBOutlet var labelCourseTitle: UILabel!
    @IBOutlet var labelAuthors: UILabel!
    @IBOutlet var starRatingView: STRatingControl!
    @IBOutlet var labelReviewCount: UILabel!
//    @IBOutlet var labelStudentsEnrolled: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCourseDetailsCell(courseTitle:String,authors:String,ratingValue:String,reviewCount:String,studentsEnrolled:String){
        self.labelCourseTitle.text = courseTitle
        self.labelAuthors.text = authors
        
        let rating = ratingValue.components(separatedBy: ".")[0]
        self.starRatingView.rating = Int(rating)!
        self.labelReviewCount.text = "\(reviewCount) Reviews  \(studentsEnrolled) Enrolled"
//        self.labelStudentsEnrolled.text = ""//"\(studentsEnrolled) Students Enrolled"
    }
}
