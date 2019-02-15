//
//  OFAMyCourseCurriculumListContainerViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/31/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift
import Alamofire
//import Vision

protocol MyCourseCurriculumContainerDelegate {
    func lastPlayedLecture(dicLecture:NSDictionary)
}

class OFAMyCourseCurriculumListContainerViewController: UIViewController {

    @IBOutlet var viewContainer: UIView!
    @IBOutlet var buttonPlayLecture: UIButton!
    @IBOutlet var labelLectureTitle: UILabel!
    @IBOutlet var buttonProgressBar: MHProgressButton!
    
    var arraySections = NSMutableArray()
    var dicCourseDetails = NSDictionary()
    var dicLecture = NSDictionary()
    
    var delegate : MyCourseCurriculumContainerDelegate!
    
    lazy var curriculumTabTVC: UIViewController? = {
        let curriculumTabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseCurriculumTVC") as! OFAMyCourseDetailsCurriculumTableViewController
        return curriculumTabTVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonProgressBar.layer.cornerRadius = self.buttonProgressBar.frame.height/2
        
        self.displayCurrentTab()
        self.buttonPlayLecture.clipsToBounds = true
        self.buttonPlayLecture.layer.cornerRadius = self.buttonPlayLecture.frame.height/2
        
        let stringVar = String()
        let fontVar = UIFont(fa_fontSize: 25)

        let faType = stringVar.fa.fontAwesome(.fa_play)
        
        self.buttonPlayLecture.titleLabel?.font = fontVar
        self.buttonPlayLecture.setTitle(" \(faType)", for: .normal)
        
        self.loadCurriculum()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationObserver), name: NSNotification.Name.init(rawValue: "CurriculumRefresh"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCurriculum()
    }
    
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(animated)
        self.loadCurriculum()
    }

    @objc func notificationObserver(){
        self.loadCurriculum()
    }
    
    func loadCurriculum(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Curriculum")
        Alamofire.request(userBaseURL+"api/course/course_curriculum", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let dicCourse = dicBody["course"] as! NSDictionary
                self.dicCourseDetails = dicCourse
                let arrTopics = dicCourse["topics"] as! NSArray
                self.arraySections.removeAllObjects()
                for item in arrTopics {
                    let dicTopic = item as! NSDictionary
                    self.arraySections.add(dicTopic)
                }
                if self.arraySections.count > 0 {
                    self.populateDetails()
                }else{
                    self.buttonPlayLecture.isHidden = true
                    self.buttonProgressBar.isHidden = true
                    self.labelLectureTitle.isHidden = true
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    func populateDetails(){
        let lastPlayedLecture = "\(self.dicCourseDetails["last_palyed_lecture"]!)"
        if lastPlayedLecture != "" || lastPlayedLecture != "<null>"{
            let arrayTopic = self.dicCourseDetails["topics"] as! NSArray
            for j in 0..<self.arraySections.count{
                for i in 0..<arrayTopic.count{
                    let dicTopic = arrayTopic[i] as! NSDictionary
                    let arrayLecture = dicTopic["lectures"] as! NSArray
                    let predicate = NSPredicate(format: "id==%@", lastPlayedLecture)
                    let arrayLastPlayedLecture = arrayLecture.filtered(using: predicate) as NSArray
                    if arrayLastPlayedLecture.count > 0 {
                        self.dicLecture = arrayLastPlayedLecture[0] as! NSDictionary
                    }
                }
            }
            if self.dicLecture.count <= 0  {
                let dicTopic = self.arraySections[0] as! NSDictionary
                let arrayLecture = dicTopic["lectures"] as! NSArray
                if arrayLecture.count > 0{
                    self.dicLecture = arrayLecture[0] as! NSDictionary
                    self.labelLectureTitle.text = "\(self.dicLecture["cl_lecture_name"]!)"
                    let percentage = "\(dicLecture["ll_percentage"]!)"
                    guard let floatPercentage = NumberFormatter().number(from: percentage) else { return }
                    self.buttonProgressBar.linearLoadingWith(progress: CGFloat(truncating: floatPercentage))
                }
            }else{
                self.labelLectureTitle.text = "\(self.dicLecture["cl_lecture_name"]!)"
                let percentage = "\(dicLecture["ll_percentage"]!)"
                guard let floatPercentage = NumberFormatter().number(from: percentage) else { return }
                self.buttonProgressBar.linearLoadingWith(progress: CGFloat(truncating: floatPercentage))
            }
        }else{
            let dicTopic = self.arraySections[0] as! NSDictionary
            let arrayLecture = dicTopic["lectures"] as! NSArray
            self.dicLecture = arrayLecture[0] as! NSDictionary
            
            self.labelLectureTitle.text = "\(self.dicLecture["cl_lecture_name"]!)"
            let percentage = "\(dicLecture["ll_percentage"]!)"
            guard let floatPercentage = NumberFormatter().number(from: percentage) else { return }
            self.buttonProgressBar.linearLoadingWith(progress: CGFloat(truncating: floatPercentage))
        }
    }
    
    @IBAction func lastPlayedLecturePressed(_ sender: UIButton) {
        self.delegate.lastPlayedLecture(dicLecture: self.dicLecture)
    }
    
    func displayCurrentTab(){
        if let vc = curriculumTabTVC {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.viewContainer.bounds
            self.viewContainer.addSubview(vc.view)
        }
    }
}
