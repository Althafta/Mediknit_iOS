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
                    }
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
        
        let dicNotification = self.arrayNotification[indexPath.row] as! NSDictionary
        let date = OFAUtils.getDateFromStringWithFormat(dateString: "\(dicNotification["updated_datetime"]!)", format: "yyyy-MM-dd HH:mm:ss")
        let dateString = OFAUtils.getStringFromDateWithFormat(date: date, format: "dd-MM-yyyy HH:mm:ss")
        cell.buttonSeeMore.tag = indexPath.row
        if "\(dicNotification["isSeeMorePressed"]!)" == "1"{
            cell.buttonSeeMore.isHidden = true
        }else{
            cell.buttonSeeMore.isHidden = false
        }
        cell.customizeCellWithDetails(notificationTitle: "\(dicNotification["subject"]!)", notificationBody: "\(dicNotification["body"]!)", isRead: "\(dicNotification["readStatus"]!)" == "1" ? true : false, dateString: dateString, courseName: "Course Name")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.arraySenderTag.contains(indexPath.row){
            if self.isSeeMorePressed{
                self.tableView.estimatedRowHeight = 191
                self.tableView.rowHeight = UITableView.automaticDimension
                return self.tableView.rowHeight
            }else{
                return 191
            }
        }else{
            return 191
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowActionMarkRead = UITableViewRowAction(style: .normal, title: "Mark as read") { (rowAction, indexPath) in
            let dicNotification = self.arrayNotification[indexPath.row] as! NSDictionary
            self.changeReadStatusOfNotifications(notificationID: "\(dicNotification["id"]!)")
        }
        rowActionMarkRead.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        return [rowActionMarkRead]
    }
    
    //MARK:- Button Actions
    
    @IBAction func seeMorePressed(_ sender: UIButton) {
        if !self.arraySenderTag.contains(sender.tag){
            self.arraySenderTag.append(sender.tag)
        }
        self.isSeeMorePressed = true
//        sender.isHidden = true
        var dicNotification = self.arrayNotification[sender.tag] as! Dictionary<String,Any>
        dicNotification["isSeeMorePressed"] = "1"
        self.arrayNotification.replaceObject(at: sender.tag, with: dicNotification)
        self.tableView.reloadData()
    }
    
}
