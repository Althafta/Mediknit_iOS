//
//  VGVerticalViewController.swift
//  VGPlayer-Example
//
//  Created by Vein on 2017/6/9.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import AVKit
import AVFoundation
import STRatingControl

class VGVerticalVideoViewController: UIViewController,STRatingControlDelegate {
    //    var player : VGPlayer?
    var videoURLString = ""
    var videoTitle = ""
    var isLiveVideo = false
    var liveTimer = Timer()         //timer for Live lectures
    var lectureID = ""
    
    var percentage = Float64()
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    @IBOutlet var viewRatingPopup: UIView!
    @IBOutlet weak var ratingView: STRatingControl!
    @IBOutlet var viewVideoContent: UIView!
//    @IBOutlet var buttonCurriculum: UIButton!
    @IBOutlet var buttonQandA: UIButton!
    
    var volumeBar = SubtleVolume.init(style: .dashes)
    
    var avVideoPlayerController = AVPlayerViewController()
    var avPlayer = AVPlayer()
    
    var isSeeked = false
    var isPercentageSaved = false
    var timerStarted = Timer()       //timer for normal video lectures
    var time = 0
    var isFullyViewed = false
    
    var arrayQueuedTSFiles = [AVPlayerItem]()
    var tsDataFiles = NSMutableData()
    var arrayTSURLs = [String]()
    var index = 0
//    var videoIOSUrl = "https://elearn.maven-silicon.com/maven_ios_app/"
    var seekedTime = CMTime()
    
    //Interactive question's variables
    
    var dicInteractiveQuestion = NSDictionary()
    var arrayQuestionTimes = NSArray()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingView.delegate = self
        //        self.navigationController?.hidesBarsOnTap = true
        
//        self.buttonCurriculum.layer.cornerRadius = self.buttonCurriculum.frame.height/2
//        self.buttonCurriculum.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
//        self.buttonCurriculum.layer.borderWidth = 1.0
        
        self.buttonQandA.layer.cornerRadius = self.buttonQandA.frame.height/2
        self.buttonQandA.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonQandA.layer.borderWidth = 1.0
        
        self.navigationController?.hidesBarsWhenVerticallyCompact = true
        
        volumeBar.frame = CGRect(x: 0, y: 70, width: self.view.frame.width, height: 2)
        volumeBar.barTintColor = .white
        volumeBar.animation = .fadeIn
        
        view.addSubview(volumeBar)
        
//        let m3u8URLString = self.videoURLString.components(separatedBy: "/videos/")
//        self.videoURLString = videoIOSUrl + m3u8URLString[1]
        
        self.avPlayer = AVPlayer(url: URL(string: self.videoURLString)!)
        self.avVideoPlayerController.view.frame = self.viewVideoContent.frame
        self.viewVideoContent.addSubview(self.avVideoPlayerController.view)
        self.avVideoPlayerController.view.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.edges.equalTo(strongSelf.viewVideoContent)
        }
        self.avVideoPlayerController.player = self.avPlayer
        
        if self.percentage != 100.0{
            let totalPlayerTime = CMTimeGetSeconds((self.avVideoPlayerController.player?.currentItem?.asset.duration)!)
            let currentTime = (self.percentage/100)*totalPlayerTime
            let cmtime = CMTime(seconds: currentTime, preferredTimescale: 1)
            self.avPlayer.play()
//            self.avVideoPlayerController.showsPlaybackControls = false
            self.time = Int(CMTimeGetSeconds(cmtime))
            self.avPlayer.seek(to: cmtime)
            self.seekedTime = cmtime
            self.timerStarted = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }else{
            self.timerStarted = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            self.avPlayer.play()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.buttonQandA.isHidden = false
//        self.buttonCurriculum.isHidden = true
        
//        self.present(self.avVideoPlayerController, animated: true, completion: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(awesomeType: .fa_ellipsis_v, style: .plain, target: self, action: #selector(self.rightBarButtonPressed))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OFAUtils.lockOrientation(.allButUpsideDown)
        
        self.navigationItem.title = self.videoTitle
        if isLiveVideo == true{
            self.liveTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.getVideoDetails), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OFAUtils.lockOrientation(.portrait)
//        self.timerStarted.invalidate()
        if !isSeeked {
            self.saveLectureProgress()
        }
        removeBlur()
        animateOut()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
        self.liveTimer.invalidate()
        UIApplication.shared.isStatusBarHidden = false
    }
    
    //MARK:- Barbutton action
    
    @objc func rightBarButtonPressed(){
        let barButtonAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        barButtonAlert.addAction(UIAlertAction(title: "Rating", style: .default, handler: { (action) in
            self.avPlayer.pause()
            self.showRatingPopUp()
            self.blur()
            self.animateIn()
        }))
        barButtonAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            barButtonAlert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(barButtonAlert, animated: true, completion: nil)
        if !OFAUtils.isiPhone(){
            let popOver = barButtonAlert.popoverPresentationController
            popOver?.barButtonItem = self.navigationItem.rightBarButtonItem
        }
    }
    
    //MARK:- STRatingControl Delegate
    
    func didSelectRating(_ control: STRatingControl, rating: Int) {
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.lectureID,COURSE_ID,"\(rating)",user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"course_id" as NSCopying,"rating" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        print(dicParameters)
        Alamofire.request(userBaseURL+"api/course/save_rating_review", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                print(dicResult)
                self.removeBlur()
                self.animateOut()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Interactive Questions helper
    
    func getInteractiveQuestionsArray(at timeInterval:String){
        guard let questionInterval = NumberFormatter().number(from: timeInterval) else { return }
        print(questionInterval)
        if self.arrayQuestionTimes.contains(questionInterval){
            self.avVideoPlayerController.dismiss(animated: true, completion: nil)
            let arrayQuestionAtInterval = self.dicInteractiveQuestion[timeInterval] as! NSArray
//            print(arrayQuestionAtInterval)
            let interactiveQuestions = self.storyboard?.instantiateViewController(withIdentifier: "InteractiveQuestionsTVC") as! OFAInteractiveQuestionsTableViewController
            UserDefaults.standard.setValue(arrayQuestionAtInterval, forKey: "QuestionArray")
            UserDefaults.standard.setValue(0, forKey: "PageIndex")
            interactiveQuestions.arrayQuestions = arrayQuestionAtInterval
            interactiveQuestions.questionString = "\((arrayQuestionAtInterval[0] as! NSDictionary)["question"]!)"
            interactiveQuestions.explanationString = "\((arrayQuestionAtInterval[0] as! NSDictionary)["explanation"]!)"
            let nav = UINavigationController(rootViewController: interactiveQuestions)
            if self.avVideoPlayerController.isTopVC(self){
                self.presentedViewController?.dismiss(animated: true, completion: {
//                    self.present(nav, animated: true, completion: nil)
                })
                self.present(nav, animated: true, completion: nil)
            }else{
                self.present(nav, animated: true, completion: nil)
            }
            self.avPlayer.pause()
//            if self.avVideoPlayerController.isBeingPresented{
//                self.presentedViewController?.dismiss(animated: true, completion: {
//                    self.present(nav, animated: true, completion: nil)
//                })
//            }else{
//                self.present(nav, animated: true, completion: nil)
//            }
//            self.avVideoPlayerController.dismiss(animated: true) {
//                self.present(nav, animated: true, completion: nil)
//            }
//            self.avVideoPlayerController.present(nav, animated: true, completion: nil)
        }
    }
    
    //MARK:- Save percentage helper
    
    @objc func updateTimer(){
        if avPlayer.timeControlStatus == .playing{
            let currentTime = CMTimeGetSeconds((self.avVideoPlayerController.player?.currentItem?.currentTime())!)
            let totalPlayerTime = CMTimeGetSeconds((self.avVideoPlayerController.player?.currentItem?.asset.duration)!)
            self.percentage = (currentTime/totalPlayerTime)*100
            self.time = Int(currentTime)
            self.getInteractiveQuestionsArray(at: "\(Int(currentTime))")
            let intCurrentTime = Int(currentTime)
            if intCurrentTime > self.time{
                //print("seeked to time")
                self.isSeeked = false
//                self.timerStarted.invalidate()
            }else{
                self.isSeeked = false
            }
            self.time += 1
        }
    }
    
    @objc func didFinishedPlaying(){
        self.isFullyViewed = true
    }
    
    
    func saveLectureProgress(){
        if self.isFullyViewed{
            self.percentage = 100
        }
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.lectureID,"\(self.percentage)","\(self.time)",user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"percentage" as NSCopying,"seconds" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        print(dicParameters)
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
                self.isPercentageSaved = true
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func curriculumPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func QandAPressed(_ sender: UIButton) {
        let QandATabCVC = self.storyboard?.instantiateViewController(withIdentifier: "QandAContainerVC") as! OFALectureQAndAContainerViewController
        avPlayer.pause()
        LECTURE_ID = self.lectureID
        self.navigationController?.pushViewController(QandATabCVC, animated: true)
    }
    
    //MARK:- Helpers
    
    @objc func getVideoDetails(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,self.lectureID,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        //        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                if let liveVideoStatus = dicBody["live_status"] as? String{
                    if liveVideoStatus == "0" || liveVideoStatus == ""{
                        if #available(iOS 11.0, *) {
                            self.avVideoPlayerController.exitsFullScreenWhenPlaybackEnds = true
                        } else {
                            // Fallback on earlier versions
                        }
                        let sessionAlert = UIAlertController(title: "Live Streaming ended", message: nil, preferredStyle: .alert)
                        sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                            sessionAlert.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(sessionAlert, animated: true, completion: nil)
                        return
                    }
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
    
    //MARK:- iPopUP Functions
    
    override func viewDidAppear(_ animated: Bool) {
        viewRatingPopup.setNeedsFocusUpdate()
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        
        viewRatingPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: 146))
        viewRatingPopup.center = view.center
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
    
    public func removeBlur() {
        blurEffectView.removeFromSuperview()
    }
    
    func showRatingPopUp(){
        if !OFAUtils.isiPhone(){
            viewRatingPopup.frame.origin.x = 0
            viewRatingPopup.frame.origin.y = 0
        }
        else{
            viewRatingPopup.frame.origin.x = 0
            viewRatingPopup.frame.origin.y = 0
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            if GlobalVariables.sharedManager.rotated() == true{
                viewRatingPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: 146))
            }
            else {
                viewRatingPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: 146))
            }
        }
        viewRatingPopup.layer.cornerRadius = 10 //make oval view edges
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
        //        self.view.addSubview(viewRatingPopup)
        rootView?.addSubview(viewRatingPopup)
        viewRatingPopup.center = (rootView?.center)!
        viewRatingPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        viewRatingPopup.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.viewRatingPopup.alpha = 1
            self.viewRatingPopup.transform = CGAffineTransform.identity
        }
    }
    
    public func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewRatingPopup.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.viewRatingPopup.alpha = 0
        }) { (success:Bool) in
            self.viewRatingPopup.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.viewRatingPopup.removeFromSuperview()
        }
    }
}

extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
