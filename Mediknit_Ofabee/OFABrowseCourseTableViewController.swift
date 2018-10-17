//
//  OFABrowseCourseTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import YNDropDownMenu
import DropDown

class OFABrowseCourseTableViewController: UITableViewController,UISearchBarDelegate,HADropDownDelegate {
    
    @IBOutlet var tableViewHeaderView: UIView!
    @IBOutlet var tableViewFooterView: UIView!
    @IBOutlet var viewDropDown: HADropDown!
//    @IBOutlet var tableViewHeader: UIView!
    
    @IBOutlet var buttonCategory: UIButton!
    @IBOutlet var buttonSignIn: UIButton!
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    var refreshController = UIRefreshControl()
    var arrayCourses = NSMutableArray()
    var arrayCategories = NSMutableArray()
    
    var offset = 1
    var selectedCategoryId = ""
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    var searchString = ""
    var filteredArray = NSArray()
    
    @IBOutlet var searchBarBrowseCourse: UISearchBar!
//    @IBOutlet var viewSearchBar: UIView!
    
    var index = 0
    var assignedTutors = [String]()
    var isPushedView = false
    
    let chooseCategoryDropDown = DropDown()
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonSignIn.layer.cornerRadius = self.buttonSignIn.frame.height/2
        
        self.searchBarBrowseCourse.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.redirectToSafari))
        self.view.layoutIfNeeded()
        self.viewDropDown.layer.borderColor = UIColor.green.cgColor
        self.viewDropDown.layer.borderWidth = 0
        self.viewDropDown.delegate = self
        //        self.viewDropDown.textAllignment = .left
        
        //        CGFloat spacing = 10; // the amount of spacing to appear between image and title
        //        tabBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
        //        tabBtn.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        
        self.buttonCategory.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: self.tableViewHeaderView.frame.width-76, bottom: 0, right: 0)
        
        self.refreshInitiated()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Get Courses"
        
        if self.user_id != nil {
            if self.isPushedView{
                
            }else{
                self.setNavigationBarItem(isSidemenuEnabled: true)
            }
        }
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        self.tableView.reloadData()
    }
    
    func blur(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = (rootView?.bounds)!
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        rootView?.addSubview(blurEffectView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.touchesView))
        singleTap.numberOfTapsRequired = 1
        self.blurEffectView.addGestureRecognizer(singleTap)
    }
    
    @objc func touchesView(){//tapAction
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if touches.first != nil{
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    func searchBarButtonPressed(){
//        didHide(dropDown: self.viewDropDown)
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
//        let rightNavBarButton = UIBarButtonItem(customView:self.viewSearchBar)
//        self.navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    func donePressed(){
        self.view.endEditing(true)
        self.navigationItem.title = "Browse Courses"
//        self.navigationItem.rightBarButtonItem = nil
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchBarButtonPressed))
        self.setNavigationBarItem(isSidemenuEnabled: true)
    }
    
    @objc func refreshInitiated(){
        index = 0
        self.offset=1
        
//        self.viewDropDown.title = "Select a Category"
        self.buttonCategory.setTitle("Select a Category", for: .normal)
        
        self.arrayCourses.removeAllObjects()
        if self.user_id == nil {
            self.loadCourses(with: "", userID: "", limit: "10", offset: 1, token: "")
        }else{
            self.loadCourses(with: "", userID: self.user_id as! String, limit: "10", offset: 1, token: self.accessToken as! String)
        }
    }

    func loadCourses(with categoryId:String,userID:String,limit:String,offset:Int,token:String){
        if(index-1 >= self.filteredArray.count ){
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [categoryId,userID,limit,"\(offset)",domainKey,token], forKeys: ["category_id" as NSCopying,"user_id" as NSCopying,"limit" as NSCopying,"offset" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/browse_course", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                if let arrCategories = dicBody["categories"] as? NSArray{
                    if arrCategories.count > 0 {
                        self.arrayCategories.removeAllObjects()
                        var arrayCategoryTitles = [String]()
                        for item in arrCategories{
                            let dicCategoryDetails = item as! NSDictionary
                            self.arrayCategories.add(dicCategoryDetails)
                            arrayCategoryTitles.append("\(dicCategoryDetails["ct_name"]!)")
                        }
//                        self.viewDropDown.items = arrayCategoryTitles
                        self.chooseCategoryDropDown.anchorView = self.buttonCategory
                        self.chooseCategoryDropDown.bottomOffset = CGPoint(x: 0, y: self.buttonCategory.bounds.height)
                        self.chooseCategoryDropDown.dataSource = arrayCategoryTitles
                        self.chooseCategoryDropDown.selectionAction = { [weak self] (index, item) in
                            
                            let dicCategory = self?.arrayCategories[index] as! NSDictionary
                            self?.selectedCategoryId = "\(dicCategory["id"]!)"
//                            self?.viewDropDown.title = "\(dicCategory["ct_name"]!)"
                            self?.buttonCategory.setTitle("\(dicCategory["ct_name"]!)", for: .normal)
                            self?.arrayCourses.removeAllObjects()
                            self?.tableView.reloadData()
                            self?.index = (self?.arrayCourses.count)!-1
                            if self?.user_id == nil{
                                self?.loadCourses(with: (self?.selectedCategoryId)!, userID: "", limit: "10", offset: 1, token: "")
                            }else{
                                self?.loadCourses(with: (self?.selectedCategoryId)!, userID: self?.user_id as! String, limit: "10", offset: 1, token: self?.accessToken as! String)
                            }
                        }
                    }else{
//                        OFAUtils.showToastWithTitle("Empty Categories")
                    }
                }
                
                let arrCourses = dicBody["categories_courses"] as! NSArray
                if arrCourses.count > 0 {
                    self.arrayCourses.removeAllObjects()
                    for item in arrCourses{
                        let dicCourseDetails = item as! NSDictionary
                        if "\(dicCourseDetails["cb_price"]!)" == "0"{
                            self.arrayCourses.add(dicCourseDetails)
                        }
                    }
                    self.filteredArray = self.arrayCourses.mutableCopy() as! NSArray
                    self.refreshController.endRefreshing()
                    self.tableView.reloadData()
                }else{
                    self.arrayCourses.removeAllObjects()
                    self.tableView.reloadData()
                    OFAUtils.showToastWithTitle("Empty Courses")
                }
            }else{
                self.refreshController.endRefreshing()
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        let appearance = chooseCategoryDropDown
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        //        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 10
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseCourseCell", for: indexPath) as! OFABrowserCourseTableViewCell
        
        let dicCourseDetails = self.filteredArray[indexPath.row] as! NSDictionary
        self.assignedTutors.removeAll()
        if let arrayAssignedTutors = dicCourseDetails["assigned_tutors"] as? NSArray{
            for item in arrayAssignedTutors{
                let dicData = item as! NSDictionary
                assignedTutors.append("\(dicData["us_name"]!)")
            }
        }
        cell.customizeCellWithDetails(imageURL: "\(dicCourseDetails["cb_image"]!)", courseTitle: "\(dicCourseDetails["cb_title"]!)", courseAuthors: self.assignedTutors.joined(separator: ", "), coursePrice: "\(dicCourseDetails["cb_price"]!)", courseDiscountPrice: "\(dicCourseDetails["cb_discount"]!)", ratingValue: "\(dicCourseDetails["rating"]!)")
        if "\(dicCourseDetails["wishlist_status"]!)" == "1"{
            cell.buttonWishlist.isSelected = true
        }else if "\(dicCourseDetails["wishlist_status"]!)" == "0"{
            cell.buttonWishlist.isSelected = false
        }else if "\(dicCourseDetails["wishlist_status"]!)" == "2"{
            cell.buttonWishlist.isHidden = true
        }
        cell.buttonWishlist.isHidden = true
        if self.user_id == nil {
            cell.buttonWishlist.isHidden = true
        }
        cell.buttonWishlist.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewDropDown.isCollapsed = true
        viewDropDown.collapseTableView()
        let cell = self.tableView.cellForRow(at: indexPath) as! OFABrowserCourseTableViewCell
        let dicCourseDetails = self.filteredArray[indexPath.row] as! NSDictionary
        if "\(dicCourseDetails["is_subscribed"]!)" == "1"{
            let myCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseDetailsVC") as! OFAMyCourseDetailsViewController
            self.navigationItem.title = ""
            myCourseDetails.courseTitle = "\(dicCourseDetails["cb_title"]!)"
            COURSE_ID = "\(dicCourseDetails["id"]!)"
            self.navigationController?.pushViewController(myCourseDetails, animated: true)
        }else{
            let browseCourseDetails = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseDetailsTVC") as! OFABrowseCourseDetailsTableViewController
            self.navigationItem.title = ""
            
            browseCourseDetails.courseTitle = "\(dicCourseDetails["cb_title"]!)"
            browseCourseDetails.courseId = "\(dicCourseDetails["id"]!)"
            browseCourseDetails.tutorsName = cell.labelCourseAuthors.text!
            if "\(dicCourseDetails["wishlist_status"]!)" == "1"{
                browseCourseDetails.isWishListSelected = true
            }else if "\(dicCourseDetails["wishlist_status"]!)" == "2"{
                browseCourseDetails.isWishListVisible = false
            }else{
                browseCourseDetails.isWishListSelected = false
            }
            self.navigationController?.pushViewController(browseCourseDetails, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        viewDropDown.isCollapsed = true
        viewDropDown.collapseTableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if OFAUtils.isiPhone(){
            return 370
        }else{
            return 500
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableViewFooterView
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableViewHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 116
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.user_id == nil {
            return 54
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        if indexPath.row  == self.filteredArray.count-1 {
            self.index = index + 10
            self.offset += 1
            if self.user_id == nil {
                self.loadCourses(with: "", userID: "", limit: "10", offset: Int(self.offset), token: "")
            }else{
                self.loadCourses(with: "", userID: self.user_id as! String, limit: "10", offset: Int(self.offset), token: self.accessToken as! String)
            }
        }
    }
    
    //MARK:- Button Actions
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    @IBAction func buttonChooseCategory(_ sender: UIButton) {
        self.customizeDropDown(self)
        self.chooseCategoryDropDown.show()
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.initializeLoginPage()
    }
    
    @IBAction func wishListCourseSelected(_ sender: UIButton) {
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        var status = 1
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! OFABrowserCourseTableViewCell
        if sender.isSelected{
            cell.buttonWishlist.isSelected=false
            status = 0
        }else{
            cell.buttonWishlist.isSelected=true
            status = 1
        }
        let dicCourseDetails = self.filteredArray[sender.tag] as! NSDictionary
        let dicParameters = NSDictionary(objects: ["\(dicCourseDetails["id"]!)","\(status)",self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["course_id" as NSCopying,"status" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/add_remove_wishlist", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- DropDown Delegates
    
    func didSelectItem(dropDown: HADropDown, at index: Int) {
        let dicCategory = self.arrayCategories[index] as! NSDictionary
        self.selectedCategoryId = "\(dicCategory["id"]!)"
        self.viewDropDown.title = "\(dicCategory["ct_name"]!)"
        self.arrayCourses.removeAllObjects()
        self.tableView.reloadData()
        self.index = self.arrayCourses.count-1
        if self.user_id == nil{
            self.loadCourses(with: self.selectedCategoryId, userID: "", limit: "10", offset: 1, token: "")
        }else{
            self.loadCourses(with: self.selectedCategoryId, userID: self.user_id as! String, limit: "10", offset: 1, token: self.accessToken as! String)
        }
    }
    
    //MARK:- Search Bar Delegates
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            searchString = searchString.substring(to: searchString.index(searchString.endIndex, offsetBy: -1))
        }
        searchString += text
        
        let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchString)
        self.filteredArray = self.arrayCourses.filtered(using: predicate) as NSArray
        if searchString == "" {
            self.filteredArray = self.arrayCourses.mutableCopy() as! NSArray
        }
        self.tableView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let predicate = NSPredicate(format: "cb_title CONTAINS[c] %@",searchBar.text!)
        self.filteredArray = self.arrayCourses.filtered(using: predicate) as NSArray
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchBar.endEditing(true)
            self.filteredArray = self.arrayCourses.mutableCopy() as! NSArray
            searchString=""
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.filteredArray = self.arrayCourses.mutableCopy() as! NSArray
        searchString=""
        self.navigationItem.title = "Browse Courses"
//        self.navigationItem.rightBarButtonItem = nil
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchBarButtonPressed))
        self.tableView.reloadData()
    }
}
