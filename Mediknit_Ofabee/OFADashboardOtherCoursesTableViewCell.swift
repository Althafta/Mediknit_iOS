//
//  OFADashboardOtherCoursesTableViewCell.swift
//  Mediknit
//
//  Created by Syam PJ on 03/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

protocol OtherCourseTableViewCellDelegate {
    func pushToWebViewController(redirectURL:String, titleString:String)
}

class OFADashboardOtherCoursesTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,OtherCoursesCollectionDelegate {

    @IBOutlet weak var collectionViewOtherCourses: UICollectionView!
    @IBOutlet weak var labelCourseSectionTitle: UILabel!
    
    var delegate:OtherCourseTableViewCellDelegate!
    
    var courseTitle = ""
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    
    var arrayCourseList = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.labelCourseSectionTitle.text = self.courseTitle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func customizeCellWithDetails(sectionTitle:String, identifier:String){
        self.labelCourseSectionTitle.text = sectionTitle
        self.getCourseList(usingIdentifier: identifier)
    }
    
    func getCourseList(usingIdentifier identifier:String){
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,identifier], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"identifier" as NSCopying])
//        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/dashboard_course", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResponse = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                print(dicResponse)
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
                    self.collectionViewOtherCourses.reloadData()
                }else{
                    OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("Other course detail loading failed")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayCourseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionViewOtherCourses.dequeueReusableCell(withReuseIdentifier: "OtherCoursesCollectionViewCell", for: indexPath) as! OFADashboardOtherCoursesCollectionViewCell
        let dicCourseDetail = self.arrayCourseList[indexPath.row] as! NSDictionary
        cell.delegate = self
        cell.customizeCellWithDetails(imageURL: "\(dicCourseDetail["cb_image"]!)", courseTitle: "\(dicCourseDetail["cb_title"]!)", courseDescription: "\(dicCourseDetail["course_discription"]!)", buttonTitle: "\(dicCourseDetail["button_name"]!)", redirectURL: "\(dicCourseDetail["cb_url"]!)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 10
    }
    
    //MARK:- Other Course Delegate
    
    func getRedirectURL(url: String, pageTitle: String) {
        self.delegate.pushToWebViewController(redirectURL:url, titleString:pageTitle)
    }
}

