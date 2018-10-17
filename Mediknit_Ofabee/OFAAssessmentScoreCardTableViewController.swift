//
//  OFAAssessmentScoreCardTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 10/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

protocol didAttendAgainSelectedDelegate{
    func attendAgainSelected(selectedTag:Int)
}

class OFAAssessmentScoreCardTableViewController: UITableViewController {
    
    @IBOutlet var buttonAttendAgain: UIButton!
    @IBOutlet var buttonDetailedView: UIButton!
    
    @IBOutlet var labelMyScore: UILabel!
    @IBOutlet var labelTotalScore: UILabel!
    @IBOutlet var labelMyAttempted: UILabel!
    @IBOutlet var labelAttempted: UILabel!
    @IBOutlet var labelTimeTaken: UILabel!
    @IBOutlet var labelRightAnswer: UILabel!
    @IBOutlet var labelWrongAnswers: UILabel!
    @IBOutlet var labelAccuracyPercentage: UILabel!
    @IBOutlet var labelAverageSpeed: UILabel!
    
    @IBOutlet var imageViewBadge: UIImageView!
    @IBOutlet var imageViewAttempted: UIImageView!
    @IBOutlet var imageViewTimeTaken: UIImageView!
    @IBOutlet var imageViewRightAnswer: UIImageView!
    @IBOutlet var imageViewWrongAnswer: UIImageView!
    @IBOutlet var viewPieChart: OFAPieChartView!
    @IBOutlet var viewSemiCirclePieChart: OFASemiCirclePieChart!
    
    var dicScoreCardDetails = NSDictionary()
    var delegate:didAttendAgainSelectedDelegate!
    
    var isAssessment = true
    var isChallenge = true
    var isGenerateTest = true
    var lectureID = ""
    
    //MARK:- Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OFAUtils.lockOrientation(.portrait)
        OFAUtils.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageViewBadge.layer.cornerRadius = self.imageViewBadge.frame.height/2
        self.imageViewAttempted.layer.cornerRadius = self.imageViewAttempted.frame.height/2
        self.imageViewTimeTaken.layer.cornerRadius = self.imageViewTimeTaken.frame.height/2
        self.imageViewRightAnswer.layer.cornerRadius = self.imageViewRightAnswer.frame.height/2
        self.imageViewWrongAnswer.layer.cornerRadius = self.imageViewWrongAnswer.frame.height/2
        
        self.buttonAttendAgain.layer.cornerRadius = self.buttonAttendAgain.frame.height/2
        self.buttonDetailedView.layer.cornerRadius = self.buttonDetailedView.frame.height/2
        
        let dicBody = self.dicScoreCardDetails["body"] as! NSDictionary
        if isAssessment{
            let dicResult = dicBody["results"] as! NSDictionary
            let maxAttempt = Int("\(dicResult["max_attempt"]!)")!
            if  maxAttempt == 0 {
                self.buttonAttendAgain.isHidden = false
            }else if maxAttempt > 0 {
                if maxAttempt > Int("\(dicResult["user_attempts"]!)")!{
                    self.buttonAttendAgain.isHidden = false
                }else{
                    self.buttonAttendAgain.isHidden = true
                }
            }
        }else{
            self.buttonAttendAgain.isHidden = true
        }
        self.populateScoreCardWithDetails(dicDetails: self.dicScoreCardDetails)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Wrong_Answer"), style: .plain, target: self, action: #selector(self.dismissScoreCard))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismissScoreCard(){
//        self.navigationController?.popToViewController((self.parent?.parent)!, animated: true)
        UserDefaults.standard.removeObject(forKey: "OriginalAssessmentQuestions")
        let controllers = self.navigationController?.viewControllers
        if isAssessment{
            for vc in controllers! {
                if vc is OFAMyCourseDetailsViewController {
                    _ = self.navigationController?.popToViewController(vc as! OFAMyCourseDetailsViewController, animated: true)
                }
            }
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.slideMenuController()?.addLeftGestures()
        
        if isAssessment{
            self.saveLectureProgress()
        }
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
    
    func populateScoreCardWithDetails(dicDetails:NSDictionary){
        let dicBody = dicDetails["body"] as! NSDictionary
        let dicResult = dicBody["results"] as! NSDictionary
        let myScore  = "\(dicResult["marks_scored"]!)"
        
        var durationString = ""
        var averageText = ""
        
        let duration = self.getDuration(seconds: Int("\(dicResult["time_taken"]!)")!)
        if duration[0] > 0 {
            durationString = "\(duration[0]) hr \(duration[1]) m \(duration[2]) s"
            averageText = " Qns / hr"
        }else if duration[1] > 0 {
            durationString = "\(duration[1]) m \(duration[2]) s"
            averageText = " Qns / min"
        }else if duration[2] >= 0 {
            durationString = " \(duration[2]) s"
            averageText = " Qns / sec"
        }
        
        self.labelMyScore.text = myScore
        self.labelTotalScore.text = "/\(dicResult["total_mark"]!)"
        self.labelMyAttempted.text = "\(dicResult["total_attended"]!)"
        self.labelAttempted.text = "/\(dicResult["total_questions"]!)"
        self.labelTimeTaken.text = durationString
        self.labelRightAnswer.text = "\(dicResult["right_answers"]!)"
        self.labelWrongAnswers.text = "\(dicResult["wrong_answers"]!)"
        self.labelAccuracyPercentage.text = "\(dicResult["accuracy"]!) %"
        
        self.viewSemiCirclePieChart.backgroundColor = .clear
        
        let strTimeTaken = "\(dicResult["time_taken"]!)"
        guard let timeTaken = NumberFormatter().number(from: strTimeTaken) else { return }
        
        let strAttended = "\(dicResult["total_attended"]!)"
        guard let totalAttended = NumberFormatter().number(from: strAttended) else { return }
        
        let averageValue =  (totalAttended as! CGFloat)/(timeTaken as! CGFloat)
        let x = averageValue
        let y = Double(round(100*x)/100)
        self.labelAverageSpeed.text = "\(y)"+averageText
        
        let totalValuePartial:CGFloat = 180
        let totalValueFull:CGFloat = 360
        
        self.viewSemiCirclePieChart.partialSegments = [
            PartialSegment(color: OFAUtils.getColorFromHexString("00a6a9"), value: (totalValuePartial * averageValue)/100),
            PartialSegment(color: OFAUtils.getColorFromHexString("cedadb"), value: totalValuePartial)
        ]
        self.viewPieChart.segments = [
            Segment(color: OFAUtils.getColorFromHexString("00a6a9"), value: (totalValueFull * (dicResult["accuracy"] as! CGFloat))/100),
            Segment(color: OFAUtils.getColorFromHexString(ofabeeGreenColorCode), value: totalValueFull)
        ]
//        let pieLayer = PieLayer()
//        pieLayer.frame = CGRect(x: 0, y: 0, width: 90 , height: 90)
//        pieLayer.addValues([PieElement(value: Float("\(dicResult["accuracy"]!)")!, color: OFAUtils.getColorFromHexString("00a6a9")),PieElement(value: (100 - Float("\(dicResult["accuracy"]!)")!), color: OFAUtils.getColorFromHexString(ofabeeGreenColorCode))], animated: false)
//        //            self.viewPieChart.contentMode = .center
//        self.viewPieChart.layer.addSublayer(pieLayer)
//
//        let semiPieLayer = PieLayer()
//        semiPieLayer.frame = CGRect(x: 0, y: 0, width: 90 , height: 90)
//        semiPieLayer.startAngle = 0
//        semiPieLayer.endAngle = 180
//        semiPieLayer.addValues([PieElement(value: Float(totalValuePartial * averageValue), color: OFAUtils.getColorFromHexString("00a6a9")),PieElement(value: (100 - Float(totalValuePartial * averageValue)), color: OFAUtils.getColorFromHexString(ofabeeGreenColorCode))], animated: false)
//        //            self.viewSemiCirclePieChart.contentMode = .center
//        self.viewSemiCirclePieChart.layer.addSublayer(semiPieLayer)
    }
    
    func getDuration(seconds:Int) -> [Int]{
        let hours = seconds/3600
        let minutes = (seconds%3600)/60
        let second = seconds % 60
        return [hours,minutes,second]
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(backgroundColor)
    }
    
    //MARK:- Button Action
    
    @IBAction func attendAgainPressed(_ sender: UIButton) {
        self.delegate.attendAgainSelected(selectedTag: 0)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func detailedReportPressed(_ sender: UIButton) {
        let dicBody = self.dicScoreCardDetails["body"] as! NSDictionary
        let dicResult = dicBody["results"] as! NSDictionary
        let detailedView = self.storyboard?.instantiateViewController(withIdentifier: "DetailedViewVC") as! OFADetailedReportViewController
        if isAssessment{
            detailedView.webURLString = URL_ASSESSMENT + "\(dicResult["attempt_id"]!)"
        }else if isChallenge{
            detailedView.webURLString = URL_CHALLENGE_ZONE + "\(dicResult["attempt_id"]!)"
        }else if isAssessment{
            detailedView.webURLString = URL_USER_GENERATED_TEST + "\(dicResult["attempt_id"]!)"
        }
        self.navigationController?.pushViewController(detailedView,animated: true)
    }
}
