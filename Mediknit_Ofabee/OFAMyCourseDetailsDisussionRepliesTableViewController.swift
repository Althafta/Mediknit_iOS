//
//  OFAMyCourseDetailsDisussionRepliesTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/18/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAMyCourseDetailsDisussionRepliesTableViewController: UITableViewController,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelCommentOwner: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var textViewQuestion: UITextView!
    @IBOutlet var textReply: UITextField!
    @IBOutlet var viewFooter: UIView!
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var viewTextFieldPadding: UIView!
    @IBOutlet var buttonOptions: UIButton!
    @IBOutlet var buttonSendReply: UIButton!
    
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewFooter: UIView!
    
    @IBOutlet var textViewEnterReason: UITextView!
    @IBOutlet var buttonReport: UIButton!
    @IBOutlet var buttonCancel: UIButton!
    
    @IBOutlet var viewReportPopup: UIView!
    
    var report_id = ""
    var report_api = ""
    
    var discussion_id = ""
    var offset = 1
    var index = 0
    var arrayReplies = NSMutableArray()
    var dicQuestionDetails = NSDictionary()
    var dateString = ""
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let access_token = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    var isQuestion = false
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewHeader.dropShadow()
        self.viewFooter.dropShadow()
        self.textReply.dropShadow()
        self.viewTextFieldPadding.dropShadow()
        
        self.textViewEnterReason.dropShadow()
        
        let stringVar = String()
//        let fontVar = UIFont(fa_fontSize: 15)
        let fontVar = UIFont.fa?.fontSize(15)
        let faType = stringVar.fa.fontAwesome(.fa_ellipsis_v)
        self.buttonOptions.titleLabel?.font = fontVar
        self.buttonOptions.setTitle(faType, for: .normal)
        self.buttonOptions.isHidden = true
        
        self.buttonSendReply.clipsToBounds = true
        self.buttonSendReply.layer.cornerRadius = self.buttonSendReply.frame.width/2
        
        self.imageViewUser.clipsToBounds = true
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.width/2
        
        self.imageViewUser.setImageWith("\(self.dicQuestionDetails["username"]!)", color: OFAUtils.getRandomColor(), circular: true)
        self.labelCommentOwner.text = "\(self.dicQuestionDetails["username"]!)"
        let createTimeString = "\(self.dicQuestionDetails["comment_date"]!)"
        let createdDate = OFAUtils.getDateFromString(createTimeString)
        let createTime = self.getTimeAgo(time:  UInt64(createdDate.millisecondsSince1970))
        
        self.labelDate.text = createTime!
        
        var comment = ""
        self.textViewQuestion.adjustsFontForContentSizeCategory = true
        do {
            let attrStr = try NSAttributedString(data: "\(self.dicQuestionDetails["comment"]!)".data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                                                 options: [ NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
            comment = attrStr.string
        }catch{
            comment = "No Comments"
        }
        
        self.textViewQuestion.text = comment
        
        self.viewHeader.frame = CGRect(x: self.viewHeader.frame.origin.x, y: self.viewHeader.frame.origin.y, width: self.viewHeader.frame.width, height: self.textViewQuestion.contentSize.height+10+49)
        
        self.buttonCancel.layer.cornerRadius = self.buttonCancel.frame.height/2
        self.buttonReport.layer.cornerRadius = self.buttonReport.frame.height/2
        
        if self.isQuestion{
           self.tableViewFooter.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.childViewControllers[1].navigationItem.title = " Question Details"
        self.navigationItem.title = "Details"
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        self.loadReplies(userID: user_id, offset: self.offset, limit: "10")
    }
    
    func loadReplies(userID:String,offset:Int,limit:String){
        if(index-1 >= self.arrayReplies.count ){
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicParameteres = NSDictionary(objects: [userID,LECTURE_ID,self.discussion_id,"\(offset)",limit,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"lecture_id" as NSCopying,"discussion_id" as NSCopying,"offset" as NSCopying,"limit" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/load_child_comments", method: .post, parameters: dicParameteres as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                if let arrayChildComments = dicBody["child_comments"] as? NSArray{
                    if arrayChildComments.count <= 0{
                        OFAUtils.showToastWithTitle("No Replies")
                    }else{
                        self.arrayReplies.removeAllObjects()
                        for item in arrayChildComments{
                            let dicReply  = item as! NSDictionary
                            self.arrayReplies.add(dicReply)
                        }
                    }
                }else{
                    OFAUtils.showToastWithTitle("No Replies")
                }
                OFAUtils.removeLoadingView(nil)
                self.tableView.reloadData()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayReplies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionRepliesCell", for: indexPath) as! OFAQuestionDetailsRepliesTableViewCell

        let dicReply = self.arrayReplies[indexPath.row] as! NSDictionary
        
        cell.buttonOptions.tag = indexPath.row
        let createTimeString = "\(dicReply["comment_date"]!)"
        let createdDate = OFAUtils.getDateFromString(createTimeString)
        let createTime = self.getTimeAgo(time:  UInt64(createdDate.millisecondsSince1970))
        
        var comment = ""
        
        cell.labelDate.adjustsFontForContentSizeCategory = true
        do {
            let attrStr = try NSAttributedString(data: "\(dicReply["comment"]!)".data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                                                 options: [ NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
            comment = attrStr.string
        }catch{
            comment = "No Comments"
        }
        
        cell.customizeCellWithDetails(imageURLString: "\(dicReply["username"]!)", fullName: "\(dicReply["username"]!)", commentDate: createTime!, comments: comment)
        
        let stringVar = String()
        let fontVar = UIFont.fa?.fontSize(15)

        let faType = stringVar.fa.fontAwesome(.fa_ellipsis_v)
        
        cell.buttonOptions.titleLabel?.font = fontVar
        cell.buttonOptions.setTitle(faType, for: .normal)
        cell.buttonOptions.tag = indexPath.row

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 118
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.textViewQuestion.contentSize.height + 77
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableViewHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return !self.isQuestion ? 106 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableViewFooter
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.dropShadow()
        if indexPath.row  == self.arrayReplies.count-1 {
            self.index = index + 10
            print("New data loaded")
            self.offset += 1
            let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
            self.loadReplies(userID: user_id, offset: self.offset, limit: "10")
        }
    }
    
    //MARK:- Button Actions
    @IBAction func sendReplyPressed(_ sender: UIButton) {
        if OFAUtils.isWhiteSpace(self.textReply.text!){
            OFAUtils.showToastWithTitle("Enter your reply")
            return
        }
        let dicParameters = NSDictionary(objects: [user_id,LECTURE_ID,self.discussion_id,self.textReply.text!,domainKey,access_token], forKeys: ["user_id" as NSCopying,"lecture_id" as NSCopying,"comment_id" as NSCopying,"comment" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/post_user_comment", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResponse = responseJSON.result.value as? NSDictionary{
                self.view.endEditing(true)
                self.textReply.text = ""
                print(dicResponse["message"]!)
                OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
                self.index = self.arrayReplies.count-1
                self.loadReplies(userID: self.user_id, offset: 1, limit: "10")
            }else{
//                OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    @IBAction func optionPressed(_ sender: UIButton) {
        let dicReply = self.arrayReplies[sender.tag] as! NSDictionary
        let optionAction = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var reportAction = UIAlertAction()
        var deleteAction = UIAlertAction()
        var cancelAction = UIAlertAction()
        
         reportAction = UIAlertAction(title: "Report", style: .default, handler: { (action) in
            self.textViewEnterReason.text = "Enter the resaon"
            self.report_id = "\(dicReply["id"]!)"
            self.report_api = "api/course/report_course_discussion_comment"
            self.showReportPopUp()
            self.blur()
            self.animateIn()
        })
        deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let dicParameters = NSDictionary(objects: [self.user_id,"\(dicReply["id"]!)",self.domainKey,self.access_token], forKeys: ["user_id" as NSCopying,"comment_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
            Alamofire.request(userBaseURL+"api/course/delete_course_discussion_comment", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
                if let dicResponse = responseJSON.result.value as? NSDictionary{
                    self.view.endEditing(true)
                    self.textReply.text = ""
                    OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
                    self.arrayReplies.removeObject(at: sender.tag)
                    self.index = self.arrayReplies.count-1
                    self.loadReplies(userID: self.user_id, offset: 1, limit: "10")
                }else{
                    OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
        })

        cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        
        if OFASingletonUser.ofabeeUser.user_id! == "\(dicReply["user_id"]!)"{
            optionAction.addAction(deleteAction)
            optionAction.addAction(cancelAction)
        }else{
            optionAction.addAction(reportAction)
            optionAction.addAction(cancelAction)
        }
        
        self.present(optionAction, animated: true, completion: nil)
        
        if !OFAUtils.isiPhone(){
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! OFAQuestionDetailsRepliesTableViewCell
            let popOver = optionAction.popoverPresentationController
            popOver?.sourceRect = (cell.buttonOptions.bounds)
            popOver?.sourceView = cell.buttonOptions
        }
    }
    
    @IBAction func discussionOptionPressed(_ sender: UIButton) {
            let optionAction = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            var reportAction = UIAlertAction()
            var deleteAction = UIAlertAction()
            var cancelAction = UIAlertAction()
            
            reportAction = UIAlertAction(title: "Report", style: .default, handler: { (action) in
                self.textViewEnterReason.text = "Enter the resaon"
                self.report_id = self.discussion_id
                self.report_api = "api/course/report_course_discussion"
                self.showReportPopUp()
                self.blur()
                self.animateIn()
            })
            deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                let dicParameters = NSDictionary(objects: [self.user_id,self.discussion_id,self.domainKey,self.access_token], forKeys: ["user_id" as NSCopying,"comment_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
                Alamofire.request(userBaseURL+"api/course/delete_course_discussion", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
                    if let dicResponse = responseJSON.result.value as? NSDictionary{
                        self.view.endEditing(true)
                        print(dicResponse["message"]!)
                        OFAUtils.showToastWithTitle("deleted successfully")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                    }
                }
            })
            
            cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            
        if OFASingletonUser.ofabeeUser.user_id! == "\(self.dicQuestionDetails["user_id"]!)"{
            optionAction.addAction(deleteAction)
            optionAction.addAction(cancelAction)
        }else{
            optionAction.addAction(reportAction)
            optionAction.addAction(cancelAction)
        }
            
            self.present(optionAction, animated: true, completion: nil)
            
            if !OFAUtils.isiPhone(){
                let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! OFAQuestionDetailsRepliesTableViewCell
                let popOver = optionAction.popoverPresentationController
                popOver?.sourceRect = (cell.buttonOptions.bounds)
                popOver?.sourceView = cell.buttonOptions
            }
        
    }
    
    @IBAction func reportDiscussionPressed(_ sender: UIButton) {
        let dicParameters = NSDictionary(objects: [self.user_id,self.report_id,self.textViewEnterReason.text!,self.domainKey,self.access_token], forKeys: ["user_id" as NSCopying,"comment_id" as NSCopying,"reason" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+self.report_api, method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResponse = responseJSON.result.value as? NSDictionary{
                self.view.endEditing(true)
                self.textReply.text = ""
                print(dicResponse["message"]!)
                OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
                self.index = self.arrayReplies.count-1
                self.loadReplies(userID: self.user_id, offset: 1, limit: "10")
                self.removeBlur()
                self.animateOut()
            }else{
                OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.removeBlur()
        self.animateOut()
    }
    
    //MARK:- UITextfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewEnterReason.text == "Enter the resaon" {
            textViewEnterReason.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewEnterReason.text == "" {
            textViewEnterReason.text = "Enter the resaon"
        }
    }
    
    //MARK:- iPopUP Functions
    
    override func viewDidAppear(_ animated: Bool) {
        viewReportPopup.setNeedsFocusUpdate()
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        
        viewReportPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/3)))
        viewReportPopup.center = view.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if touches.first != nil{
            removeBlur()
            animateOut()
        }
    }
    
    @objc func touchesView(){//tapAction
        removeBlur()
        animateOut()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeBlur()
        animateOut()
    }
    
    public func removeBlur() {
        blurEffectView.removeFromSuperview()
    }
    
    func showReportPopUp(){
        if !OFAUtils.isiPhone(){
            viewReportPopup.frame.origin.x = 0
            viewReportPopup.frame.origin.y = 0
        }
        else{
            viewReportPopup.frame.origin.x = 0
            viewReportPopup.frame.origin.y = 0
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            if GlobalVariables.sharedManager.rotated() == true{
                viewReportPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/3)))
            }
            else {
                viewReportPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/3)))//357
            }
        }
        viewReportPopup.layer.cornerRadius = 10 //make oval view edges
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
    
    func animateIn() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        //        self.view.addSubview(viewReportPopup)
        rootView?.addSubview(viewReportPopup)
        viewReportPopup.center = (rootView?.center)!
        viewReportPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        viewReportPopup.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.viewReportPopup.alpha = 1
            self.viewReportPopup.transform = CGAffineTransform.identity
        }
    }
    
    public func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewReportPopup.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.viewReportPopup.alpha = 0
        }) { (success:Bool) in
            self.viewReportPopup.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.viewReportPopup.removeFromSuperview()
        }
    }
    
    //MARK:- Get TimeStamp string
    
    func getTimeAgo(time:UInt64) -> String? {
        let secondMilliSecond:UInt64 = 1000
        let minuteMilliSecond:UInt64 = 60 * secondMilliSecond
        let hoursMillisecond:UInt64 = 60 * minuteMilliSecond
        //        let DAY_MILLIS:UInt64 = 24 * HOUR_MILLIS
        var time = time
        if time < 1000000000000 {
            time *= 1000
        }
        let nowMilliSecs = Date().millisecondsSince1970
        if time > nowMilliSecs || time <= 0{
            return nil
        }
        let diff = nowMilliSecs - time
        
        if diff < minuteMilliSecond {
            return "just now"
        } else if diff < 2 * minuteMilliSecond {
            return "a minute ago"
        } else if diff < 50 * minuteMilliSecond {
            return "\(diff / minuteMilliSecond)" + " mins ago"
        } else if diff < 90 * minuteMilliSecond {
            return "an hour ago"
        } else if diff < 24 * hoursMillisecond {
            return "\(diff / hoursMillisecond)" + " hrs ago"
        } else if (diff < 48 * hoursMillisecond) {
            return "yesterday";
        }else{
            let createDate = Date(milliseconds: time)
            let createTime = OFAUtils.getStringFromMilliSecondDate(date: createDate)
            return createTime
        }
    }
}

//extension UITextField{
//        
//    var padding:UIEdgeInsets{
//        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//    }
//    
//        func textRect(forBounds bounds: CGRect) -> CGRect {
//            return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
//        }
//    
//        func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//            return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
//        }
//        
//        func editingRect(forBounds bounds: CGRect) -> CGRect {
//            return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
//        }
//}
