//
//  OFAMyCourseTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAMyCourseTableViewCell: UITableViewCell {

    @IBOutlet var imageViewCourse: UIImageView!
//    @IBOutlet var labelCourseTitle: UILabel!
    @IBOutlet var labelCourseDescription: UILabel!
    @IBOutlet var labelPercentage: UILabel!
    @IBOutlet var buttonProgress: MHProgressButton!
//    @IBOutlet var buttonCourseTitle: UIButton!
    @IBOutlet weak var textViewCourseTitle: UITextView!
    @IBOutlet var myCourseInnerView: UIView!
    @IBOutlet weak var myCourseShadeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(courseTitle:String,courseImageURL:String,courseDescription:String,percentage:String){
//        self.labelCourseTitle.text = courseTitle
//        self.buttonCourseTitle.setTitle(courseTitle, for: .normal)
//        self.layer.cornerRadius = 10.0
//        self.myCourseInnerView.layer.cornerRadius = 10.0
        self.textViewCourseTitle.text = courseTitle
        self.labelCourseDescription.text = courseDescription
        
        guard let n = NumberFormatter().number(from: percentage) else { return }
        self.buttonProgress.linearLoadingWith(progress: CGFloat(n))
        
        self.buttonProgress.layer.cornerRadius = self.buttonProgress.frame.height/2
        self.labelPercentage.text = "\(percentage) %"
        
//        let path = UIBezierPath(roundedRect:self.imageViewCourse.bounds,
//                                byRoundingCorners:[.topRight, .topLeft],
//                                cornerRadii: CGSize(width: 10, height:  10))
//        
//        let maskLayer = CAShapeLayer()
//        
//        maskLayer.path = path.cgPath
//        self.myCourseShadeView.layer.mask = maskLayer
//        self.imageViewCourse.layer.mask = maskLayer
        
        self.imageViewCourse.sd_setImage(with: URL(string: courseImageURL), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
        
        self.myCourseInnerView.dropShadow()
    }
}
