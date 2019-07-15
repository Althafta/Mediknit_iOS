//
//  OFADashboardTableViewCell.swift
//  Mediknit
//
//  Created by Syam PJ on 02/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

protocol MyCourseDashboardListDelegate {
    func pushToCourseDetails(dicDetails:NSDictionary)
    func getArrayCount(arrayMyCourses:NSMutableArray,identifier:String)
}

class OFADashboardTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewMyCourse: UICollectionView!
    @IBOutlet weak var labelCourseTitle: UILabel!
    
    var delegate:MyCourseDashboardListDelegate!
    
    var courseTitle = ""
    var arrayCourseList = NSMutableArray()
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.labelCourseTitle.text = self.courseTitle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK:- Cell customizisation
    
    func customizeCellWithDetails(sectionTitle:String, identifier:String){
        self.labelCourseTitle.text = sectionTitle
        self.getCourseList(usingIdentifier: identifier)
    }
    
    //MARK:- Get course list
    
    func getCourseList(usingIdentifier identifier:String){
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,identifier], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"identifier" as NSCopying])
//        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/dashboard_course", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResponse = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResponse["success"]!)" == "1"{
                    if let dicBody = dicResponse["body"] as? NSDictionary{
                        let arrayCourse = dicBody["course"] as! NSArray
                        for item in arrayCourse{
                            let dicCourseDetails = item as! NSDictionary
                            if !self.arrayCourseList.contains(dicCourseDetails){
                                self.arrayCourseList.add(dicCourseDetails)
                            }
                        }
                    }
                    self.delegate.getArrayCount(arrayMyCourses: self.arrayCourseList, identifier: identifier)
                    self.collectionViewMyCourse.reloadData()
                }else{
                    OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("My course detail loading failed")
            }
        }
    }
    
    //MARK:- CollectionView delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayCourseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionViewMyCourse.dequeueReusableCell(withReuseIdentifier: "MyCoursesCollectionViewCell", for: indexPath) as! OFADashboardCoursesCollectionViewCell
        let dicCourseDetail = self.arrayCourseList[indexPath.row] as! NSDictionary
        cell.customizeCellWithDetails(imageURL: "\(dicCourseDetail["cb_image"]!)", courseTitle: "\(dicCourseDetail["cb_title"]!)", lectureCount: "\(dicCourseDetail["total_lectures"]!)", lecturePercentage: "\(dicCourseDetail["percentage"]!)", startDate: self.getFormattedStringDate(stringDate: "\(dicCourseDetail["cs_start_date"]!)"), endDate: self.getFormattedStringDate(stringDate: "\(dicCourseDetail["cs_end_date"]!)"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicCourseDetail = self.arrayCourseList[indexPath.row] as! NSDictionary
        self.delegate.pushToCourseDetails(dicDetails: dicCourseDetail)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 10
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerSupplementaryView = UICollectionReusableView()
        footerSupplementaryView.frame = CGRect(x: 0, y: 0, width: 20, height: collectionView.frame.height)
        return footerSupplementaryView
    }
    
    //MARK:- Date Formatter
    
    func getDateFromString(stringDate:String)->Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyy-MM-dd"
        let local = Locale(identifier: "en_US")
        dateFormatter.locale=local
        return dateFormatter.date(from: stringDate)!
    }
    
    func getStringFromDate(date:Date)->String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="dd MMM yyyy"
        let local = Locale(identifier: "en_US")
        dateFormatter.locale=local
        return dateFormatter.string(from:date)
    }
    
    func getFormattedStringDate(stringDate:String) -> String{
        return self.getStringFromDate(date: self.getDateFromString(stringDate: stringDate)!)!
    }
}
