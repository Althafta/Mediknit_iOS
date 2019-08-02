//
//  OFAMyCourseTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import FontAwesomeKit_Swift

class OFAMyCourseTableViewController: UITableViewController,UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var headerView: UIView!
    @IBOutlet var buttonLeftIcon: UIButton!
    @IBOutlet weak var textViewNoCourseDescription: UITextView!
    
    var arrayMyCourses = NSMutableArray()
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    
    var refreshController = UIRefreshControl()
    var searchBarButtonItem = UIBarButtonItem()
    
    var searchString = ""
    var filteredArray = NSArray()
    
    var notificationBarButtonItem = UIBarButtonItem()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK:- Life Cycle
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)//.white
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController

        self.searchBar.inputAccessoryView = OFAUtils.getDoneToolBarButton(tableView: self, target: #selector(self.tapAction))
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        self.headerView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.buttonLeftIcon)
        let barButtonlogout = UIBarButtonItem(image: UIImage(named: "Logout"), style: .plain, target: self, action: #selector(self.logoutPressed))
        let barButtonProfile = UIBarButtonItem(image: UIImage(named: "DashboardMyProfile"), style: .plain, target: self, action: #selector(self.profilePressed))
        self.notificationBarButtonItem = UIBarButtonItem(image: UIImage(named: "NotificationIcon"), style: .plain, target: self, action: #selector(self.notificationPressed))
        self.navigationItem.rightBarButtonItems = [barButtonlogout,barButtonProfile,self.notificationBarButtonItem]
        self.textViewNoCourseDescription.text = OFAUtils.getHTMLAttributedString(htmlString: "It looks like you are not enrolled to our e-courses! </br> Please visit www.mediknit.org to explore our learning programs or please contact info@mediknit.org for any clarifications or queries.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshInitiated()
        self.getNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "My Courses"
    }
    
    @objc func logoutPressed(_ sender: UIButton) {
        let logoutAlert = UIAlertController(title: "Do you want to logout?", message: nil, preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.logout()
        }))
        logoutAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(logoutAlert, animated: true, completion: nil)
    }
    
    @objc func profilePressed(){
        let myProfile = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTVC") as! OFAMyProfileTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(myProfile, animated: true)
    }
    
    @objc func notificationPressed(){
        let notificationPage = self.storyboard?.instantiateViewController(withIdentifier: "NotificationTVC") as! OFANotificationTableViewController
        notificationPage.isCourseSpecific = false
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(notificationPage, animated: true)
    }
    
    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    func getNotifications(){
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/announcement_notification", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                if let dicBody = dicResult["body"] as? NSDictionary{
                    if let arrayNotifications = dicBody["notification"] as? NSArray{
                        let arrayUnReadNotifications = NSMutableArray()
                        arrayUnReadNotifications.removeAllObjects()
                        for item in arrayNotifications{
                            let dicNotification = item as! NSDictionary
                            if "\(dicNotification["readStatus"]!)" == "0"{
                                arrayUnReadNotifications.add(dicNotification)
                            }
                        }
                        if arrayUnReadNotifications.count > 0{
                            self.notificationBarButtonItem.addBadge(number: arrayUnReadNotifications.count)
                        }
                    }
                }
            }else{
                print("Notification API failed")
            }
        }
    }
    
    @objc func refreshInitiated(){
        self.loadMyCourses()
    }
    
    func loadMyCourses(){
        
        var arrayCourses = NSArray()
        if let dataSubscribedCourses = UserDefaults.standard.value(forKey: Subscribed_Courses) as? Data{
            arrayCourses = NSKeyedUnarchiver.unarchiveObject(with: dataSubscribedCourses) as! NSArray
        }
        //        if self.user_id == nil {
//                    let browseCourse = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseTVC") as!OFABrowseCourseTableViewController
//                    self.navigationController?.pushViewController(browseCourse, animated: true)
        //        }else{
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,arrayCourses], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"courses" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/mycourse", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if responseJSON.response?.statusCode == 203 {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                if let arrCourses = dicBody["course"] as? NSArray{
                    if arrCourses.count > 0 {
                        self.arrayMyCourses.removeAllObjects()
                        for item in arrCourses{
                            let dicCourseDetails = item as! NSDictionary
                            self.arrayMyCourses.add(dicCourseDetails)
                        }
                        self.filteredArray = self.arrayMyCourses.mutableCopy() as! NSArray
                        self.refreshController.endRefreshing()
                        self.tableView.reloadData()
                    }
//                    else{
//                        let emptyAlert = UIAlertController(title: "Get Courses", message: "Get some courses to get trained on", preferredStyle: .alert)
//                        emptyAlert.addAction(UIAlertAction(title: "Get", style: .default, handler: { (alertAction) in
//                            let browseCourse = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseTVC") as!OFABrowseCourseTableViewController
//                            browseCourse.isPushedView = true
//                            self.navigationController?.children[0].navigationItem.title = ""
//                            self.navigationController?.pushViewController(browseCourse, animated: true)
//                        }))
//                        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
//
//                        }))
//                        self.present(emptyAlert, animated: true, completion: nil)
//                    }
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
            self.refreshController.endRefreshing()
            self.tableView.reloadData()
        }
        //        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCourseCell", for: indexPath) as! OFAMyCourseTableViewCell

        let dicDetails = self.filteredArray[indexPath.row] as! NSDictionary
        let descriptionString = "Course progress"//"Lecture \(dicDetails["total_lectures"]!)"
        cell.customizeCellWithDetails(courseTitle: "\(dicDetails["cb_title"]!)", courseImageURL: "\(dicDetails["cb_image"]!)", courseDescription: descriptionString, percentage: "\(dicDetails["percentage"]!)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseDetailsVC") as! OFAMyCourseDetailsViewController
        
        let dicDetails = self.filteredArray[indexPath.row] as! NSDictionary
        myCourseDetails.courseTitle = "\(dicDetails["cb_title"]!)"
        myCourseDetails.promoImageURLString = "\(dicDetails["cb_image"]!)"
        COURSE_ID = "\(dicDetails["id"]!)"
        if "\(dicDetails["subscription_status"]!)" == "3" {
            let sessionAlert = UIAlertController(title: nil, message: "\(dicDetails["subscription_message"]!)", preferredStyle: .alert)
            sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                sessionAlert.dismiss(animated: true, completion: nil)
            }))
            self.present(sessionAlert, animated: true, completion: nil)
            return
        }
        if "\(dicDetails["cs_approved"]!)" == "0" {
            let sessionAlert = UIAlertController(title: "Course not approved", message: nil, preferredStyle: .alert)
            sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                sessionAlert.dismiss(animated: true, completion: nil)
            }))
            self.present(sessionAlert, animated: true, completion: nil)
            return
        }
        if self.searchBar.isFirstResponder{
            self.view.endEditing(true)
        }
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(myCourseDetails, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
//        cell.layer.cornerRadius = 10.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 287
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
//        return 260
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.arrayMyCourses.count <= 0 {
            return self.headerView
        }else{
            return nil//self.searchBar
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.arrayMyCourses.count <= 0 {
            return self.view.frame.height/2
        }else{
            return 0//self.searchBar.bounds.height
        }
    }
     //MARK:-  Button Actions
    
    @IBAction func dashBoardIconPressed(_ sender: UIButton) {
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:- Search Bar Delegates
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            searchString = searchString.substring(to: searchString.index(searchString.endIndex, offsetBy: -1))
        }
        searchString += text
        
        let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchString)
        self.filteredArray = self.arrayMyCourses.filtered(using: predicate) as NSArray
        if searchString == "" {
            self.filteredArray = self.arrayMyCourses.mutableCopy() as! NSArray
        }
        self.tableView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if !OFAUtils.isWhiteSpace(searchBar.text!){
            let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchBar.text!)
            self.filteredArray = self.arrayMyCourses.filtered(using: predicate) as NSArray
        }else{
            self.loadMyCourses()
        }
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchBar.endEditing(true)
            self.filteredArray = self.arrayMyCourses.mutableCopy() as! NSArray
            searchString=""
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.filteredArray = self.arrayMyCourses.mutableCopy() as! NSArray
        searchString=""
        self.navigationItem.title = "My Courses"
//        self.navigationItem.rightBarButtonItem = nil
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchBarButtonPressed))
        self.tableView.reloadData()
    }
}
