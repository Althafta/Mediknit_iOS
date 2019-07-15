//
//  OFADashboardCoursesCollectionViewCell.swift
//  Mediknit
//
//  Created by Syam PJ on 02/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit

class OFADashboardCoursesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewMyCourse: UIImageView!
    @IBOutlet weak var labelMyCourseTitle: UILabel!
    @IBOutlet weak var labelMyCourseLectureCount: UILabel!
    @IBOutlet weak var labelMyCoursePercentage: UILabel!
    @IBOutlet weak var buttonPercentage: MHProgressButton!
    @IBOutlet weak var labelMyCourseStartDate: UILabel!
    @IBOutlet weak var labelMyCourseEndDate: UILabel!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    
    func customizeCellWithDetails(imageURL:String,courseTitle:String,lectureCount:String,lecturePercentage:String,startDate:String,endDate:String){
        self.imageViewMyCourse.sd_setImage(with: URL(string: imageURL)!, placeholderImage: UIImage(named: "Default image"), options: .progressiveDownload)
        self.labelMyCourseTitle.text = courseTitle
        self.labelMyCourseLectureCount.text = "course progress"//"Lecture "+lectureCount
        self.labelMyCourseEndDate.text = "Expires on : "
        self.labelMyCourseStartDate.text = "Enrolled on : "
        self.labelEndDate.text = endDate
        self.labelStartDate.text = startDate
        self.labelMyCoursePercentage.text = lecturePercentage + " %"
        
        guard let percentage = NumberFormatter().number(from: lecturePercentage) else { return }
        self.buttonPercentage.linearLoadingWith(progress: CGFloat(truncating: percentage))
        
        self.buttonPercentage.layer.cornerRadius = self.buttonPercentage.frame.height/2
    }
}
