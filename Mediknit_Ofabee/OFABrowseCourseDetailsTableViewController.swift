//
//  OFABrowseCourseDetailsTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import STRatingControl
import Alamofire
import AVFoundation
import AVKit

class OFABrowseCourseDetailsTableViewController: UITableViewController,CourseDetailsCurriculumDelegate,CourseDetailsReviewDelegate,CourseDetailsInstructorsDelegate {
    
    @IBOutlet var imageViewVideoPreview: UIImageView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewFooter: UIView!
    @IBOutlet var buttonPlay: UIButton!
    @IBOutlet var buttonFooterBuy: UIButton!
    @IBOutlet var labelFooterDiscountPrice: UILabel!
    @IBOutlet var labelFooterOriginalPrice: UILabel!
    
    var arraySections = NSMutableArray()
    var arrayLectures = NSMutableArray()
    var arrayReview = NSMutableArray()
    var arrayInstructors = NSMutableArray()
    var dicCourseDescription = NSDictionary()
    var tutorsName = ""
    
    var mAmount = ""
    var courseTitle = ""
    var courseId = ""
    var curriculumCount = 0
    var totalSectionCount = 0
    var isShowMorePressed = false
    var totalHeight:CGFloat = 0
    var wishListBarButton = UIBarButtonItem()
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    
    var arraySeperatorCells = [2,4,6,8]
    var isWishListSelected = false
    var isWishListVisible = true
    
    var isFree = false
    
    var cancelled: Bool = false
    
    //PayUMoney variables
    
//    var txnParam = PUMTxnParam()
    var merchantHash = ""
    var paymentTransactionID = ""
    var phoneNumber = ""
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCourseDetails()
//        self.getMerchantHash()
        
        if self.user_id != nil{
            if self.isWishListSelected{
                self.wishListBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "wishListSelected"), style: .plain, target: self, action: #selector(self.wishListClicked))
                self.navigationItem.rightBarButtonItem = self.wishListBarButton
            }else{
                self.wishListBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "wishListUnSelected"), style: .plain, target: self, action: #selector(self.wishListClicked))
                self.navigationItem.rightBarButtonItem = self.wishListBarButton
            }
            if isWishListVisible == false{
                self.navigationItem.rightBarButtonItem = nil
            }
            self.getTransactionIDFromServer()
        }
        self.navigationItem.rightBarButtonItem = nil
        self.buttonFooterBuy.layer.cornerRadius = self.buttonFooterBuy.frame.height/2
        self.buttonPlay.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = courseTitle
    }
    
    //MARK:- API Helpers
    
    func getTransactionIDFromServer(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.courseId,self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/get_hash", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if let dicBody = dicResult["body"] as? NSDictionary{
                    self.paymentTransactionID = "\(dicBody["txnid"]!)"
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithTitle("Warning", message: "Some error occured", cancelButtonTitle: "OK")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    @objc func wishListClicked(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        var status = 1
        
        if self.isWishListSelected{
            self.isWishListSelected = false
            status = 0
        }else{
            self.isWishListSelected = true
            status = 1
        }
        
        let dicParameters = NSDictionary(objects: [self.courseId,"\(status)",self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["course_id" as NSCopying,"status" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/add_remove_wishlist", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                if self.isWishListSelected{
                    self.wishListBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "wishListSelected"), style: .plain, target: self, action: #selector(self.wishListClicked))
                    self.navigationItem.rightBarButtonItem = self.wishListBarButton
                }else{
                    self.wishListBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "wishListUnSelected"), style: .plain, target: self, action: #selector(self.wishListClicked))
                    self.navigationItem.rightBarButtonItem = self.wishListBarButton
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func loadCourseDetails(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        var accessTokenParameter = ""
        if self.user_id == nil {
            accessTokenParameter = ""
        }else{
            accessTokenParameter = self.accessToken as! String
        }
        let dicParameters = NSDictionary(objects: [self.courseId,domainKey,accessTokenParameter], forKeys: ["course_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/course_description", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let dicCourses = dicBody["course"] as! NSDictionary
                self.dicCourseDescription = dicCourses
                if "\(self.dicCourseDescription["cb_promo"]!)" == "" {
                    self.buttonPlay.isHidden = true
                }
                self.populateDetailView()
                if let arrReviews = dicCourses["reviews"] as? NSArray{
                    self.arrayReview.removeAllObjects()
                    self.arrayReview = arrReviews.mutableCopy() as! NSMutableArray
                }
                if let arrTutors = dicCourses["course_tutors"] as? NSArray{
                    self.arrayInstructors.removeAllObjects()
                    self.arrayInstructors = arrTutors.mutableCopy() as! NSMutableArray
                }
                if let arrSections = dicCourses["sections"] as? NSArray{
                    self.arraySections.removeAllObjects()
                    self.arraySections = arrSections.mutableCopy() as! NSMutableArray
                }
                
                let courseDiscountPrice = "\(self.dicCourseDescription["cb_discount"]!)"
                let courseOriginalPrice = "\(self.dicCourseDescription["cb_price"]!)"
                
                if courseDiscountPrice != "<null>" || courseDiscountPrice != ""{
                    if courseDiscountPrice == "0"{
                        if courseOriginalPrice != "0"{
                            self.mAmount = courseOriginalPrice
                            self.labelFooterDiscountPrice.text = "RS. \(courseOriginalPrice)"
                            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "RS. \(courseDiscountPrice)")
                            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                            self.labelFooterOriginalPrice.attributedText = attributeString
                        }else{
                            self.labelFooterDiscountPrice.text = ""//"Free"
                            self.labelFooterOriginalPrice.text = ""
                            self.buttonFooterBuy.setTitle("Get", for: .normal)
                            self.isFree = true
                        }
                    }else{
                        if courseOriginalPrice != "0"{
                            self.mAmount = courseDiscountPrice
                            self.labelFooterDiscountPrice.text = courseDiscountPrice
                            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "RS. \(courseOriginalPrice)")
                            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                            self.labelFooterOriginalPrice.attributedText = attributeString
                        }else{
                            self.labelFooterDiscountPrice.text = ""//"Free"
                            self.labelFooterOriginalPrice.text = ""
                            self.buttonFooterBuy.setTitle("Get", for: .normal)
                            self.isFree = true
                        }
                    }
                }else{
                    if courseOriginalPrice != "0"{
                        self.mAmount = ""//courseOriginalPrice
                        self.labelFooterDiscountPrice.text = ""// "RS. \(courseOriginalPrice)"
                    }else{
                        self.labelFooterDiscountPrice.text = ""//"Free"
                        self.labelFooterOriginalPrice.text = ""
                        self.buttonFooterBuy.setTitle("Get", for: .normal)
                        self.isFree = true
                    }
                }
//                print("mAmount: = \(self.mAmount)")
                
                self.buttonPlay.isEnabled = true
                self.tableView.reloadData()
                OFAUtils.removeLoadingView(nil)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    func populateDetailView(){
        self.imageViewVideoPreview.sd_setImage(with: URL(string: "\(self.dicCourseDescription["cb_image"]!)"), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
    }
    
    //MARK:- Button Actions
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if "\(self.dicCourseDescription["cb_promo"]!)" == "" {
            OFAUtils.showToastWithTitle("No Video")//,opening imageViewer")
            return
        }
        let youtubePlayerVC = self.storyboard?.instantiateViewController(withIdentifier: "YoutubePlayerVC") as! OFAYoutubeVideoViewController
        self.navigationItem.title = ""
        youtubePlayerVC.isBrowseCourse = true
        youtubePlayerVC.videoURL = "\(self.dicCourseDescription["cb_promo"]!)".youtubeID!
        //        self.navigationController?.pushViewController(youtubePlayerVC, animated: true)
        self.present(youtubePlayerVC, animated: true, completion: nil)
    }
    
    @IBAction func buyNowPressed(_ sender: UIButton) {
        print("is the course free : \(isFree)")
        if self.user_id != nil {
            if self.isFree{
                self.subscribeToFreeCourse()
            }else{
                
                PlugNPlay.setTopBarColor(OFAUtils.getColorFromHexString(barTintColor))
                PlugNPlay.setButtonTextColor(UIColor.white)
                PlugNPlay.setButtonColor(OFAUtils.getColorFromHexString(ofabeeGreenColorCode))
                PlugNPlay.setTopTitleTextColor(UIColor.white)
                PlugNPlay.setIndicatorTintColor(.white)
                
                let user = OFASingletonUser.ofabeeUser
                if user.user_phone! != "0" {
                    phoneNumber = user.user_phone!
                    let txnParam = self.getParams()
                    PlugNPlay.presentPaymentViewController(withTxnParams: txnParam, on: self) { (paymentResponse, error, extraParam) in
                        if (error == nil){
                            print(paymentResponse!)
                            self.subscribeToPaidCourse()
                        }else{
                            OFAUtils.showToastWithTitle((error?.localizedDescription)!)
                        }
                    }
                }else{
                    let alertController = UIAlertController(title: "Phone number missing", message: "Add your number for payment to proceed", preferredStyle: .alert)
                    
                    let saveAction = UIAlertAction(title: "Continue", style: .default, handler: {
                        alert -> Void in
                        let firstTextField = alertController.textFields![0] as UITextField
                        if firstTextField.text! != "0" || firstTextField.text! != "" || !OFAUtils.isWhiteSpace(firstTextField.text!){
                            self.phoneNumber = firstTextField.text!
                            let txnParam = self.getParams()
                            PlugNPlay.presentPaymentViewController(withTxnParams: txnParam, on: self) { (paymentResponse, error, extraParam) in
                                if (error == nil){
                                    print(paymentResponse!)
                                    self.subscribeToPaidCourse()
                                }else{
                                    OFAUtils.showToastWithTitle((error?.localizedDescription)!)
                                }
                            }
                        }else{
                            OFAUtils.showToastWithTitle("Enter a valid phone number")
                        }
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                        (action : UIAlertAction!) -> Void in
                    })
                    
                    alertController.addTextField { (textField : UITextField!) -> Void in
                        textField.placeholder = "Phone Number"
                    }
                    
                    alertController.addAction(saveAction)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }else{
            OFAUtils.showToastWithTitle("Login to get the course")
            let domainView = self.storyboard?.instantiateViewController(withIdentifier: "LoginTVC") as! OFALoginTableTableViewController
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(domainView, animated: true)
        }
    }
    
    func subscribeToFreeCourse(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.courseId,self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/subscribe_free_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                self.navigationController?.popViewController(animated: true)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func subscribeToPaidCourse(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.courseId,self.mAmount,self.user_id as! String,domainKey,self.accessToken as! String], forKeys: ["course_id" as NSCopying,"course_amount" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/save_payment_details", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dicCourseDescription.count <= 0 {
            return 0
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailsDetail", for: indexPath) as! OFACourseDetailsDetailTableViewCell
            cell.customizeCourseDetailsCell(courseTitle: "\(self.dicCourseDescription["cb_title"]!)", authors: self.tutorsName, ratingValue: "\(self.dicCourseDescription["rating"]!)", reviewCount: "\(self.dicCourseDescription["review_count"]!)", studentsEnrolled: "\(self.dicCourseDescription["subscriptions"]!)")
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailsPayment", for: indexPath) as! OFACourseDetailsPaymentTableViewCell
            cell.customizePaymentDetails(discountPrice: "\(self.dicCourseDescription["cb_discount"]!)", originalPrice: "\(self.dicCourseDescription["cb_price"]!)")
            return cell
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailsDescription", for: indexPath) as! OFACourseDetailsDescriptionTableViewCell
            //            self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
            cell.textViewDescription.isScrollEnabled = false
            cell.textViewDescription.adjustsFontForContentSizeCategory = true
            do {
                let attrStr = try NSAttributedString(data: "\(self.dicCourseDescription["cb_description"]!)".data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                                                     options: [ NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html],
                                                     documentAttributes: nil)
                cell.textViewDescription.text = attrStr.string
            }catch{
                cell.textViewDescription.text = "(No Description)"
            }
            return cell
        }
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailsCurriculum", for: indexPath) as! OFACourseDetailsCurriculumTableViewCell
            cell.delegate = self
            cell.arraySections = self.arraySections
            return cell
        }
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailsReview", for: indexPath) as! OFACourseDetailsReviewTableViewCell
            cell.delegate=self
            cell.arrayReviews = self.arrayReview
            cell.labelReviewCount.text = "\(self.dicCourseDescription["review_count"]!) Reviews"
            let rating = "\(self.dicCourseDescription["rating"]!)".components(separatedBy: ".")[0]
            cell.starRatingView.rating = Int(rating)!
            cell.labelTotalRating.text = "\(self.dicCourseDescription["rating"]!)"
            
            cell.totalReviewCount = Int("\(self.dicCourseDescription["review_count"]!)")!
            cell.courseId = self.courseId
            return cell
        }
        if indexPath.row == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailsInstructors", for: indexPath) as! OFACourseDetailsInstructorsTableViewCell
            cell.delegate=self
            cell.arrayInstructors = self.arrayInstructors
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableViewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableViewFooter
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0//202
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 131
        }
        if indexPath.row == 1 {
            return 65
        }
        if indexPath.row == 3 {
            self.tableView.estimatedRowHeight = 168
            self.tableView.rowHeight = UITableView.automaticDimension
            return self.tableView.rowHeight//170+53
        }
        if indexPath.row == 5 {
            if isShowMorePressed == false{
                return self.totalHeight
            }else{
                return self.totalHeight
            }
        }
        if indexPath.row == 7 {
            return (CGFloat(self.arrayReview.count) * 118)+138+60
        }
        if indexPath.row == 9 {
            return (CGFloat(self.arrayInstructors.count) * 90)+60
        }
        if self.arraySeperatorCells.contains(indexPath.row){
            return 20
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.arraySeperatorCells.contains(indexPath.row){
            cell.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
        }
    }
    
    //MARK:- PayUMoney Payment Gateway Helpers
    
    func getParams()->PUMTxnParam{
        let user = OFASingletonUser.ofabeeUser
        let txnParam = PUMTxnParam()

        txnParam.phone = self.phoneNumber
        txnParam.email = user.user_email!
        txnParam.amount = self.mAmount
        txnParam.environment = PUMEnvironment.production
        txnParam.firstname = user.user_name!
        txnParam.key = PayUMoneyMerchantKey
        txnParam.merchantid = PayUMoneyMerchantID
        txnParam.txnID = self.paymentTransactionID
        txnParam.surl = "https://www.payumoney.com/mobileapp/payumoney/success.php"
        txnParam.furl = "https://www.payumoney.com/mobileapp/payumoney/failure.php"
        txnParam.productInfo = self.courseTitle
        txnParam.udf1 = "asd"
        txnParam.udf2 = "as"
        txnParam.udf3 = ""
        txnParam.udf4 = ""
        txnParam.udf5 = ""
        txnParam.udf6 = ""
        txnParam.udf7 = ""
        txnParam.udf8 = ""
        txnParam.udf9 = ""
        txnParam.udf10 = ""

        txnParam.hashValue = self.getHashForPayment(txnParams: txnParam)
        
        return txnParam
    }
    
    func getHashForPayment(txnParams:PUMTxnParam)->String{
        let hashSequence = "\(txnParams.key!)|\(txnParams.txnID!)|\(txnParams.amount!)|\(txnParams.productInfo!)|\(txnParams.firstname!)|\(txnParams.email!)|\(txnParams.udf1!)|\(txnParams.udf2!)|\(txnParams.udf3!)|\(txnParams.udf4!)|\(txnParams.udf5!)|\(txnParams.udf6!)|\(txnParams.udf7!)|\(txnParams.udf8!)|\(txnParams.udf9!)|\(txnParams.udf10!)|\(PayUMoneyMerchantSalt)"
        let hash = hashSequence.sha512()
        return hash
    }
    
    //MARK:- CourseDetailsCurriculum Delegate
    
    func totalHeightForTableView(height: CGFloat) {
        //        self.isShowMorePressed = true
        self.totalHeight = height
        self.tableView.reloadData()
    }
    
    func updateRowHeightForCurriculum(with array: NSMutableArray, count: Int) {
        self.curriculumCount = count
        self.tableView.reloadData()
    }
    
    //MARK:- CourseDetailsReview Delegate
    
    func updateRowHeightForReview(with array: NSMutableArray) {
        self.arrayReview = array
        self.tableView.reloadData()
    }
    
    //MARK:- CourseDetailsInstructors Delegate
    
    func updateRowHeightForInstructors(with array: NSMutableArray) {
        
    }
}

extension String {
    
    func sha512() -> String {
        let data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes({
            _ = CC_SHA512($0, CC_LONG(data.count), &digest)
        })
        return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
    
}
