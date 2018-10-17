//
//  OFAYoutubeVideoViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/23/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import YouTubePlayer
import Alamofire

class OFAYoutubeVideoViewController: UIViewController {

    @IBOutlet var viewYoutubePlayer: YouTubePlayerView!
    @IBOutlet var buttonCurriculum: UIButton!
    @IBOutlet var buttonQandA: UIButton!
    @IBOutlet var buttonDone: UIButton!
    
    var videoURL = ""
    var isBrowseCourse = true
    var lectureID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonQandA.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonQandA.layer.cornerRadius = self.buttonQandA.frame.height/2
        self.buttonQandA.layer.borderWidth = 1.0
        
        self.buttonCurriculum.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonCurriculum.layer.cornerRadius = self.buttonCurriculum.frame.height/2
        self.buttonCurriculum.layer.borderWidth = 1.0
        
        if self.isBrowseCourse{
            self.buttonDone.isHidden=false
            self.buttonCurriculum.isHidden = true
            self.buttonQandA.isHidden = true
        }else{
            self.buttonDone.isHidden=true
        }
//        let myVideoURL = URL(string: self.videoURL)
//        self.viewYoutubePlayer.loadVideoURL(myVideoURL!)
        self.viewYoutubePlayer.loadVideoID(self.videoURL)
        self.navigationController?.hidesBarsWhenVerticallyCompact = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OFAUtils.lockOrientation(.allButUpsideDown)
        UIApplication.shared.statusBarStyle = .lightContent
        if !isBrowseCourse{
            self.saveLectureProgress()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OFAUtils.lockOrientation(.portrait)
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    func saveLectureProgress(){
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.lectureID,"100",user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"percentage" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/save_lecture_percentage", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                print(dicResult)
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
    
    //MARK:- Button Actions
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func QandAPressed(_ sender: UIButton) {
        let QandATabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        QandATabTVC.isPresented = false
//        let nav = UINavigationController(rootViewController: QandATabTVC)
//        self.present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(QandATabTVC, animated: true)
    }
    
    @IBAction func curriculumPressed(_ sender: UIButton) {
        _ = self.dismiss(animated: true, completion: nil)
    }
}
