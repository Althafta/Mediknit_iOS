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
    var arrayMyCourses = NSMutableArray()
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    
    var refreshController = UIRefreshControl()
    var searchBarButtonItem = UIBarButtonItem()
    
    var searchString = ""
    var filteredArray = NSArray()
    
    //MARK:- Life Cycle
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.setNavigationBarItem()
        
//        self.tableView.contentOffset = CGPoint(x: 0, y: self.searchBar.bounds.height)
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)//.white
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
//        self.tableView.refreshControl = self.refreshController
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        self.headerView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchBarButtonPressed))
//        self.refreshInitiated()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshInitiated()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if #available(iOS 11.0, *) {
//            self.navigationController?.navigationBar.prefersLargeTitles = false
//        } else {
//            // Fallback on earlier versions
//        }
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.navigationItem.title = "My Courses"
//    }
//    
    func searchBarButtonPressed(){
        
    }
    
    @objc func refreshInitiated(){
        self.loadMyCourses()
    }
    
    func loadMyCourses(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        //        if self.user_id == nil {
//                    let browseCourse = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseTVC") as!OFABrowseCourseTableViewController
//                    self.navigationController?.pushViewController(browseCourse, animated: true)
        //        }else{
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/mycourse", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        self.refreshController.endRefreshing()
                        sessionAlert.dismiss(animated: true, completion: nil)
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
                    }else{
                        let emptyAlert = UIAlertController(title: "Get Courses", message: "Get some courses to get trained on", preferredStyle: .alert)
                        emptyAlert.addAction(UIAlertAction(title: "Get", style: .default, handler: { (alertAction) in
                            let browseCourse = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseTVC") as!OFABrowseCourseTableViewController
                            browseCourse.isPushedView = true
                            self.navigationController?.children[0].navigationItem.title = ""
                            self.navigationController?.pushViewController(browseCourse, animated: true)
                        }))
                        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                            
                        }))
                        self.present(emptyAlert, animated: true, completion: nil)
                    }
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
        let descriptionString = "Lecture \(dicDetails["total_lectures"]!)"
        cell.customizeCellWithDetails(courseTitle: "\(dicDetails["cb_title"]!)", courseImageURL: "\(dicDetails["cb_image"]!)", courseDescription: descriptionString, percentage: "\(dicDetails["percentage"]!)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseDetailsVC") as! OFAMyCourseDetailsViewController
        self.navigationItem.title = ""
        let dicDetails = self.filteredArray[indexPath.row] as! NSDictionary
        myCourseDetails.courseTitle = "\(dicDetails["cb_title"]!)"
        COURSE_ID = "\(dicDetails["id"]!)"
        
        if "\(dicDetails["cs_approved"]!)" == "0" {
            let sessionAlert = UIAlertController(title: "Course not approved", message: nil, preferredStyle: .alert)
            sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                sessionAlert.dismiss(animated: true, completion: nil)
            }))
            self.present(sessionAlert, animated: true, completion: nil)
            return
        }
        
        self.navigationController?.pushViewController(myCourseDetails, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
        let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchBar.text!)
        self.filteredArray = self.arrayMyCourses.filtered(using: predicate) as NSArray
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
