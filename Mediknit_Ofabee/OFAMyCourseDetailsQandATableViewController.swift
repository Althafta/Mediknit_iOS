//
//  OFAMyCourseDetailsQandATableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAMyCourseDetailsQandATableViewController: UITableViewController,UITextViewDelegate {

    var offset = 1
    var index = 0
    var arrayDiscussions = NSMutableArray()
    
    @IBOutlet var viewTableViewFooter: UIView!
    @IBOutlet var buttonPlus: UIButton!
    
    @IBOutlet var viewAskQuestionPopUp: UIView!
    @IBOutlet var buttonCancel: UIButton!
    @IBOutlet var buttonPost: UIButton!
    @IBOutlet var textViewAskQuestion: UITextView!
    @IBOutlet var viewDropDown: HADropDown!
    
    var isPresented = false
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.tableView.refreshControl = self.refreshController
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.barTintColor = OFAUtils.getColorFromHexString(barTintColor)
        
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)

        self.buttonPlus.clipsToBounds = true
        self.buttonPlus.layer.cornerRadius = self.buttonPlus.frame.width/2
        self.buttonPlus.dropShadow()
        
        self.buttonCancel.layer.cornerRadius = self.buttonCancel.frame.height/2
        self.buttonPost.layer.cornerRadius = self.buttonCancel.frame.height/2
        
        self.textViewAskQuestion.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewAskQuestion.layer.borderWidth = 1.0
        
        self.viewDropDown.layer.cornerRadius = self.viewDropDown.frame.height/2
        
        self.textViewAskQuestion.inputAccessoryView = OFAUtils.getDoneToolBarButton(tableView: self, target: #selector(self.dismissKeyboard))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissAction))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        self.arrayDiscussions.removeAllObjects()
        
        self.refreshInitiated()
    }
    
    @objc func refreshInitiated(){
        index = 0
        self.offset=1
        
        self.arrayDiscussions.removeAllObjects()
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        self.loadDiscussion(userID: user_id, offset: 1, limit: "10")
    }
     
    @objc func dismissKeyboard(){
        self.viewAskQuestionPopUp.endEditing(true)
    }
    
    @objc func dismissAction(){
        self.navigationController?.popViewController(animated: true)
        removeBlur()
        animateOut()
    }
    
    func loadDiscussion(userID:String,offset:Int,limit:String){
        if(index-1 >= self.arrayDiscussions.count ){
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicParameteres = NSDictionary(objects: [userID,COURSE_ID,"\(offset)",limit,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"course_id" as NSCopying,"offset" as NSCopying,"limit" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/get_discussions", method: .post, parameters: dicParameteres as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.refreshController.endRefreshing()
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
                let arrDiscussion = dicBody["discussions"] as! NSArray
                for item in arrDiscussion{
                    let dicDiscussion = item as! NSDictionary
                    self.arrayDiscussions.add(dicDiscussion)
                }
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
                self.tableView.scrollsToTop = true
            }else{
                OFAUtils.removeLoadingView(nil)
                self.refreshController.endRefreshing()
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayDiscussions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCourseDetailsDiscussionCell", for: indexPath) as! OFAMyCourseDetailsDiscussionTableViewCell

        let dicDiscussion = self.arrayDiscussions[indexPath.row] as! NSDictionary
        
        let createTimeString = "\(dicDiscussion["created_date"]!)"
        let createdDate = OFAUtils.getDateFromString(createTimeString)
        let createTime = self.getTimeAgo(time:  UInt64(createdDate.millisecondsSince1970))
        
        var comment = ""
        
        cell.labelComment.adjustsFontForContentSizeCategory = true
        do {
            let attrStr = try NSAttributedString(data: "\(dicDiscussion["comment"]!)".data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                                                 options: [ NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
            comment = attrStr.string
        }catch{
            comment = "No Comments"
        }
        
        cell.customizeCellWithDetails(comment: comment, author: "\(dicDiscussion["us_name"]!)", dateString: createTime!, numberOfReplies: "\(dicDiscussion["children_count"]!)")

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let discussionRepliesTVC = self.storyboard?.instantiateViewController(withIdentifier: "DiscussionRepliesTVC") as! OFAMyCourseDetailsDisussionRepliesTableViewController
        if isPresented == false{
            self.navigationController?.children[1].navigationItem.title = ""
        }else{
            self.navigationItem.title = ""
        }
        let dicDiscussion = self.arrayDiscussions[indexPath.row] as! NSDictionary
        discussionRepliesTVC.discussion_id = "\(dicDiscussion["id"]!)"
        discussionRepliesTVC.dicQuestionDetails = dicDiscussion
        self.navigationController?.pushViewController(discussionRepliesTVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row  == self.arrayDiscussions.count-1 {
            self.index = index + 10
            print("New data loaded")
            self.offset += 1
            let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
            self.loadDiscussion(userID: user_id, offset: self.offset, limit: "10")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.viewTableViewFooter
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 97
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    //MARK:- Button Actions
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        self.textViewAskQuestion.text = "What's on your mind and where you are getting stuck?"
        self.showAskQuestionPopUp()
        blur()
        animateIn()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        removeBlur()
        animateOut()
    }
    
    @IBAction func postQuestionPressed(_ sender: UIButton) {
        if self.textViewAskQuestion.text == "What's on your mind and where you are getting stuck?" || OFAUtils.isWhiteSpace(self.textViewAskQuestion.text!){
            self.viewAskQuestionPopUp.endEditing(true)
            OFAUtils.showToastWithTitle("Enter your comment")
            return
        }
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let access_token = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [user_id,COURSE_ID,"",self.textViewAskQuestion.text!,domainKey,access_token], forKeys: ["user_id" as NSCopying,"course_id" as NSCopying,"comment_title" as NSCopying,"comment" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/create_new_discussion", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicRespose = responseJSON.result.value as? NSDictionary{
                self.removeBlur()
                self.animateOut()
                OFAUtils.showToastWithTitle("\(dicRespose["message"]!)")
//                self.index = self.arrayDiscussions.count-1
                self.arrayDiscussions.removeAllObjects()
                self.refreshInitiated()
                self.tableView.reloadData()
            }else{
                OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewAskQuestion.text == "What's on your mind and where you are getting stuck?" {
            textViewAskQuestion.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewAskQuestion.text == "" {
            textViewAskQuestion.text = "What's on your mind and where you are getting stuck?"
        }
    }
    
    //MARK:- iPopUP Functions
    
    override func viewDidAppear(_ animated: Bool) {
        viewAskQuestionPopUp.setNeedsFocusUpdate()
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        
        viewAskQuestionPopUp.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/3)))
        viewAskQuestionPopUp.center = view.center
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
    
    func showAskQuestionPopUp(){
        if !OFAUtils.isiPhone(){
            viewAskQuestionPopUp.frame.origin.x = 0
            viewAskQuestionPopUp.frame.origin.y = 0
        }
        else{
            viewAskQuestionPopUp.frame.origin.x = 0
            viewAskQuestionPopUp.frame.origin.y = 0
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            if GlobalVariables.sharedManager.rotated() == true{
                viewAskQuestionPopUp.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/3)))
            }
            else {
                viewAskQuestionPopUp.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/3)))//357
            }
        }
        viewAskQuestionPopUp.layer.cornerRadius = 10 //make oval view edges
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
        //        self.view.addSubview(viewAskQuestionPopUp)
        rootView?.addSubview(viewAskQuestionPopUp)
        viewAskQuestionPopUp.center = (rootView?.center)!
        viewAskQuestionPopUp.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        viewAskQuestionPopUp.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.viewAskQuestionPopUp.alpha = 1
            self.viewAskQuestionPopUp.transform = CGAffineTransform.identity
        }
    }
    
    public func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewAskQuestionPopUp.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.viewAskQuestionPopUp.alpha = 0
        }) { (success:Bool) in
            self.viewAskQuestionPopUp.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.viewAskQuestionPopUp.removeFromSuperview()
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

extension Date {
    var millisecondsSince1970:UInt64 {
        return UInt64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:UInt64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
