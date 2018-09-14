//
//  OFACourseDdetailsReviewTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import STRatingControl
import Alamofire

protocol CourseDetailsReviewDelegate{
    func updateRowHeightForReview(with array:NSMutableArray)
}

class OFACourseDetailsReviewTableViewCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var labelReviewCount: UILabel!
    @IBOutlet var starRatingView: STRatingControl!
    @IBOutlet var labelTotalRating: UILabel!
    @IBOutlet var tableViewReviewsList: UITableView!
    @IBOutlet var buttonShowMore: UIButton!
    
    var delegate:CourseDetailsReviewDelegate!
    var arrayReviews = NSMutableArray()
    var totalReviewCount = 0
    var courseId = ""
    var offset = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewReviewsList.dequeueReusableCell(withIdentifier: "CourseReviewsList", for: indexPath) as! OFACourseReviewsTableViewCell
        let dicReview = self.arrayReviews[indexPath.row] as! NSDictionary
        //created_date
        let createTimeString = "\(dicReview["created_date"]!)"
        let createdDate = OFAUtils.getDateFromString(createTimeString)
        let createTime = self.getTimeAgo(time:  UInt64(createdDate.millisecondsSince1970))
        cell.customizeCellWithDetails(imageURL: "\(dicReview["us_image"]!)", fullName: "\(dicReview["us_name"]!)", comment: "\(dicReview["rv_reviews"]!)", timeDuration: createTime!, rating: "\(dicReview["cc_rating"]!)")
        return cell
    }
    
    @IBAction func showMoreReviewsPressed(_ sender: UIButton) {
        self.offset += 1
        if self.offset == 1 {
            self.arrayReviews.removeAllObjects()
        }
        let dicParameters = NSDictionary(objects: [self.courseId,self.offset], forKeys: ["course_id" as NSCopying,"offset" as NSCopying])
        OFAUtils.showLoadingViewWithTitle(nil)
        Alamofire.request(userBaseURL+"api/course/course_reviews", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                let dicBody = dicResult["body"] as! NSDictionary
                if let arrReviews = dicBody["reviews"] as? NSArray{
                    
                    for item in arrReviews{
                        self.arrayReviews.add(item as! NSDictionary)
                    }
                    if self.arrayReviews.count == self.totalReviewCount {
                        self.buttonShowMore.isHidden = true
                    }
                }else{
                    OFAUtils.showToastWithTitle("No more Reviews")
                    self.buttonShowMore.isHidden=true
                }
                self.delegate.updateRowHeightForReview(with: self.arrayReviews)
                OFAUtils.removeLoadingView(nil)
                self.tableViewReviewsList.reloadData()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Get TimeStamp string
    
    func getTimeAgo(time:UInt64) -> String? {
        let secondMilliSecond:UInt64 = 1000
        let minuteMilliSecond:UInt64 = 60 * secondMilliSecond
        let hoursMillisecond:UInt64 = 60 * minuteMilliSecond
        //        let DAY_MILLIS:UInt64 = 24 * HOUR_MILLIS
        var time = time
        if time < 1000000000000 {
            time *= 1000
        }
        let nowMilliSecs = Date().millisecondsSince1970
        if time > nowMilliSecs || time <= 0{
            return nil
        }
        let diff = nowMilliSecs - time
        
        if diff < minuteMilliSecond {
            return "just now"
        } else if diff < 2 * minuteMilliSecond {
            return "a minute ago"
        } else if diff < 50 * minuteMilliSecond {
            return "\(diff / minuteMilliSecond)" + " mins ago"
        } else if diff < 90 * minuteMilliSecond {
            return "an hour ago"
        } else if diff < 24 * hoursMillisecond {
            return "\(diff / hoursMillisecond)" + " hrs ago"
        } else if (diff < 48 * hoursMillisecond) {
            return "yesterday";
        }else{
            let createDate = Date(milliseconds: time)
            let createTime = OFAUtils.getStringFromMilliSecondDate(date: createDate)
            return createTime
        }
    }
}
