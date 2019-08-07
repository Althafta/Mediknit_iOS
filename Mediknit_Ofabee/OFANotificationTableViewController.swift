//
//  OFANotificationTableViewController.swift
//  Mediknit
//
//  Created by Enfin on 26/07/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFANotificationTableViewController: UITableViewController {

    var arrayNotification = NSMutableArray()
    var refreshController = UIRefreshControl()
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    
    var isCourseSpecific = false
    var courseID = ""
    
    var arraySenderTag = [Int]()
    var isSeeMorePressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.refreshController.addTarget(self, action: #selector(self.getNotifications), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
        
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Announcements"
        self.getNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK:- API Helpers
    
    @objc func getNotifications(){
        let dicParameters = !self.isCourseSpecific ? NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying]) : NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,self.courseID], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"course_id" as NSCopying])

        Alamofire.request(userBaseURL+"api/course/announcement_notification", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                if let dicBody = dicResult["body"] as? NSDictionary{
                    if let arrayNotifications = dicBody["notification"] as? NSArray{
                        self.arraySenderTag.removeAll()
                        self.arrayNotification.removeAllObjects()
                        for item in arrayNotifications{
                            var dicItem = item as! Dictionary<String,Any>
                            dicItem["isSeeMorePressed"] = "0"
                            self.arrayNotification.add(dicItem)
                        }
                        if arrayNotifications.count <= 0{
                            OFAUtils.showToastWithTitle("No notificaitons")
                        }
                    }else{
                        OFAUtils.showToastWithTitle("No notificaitons")
                    }
                }else{
                    OFAUtils.showToastWithTitle("No notificaitons")
                }
                self.refreshController.endRefreshing()
                self.tableView.reloadData()
            }else{
                self.refreshController.endRefreshing()
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func changeReadStatusOfNotifications(notificationID:String){
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,notificationID], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"notification_id" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/announcement_read_status", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                if "\(dicResult["success"]!)" == "1"{
                    self.getNotifications()
                }else{
                    OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                }
                self.tableView.reloadData()
            }else{
                print("Notification API failed")
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayNotification.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! OFANotificationTableViewCell
        
        var dicNotification = self.arrayNotification[indexPath.row] as! Dictionary<String,Any>
        cell.buttonSeeMore.tag = indexPath.row
        if "\(dicNotification["isSeeMorePressed"]!)" == "1"{
            cell.buttonSeeMore.isHidden = true
            cell.buttonSeeMore.setTitle("...Read less", for: .normal)
        }else{
            cell.buttonSeeMore.isHidden = false
            cell.buttonSeeMore.setTitle("...Read more", for: .normal)
        }
        cell.customizeCellWithDetails(notificationTitle: "\(dicNotification["subject"]!)", notificationBody: "\(dicNotification["body"]!)", isRead: "\(dicNotification["readStatus"]!)" == "1" ? true : false, dateString: "\(dicNotification["updated_datetime"]!)", courseName: "\(dicNotification["cb_title"]!)")
        let numberOfLines = Int(cell.labelNotificationBody.intrinsicContentSize.height / cell.labelNotificationBody.font!.lineHeight)
        dicNotification["number_of_lines"] = numberOfLines
        if numberOfLines <= 3{
            cell.buttonSeeMore.isHidden = true
        }else{
            cell.buttonSeeMore.isHidden = false
        }
        self.arrayNotification.replaceObject(at: indexPath.row, with: dicNotification)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dicNotification = self.arrayNotification[indexPath.row] as! NSDictionary
        self.changeReadStatusOfNotifications(notificationID: "\(dicNotification["id"]!)")
        
        let myCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseDetailsVC") as! OFAMyCourseDetailsViewController
        
        myCourseDetails.courseTitle = "\(dicNotification["cb_title"]!)"
        myCourseDetails.promoImageURLString = "\(dicNotification["cb_image"]!)"
        COURSE_ID = "\(dicNotification["course_id"]!)"
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(myCourseDetails, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dicNotification = self.arrayNotification[indexPath.row] as! NSDictionary
        if let numberOfLines = dicNotification["number_of_lines"] as? Int{
            if numberOfLines > 3{
                if self.arraySenderTag.contains(indexPath.row){
                    if "\(dicNotification["isSeeMorePressed"]!)" == "1"{
                        self.tableView.estimatedRowHeight = 197
                        self.tableView.rowHeight = UITableView.automaticDimension
                        return self.tableView.rowHeight
                    }else{
                        return 197
                    }
                }
            }else{
                if self.arraySenderTag.contains(indexPath.row){
                    if "\(dicNotification["isSeeMorePressed"]!)" == "1"{
                        self.tableView.estimatedRowHeight = 197
                        self.tableView.rowHeight = UITableView.automaticDimension
                        return self.tableView.rowHeight
                    }else{
                        return 197
                    }
                }
            }
            return 197
        }else{
            self.tableView.estimatedRowHeight = 197
            self.tableView.rowHeight = UITableView.automaticDimension
            return self.tableView.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let dicNotification = self.arrayNotification[indexPath.row] as! NSDictionary
        let rowActionMarkRead = UITableViewRowAction(style: .normal, title: "Mark as read") { (rowAction, indexPath) in
            self.changeReadStatusOfNotifications(notificationID: "\(dicNotification["id"]!)")
        }
        rowActionMarkRead.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        if "\(dicNotification["readStatus"]!)" == "0"{
            return [rowActionMarkRead]
        }else{
            return []
        }
        
    }
    
    //MARK:- Button Actions
    
    @IBAction func seeMorePressed(_ sender: UIButton) {
        if !self.arraySenderTag.contains(sender.tag){
            self.arraySenderTag.append(sender.tag)
        }
        self.isSeeMorePressed = !self.isSeeMorePressed
        var dicNotification = self.arrayNotification[sender.tag] as! Dictionary<String,Any>
        if !self.isSeeMorePressed{
            dicNotification["isSeeMorePressed"] = "0"
        }else{
            dicNotification["isSeeMorePressed"] = "1"
        }
        self.arrayNotification.replaceObject(at: sender.tag, with: dicNotification)
        self.tableView.reloadData()
    }
}
