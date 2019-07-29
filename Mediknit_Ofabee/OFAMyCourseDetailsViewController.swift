//
//  OFAMyCourseDetailsViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift
import Alamofire

class OFAMyCourseDetailsViewController: UIViewController {

    enum TabIndex : Int {
        case curriculumTab = 0
        case DiscussionTab = 1
    }
    
    @IBOutlet weak var viewPromo: UIView!
    @IBOutlet weak var imageViewPromo: UIImageView!
    @IBOutlet weak var buttonPromoPlay: UIButton!
    
    @IBOutlet var segmentControlMyCourse: TabySegmentedControl!
    @IBOutlet var contentView: UIView!
    var courseTitle = ""
    var promoImageURLString = ""
    
    var currentViewController: UIViewController?
    lazy var curriculumVC: UIViewController? = {
        let curriculumVC = self.storyboard?.instantiateViewController(withIdentifier: "CurriculumContainerView") as! OFAMyCourseCurriculumListContainerViewController
        return curriculumVC
    }()
    lazy var DiscussionTabTVC : UIViewController? = {
        let DiscussionTabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        
        return DiscussionTabTVC
    }()
    
    var notificationBarButtonItem = UIBarButtonItem()
    let user_id = UserDefaults.standard.value(forKey: USER_ID)
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN)
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewPromo.sd_setImage(with: URL(string: self.promoImageURLString)!, placeholderImage: UIImage(named: "AppLogo_horizontal"), options: .progressiveDownload)
        self.buttonPromoPlay.isHidden = true
        self.contentView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        segmentControlMyCourse.initUI()
        segmentControlMyCourse.selectedSegmentIndex = TabIndex.curriculumTab.rawValue
        displayCurrentTab(TabIndex.curriculumTab.rawValue)
        
        self.notificationBarButtonItem = UIBarButtonItem(image: UIImage(named: "NotificationIcon"), style: .plain, target: self, action: #selector(self.notificationPressed))
        self.navigationItem.rightBarButtonItems = [self.notificationBarButtonItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.courseTitle
        self.getNotifications()
    }
    
    //MARK:- Notification helpers
    
    func getNotifications(){
        let dicParameters = NSDictionary(objects: [self.user_id as! String,domainKey,self.accessToken as! String,COURSE_ID], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"course_id" as NSCopying])
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
                        self.notificationBarButtonItem.addBadge(number: arrayUnReadNotifications.count)
                    }
                }
            }else{
                print("Notification API failed")
            }
        }
    }
    
    //MARK:- Button Actions
    
    @objc func notificationPressed(){
        let notificationPage = self.storyboard?.instantiateViewController(withIdentifier: "NotificationTVC") as! OFANotificationTableViewController
        notificationPage.isCourseSpecific = true
        notificationPage.courseID = COURSE_ID
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(notificationPage, animated: true)
    }
    
    @IBAction func promoPlayPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func segmentControlSelected(_ sender: TabySegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParent()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    //MARK:- Content view helpers
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.curriculumTab.rawValue :
            vc = curriculumVC
        case TabIndex.DiscussionTab.rawValue :
            vc = DiscussionTabTVC
        
        default:
            return nil
        }
        return vc
    }

}
