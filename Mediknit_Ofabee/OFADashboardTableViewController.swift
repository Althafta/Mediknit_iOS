//
//  OFADashboardTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 01/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFADashboardTableViewController: UITableViewController,OtherCourseTableViewCellDelegate {

    var arrayContentTitles = NSMutableArray()
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.tableView.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Dashboard"
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayContentTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dicTitleDetails = self.arrayContentTitles[indexPath.row] as! NSDictionary
        if "\(dicTitleDetails["type"]!)" == "1"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTVCell", for: indexPath) as! OFADashboardTableViewCell
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
    
    //MARK:-Button Action Delegate
    
    func pushToWebViewController(redirectURL: String, titleString: String){
        let webView = self.storyboard?.instantiateViewController(withIdentifier: "DashboardWebView") as! OFAWebViewDashboardViewController
        webView.urlString = redirectURL
        webView.titleString = titleString
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
}
