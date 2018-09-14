//
//  OFAWishListTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAWishListTableViewController: UITableViewController,UISearchBarDelegate {

    var arrayWishList = NSMutableArray()
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    var index = 0
    var offset = 1
    var refreshController = UIRefreshControl()
    @IBOutlet var searchBarWishList: UISearchBar!
    
    var searchString = ""
    var filteredArray = NSMutableArray()
    
    var assignedTutors = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
        self.refreshController.tintColor = .white//OFAUtils.getColorFromHexString(barTintColor)
        self.tableView.refreshControl = self.refreshController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Wish List"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        self.refreshInitiated()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    func refreshInitiated(){
        index = 0
        self.offset=1
        self.arrayWishList.removeAllObjects()
        self.filteredArray.removeAllObjects()
        self.loadWishList(with: self.user_id as! String, limit: "10", offset: 1, token: self.accessToken)

    }
    func loadWishList(with userID:String,limit:String,offset:Int,token:String){
        if(index-1 >= self.filteredArray.count ){
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameteres = NSDictionary(objects: [userID,offset,limit,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"offset" as NSCopying,"limit" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/my_wishlist", method: .post, parameters: dicParameteres as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let arrCourses = dicBody["wishlist_courses"] as! NSArray
                if arrCourses.count > 0 {
                    //                    self.arrayCourses.removeAllObjects()
                    for item in arrCourses{
                        let dicCourseDetails = item as! NSDictionary
                        self.arrayWishList.add(dicCourseDetails)
                    }
                    self.filteredArray = self.arrayWishList//.mutableCopy() as! NSArray
                    self.refreshController.endRefreshing()
                    self.tableView.reloadData()
                }else{
                    //                    self.arrayCourses.removeAllObjects()
                    //                    OFAUtils.showToastWithTitle("Empty Courses")
                }
                self.refreshController.endRefreshing()
                self.tableView.reloadData()
            }else{
                self.refreshController.endRefreshing()
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.filteredArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishListCell", for: indexPath) as! OFAWishListTableViewCell
        self.assignedTutors.removeAll()
        let dicCourseDetails = self.filteredArray[indexPath.row] as! NSDictionary
        if let arrayAssignedTutors = dicCourseDetails["assigned_tutors"] as? NSArray{
            for item in arrayAssignedTutors{
                let dicData = item as! NSDictionary
                assignedTutors.append("\(dicData["us_name"]!)")
            }
        }
        cell.customizeCellWithDetails(imageURL: "\(dicCourseDetails["cb_image"]!)", courseTitle: "\(dicCourseDetails["cb_title"]!)", courseAuthors: assignedTutors.joined(separator: ", "), coursePrice: "\(dicCourseDetails["cb_price"]!)", courseDiscountPrice: "\(dicCourseDetails["cb_discount"]!)", ratingValue: "\(dicCourseDetails["rating"]!)")
        cell.buttonWishlist.isSelected = true
        cell.buttonWishlist.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! OFAWishListTableViewCell
        let browseCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseDetailsTVC") as! OFABrowseCourseDetailsTableViewController
        self.navigationItem.title = ""
        let dicCourseDetails = self.filteredArray[indexPath.row] as! NSDictionary
        browseCourseDetails.courseTitle = "\(dicCourseDetails["cb_title"]!)"
        browseCourseDetails.courseId = "\(dicCourseDetails["cw_course_id"]!)"
        browseCourseDetails.tutorsName = cell.labelCourseAuthors.text!
        browseCourseDetails.isWishListSelected = true
        self.navigationController?.pushViewController(browseCourseDetails, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row  == self.filteredArray.count-1 {
            self.index = index + 10
            print("New data loaded")
            self.offset += 1
            self.loadWishList(with: self.user_id as! String, limit: "10", offset: Int(self.offset), token: self.accessToken)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if OFAUtils.isiPhone(){
            return 370
        }else{
            return 500
        }
    }

    //MARK:- Button Actions
    
    @IBAction func wishListPressed(_ sender: UIButton) {
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicCourseDetails = self.filteredArray[sender.tag] as! NSDictionary
        let dicParameters = NSDictionary(objects: ["\(dicCourseDetails["cw_course_id"]!)","0",self.user_id as! String,domainKey,self.accessToken], forKeys: ["course_id" as NSCopying,"status" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/add_remove_wishlist", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                self.filteredArray.removeObject(at: sender.tag)
                self.tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
//                self.tableView.reloadData()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Search Bar Delegates
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            searchString = searchString.substring(to: searchString.index(searchString.endIndex, offsetBy: -1))
        }
        searchString += text
        
        let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchString)
        self.filteredArray = (self.arrayWishList.filtered(using: predicate) as NSArray).mutableCopy() as! NSMutableArray
        if searchString == "" {
            self.filteredArray = self.arrayWishList//.mutableCopy() as! NSMutableArray
        }
        self.tableView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchBar.text!)
        self.filteredArray = (self.arrayWishList.filtered(using: predicate) as NSArray).mutableCopy() as! NSMutableArray
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchBar.endEditing(true)
            self.filteredArray = self.arrayWishList//.mutableCopy() as! NSMutableArray
            searchString=""
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.filteredArray = self.arrayWishList//.mutableCopy() as! NSMutableArray
        searchString=""
        self.tableView.reloadData()
    }

 }
