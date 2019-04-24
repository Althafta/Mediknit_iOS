//
//  OFADashboardTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 01/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFADashboardTableViewController: UITableViewController,OtherCourseTableViewCellDelegate,MyCourseDashboardListDelegate {

    var arrayContentTitles = NSMutableArray()
    @IBOutlet weak var viewHeading: UIView!
    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var buttonMyCourse: UIButton!
    @IBOutlet weak var buttonMyProfile: UIButton!
//    @IBOutlet weak var buttonLogout: UIButton!
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.tableView.backgroundColor = UIColor.white
        
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
        
        let labelTitle = UILabel()
        labelTitle.text = "Mediknit"
//        labelTitle.font = UIFont(name: "Open Sans-Bold", size: 17)
        labelTitle.textColor = OFAUtils.getColorFromHexString(barTintColor)
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: UIImageView(image: UIImage(named: "DashboardIcon"))),UIBarButtonItem(customView: labelTitle)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logout"), style: .plain, target: self, action: #selector(self.logoutPressed))
        
        self.customAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationItem.title = "MEDIKNIT"
        self.refreshInitiated()
    }
    
    func customAppearance(){
        self.buttonHome.layer.cornerRadius = self.buttonHome.frame.height/2
        self.buttonMyCourse.layer.cornerRadius = self.buttonMyCourse.frame.height/2
        self.buttonMyProfile.layer.cornerRadius = self.buttonMyProfile.frame.height/2
//        self.buttonLogout.layer.cornerRadius = self.buttonLogout.frame.height/2
        
        self.buttonHome.dropShadow()
        self.buttonMyProfile.dropShadow()
        self.buttonMyCourse.dropShadow()
//        self.buttonLogout.dropShadow()
        self.viewHeading.dropShadow()
    }
    
    @objc func refreshInitiated(){
        self.loadDashboardContents()
    }
    
    func loadDashboardContents(){
        var arrayCourses = NSArray()
        if let dataSubscribedCourses = UserDefaults.standard.value(forKey: Subscribed_Courses) as? Data{
            arrayCourses = NSKeyedUnarchiver.unarchiveObject(with: dataSubscribedCourses) as! NSArray
        }
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,arrayCourses], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"courses" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/dashboard_content", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResponse = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                self.refreshController.endRefreshing()
                if responseJSON.response?.statusCode == 203{
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResponse["body"] as! NSDictionary
                let arrayTitles = dicBody["title"] as! NSArray
                for item in arrayTitles{
                    let dicTitle = item as! NSDictionary
                    if !self.arrayContentTitles.contains(dicTitle){
                        self.arrayContentTitles.add(dicTitle)
                    }
                }
                self.tableView.reloadData()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("Dashboard content loading failed")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayContentTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dicTitleDetails = self.arrayContentTitles[indexPath.row] as! NSDictionary
        if "\(dicTitleDetails["type"]!)" == "1"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTVCell", for: indexPath) as! OFADashboardTableViewCell
            cell.delegate = self
            cell.customizeCellWithDetails(sectionTitle: "My Course", identifier: "\(dicTitleDetails["identifier"]!)")
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardOtherCoursesTVCell", for: indexPath) as! OFADashboardOtherCoursesTableViewCell
            cell.delegate = self
            cell.customizeCellWithDetails(sectionTitle: "\(dicTitleDetails["name"]!)", identifier: "\(dicTitleDetails["identifier"]!)")
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 420
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.dropShadow()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewHeading
    }
    
    //MARK:- MyCourse selection delegate
    
    func pushToCourseDetails(dicDetails:NSDictionary) {
        let myCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseDetailsVC") as! OFAMyCourseDetailsViewController
        self.navigationItem.title = ""
        
        myCourseDetails.courseTitle = "\(dicDetails["cb_title"]!)"
        myCourseDetails.promoImageURLString = "\(dicDetails["cb_image"]!)"
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
    //MARK:- Button Action Delegate
    
    func pushToWebViewController(redirectURL: String, titleString: String){
        let webView = self.storyboard?.instantiateViewController(withIdentifier: "DashboardWebView") as! OFAWebViewDashboardViewController
        webView.urlString = redirectURL
        webView.titleString = titleString
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    //MARK:- Button Actions
    
    @IBAction func homePressed(_ sender: Any) {
        self.refreshInitiated()
    }
    //["DashboardTVC","MyCourseTVC","ProfileTVC",""]
    @IBAction func myCoursePressed(_ sender: UIButton) {
        let myCourseList = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseTVC") as! OFAMyCourseTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(myCourseList, animated: true)
    }
    
    @IBAction func myProfilePressed(_ sender: UIButton) {
        let myProfile = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTVC") as! OFAMyProfileTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(myProfile, animated: true)
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
}
