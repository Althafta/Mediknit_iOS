//
//  OFAAssessmentContainerViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/29/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift
import WebKit
import Alamofire

class OFAAssessmentContainerViewController: UIViewController,AssessmentAnswerDelegate,didSelectRandomQuestionFromList,didAttendAgainSelectedDelegate {

    //MARK:- View Outlets
    @IBOutlet var buttonPrevious: UIButton!
    @IBOutlet var buttonNext: UIButton!
    @IBOutlet var buttonReviseLater: UIButton!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var labelQuestionHeading: UILabel!
    @IBOutlet var instructionPopUpView: UIView!

    @IBOutlet var webViewInstructions: UIWebView!
    @IBOutlet var buttonProceed: UIButton!
    @IBOutlet var buttonCancel: UIButton!
    //MARK:- Submit Popup Outlets
    @IBOutlet var viewSubmitPopUp: UIView!
    @IBOutlet var viewTimerBackGround: UIView!
    @IBOutlet var viewAnsweredBG: UIView!
    @IBOutlet var viewReviseLaterBG: UIView!
    @IBOutlet var viewSkippedBG: UIView!
    @IBOutlet var viewUnAttemptedBG: UIView!
    
    @IBOutlet var labelTimerCount: UILabel!
    @IBOutlet var labelAnsweredCount: UILabel!
    @IBOutlet var labelReviseLaterCount: UILabel!
    @IBOutlet var labelSkippedCount: UILabel!
    @IBOutlet var labelUnAttemptedCount: UILabel!
    
    @IBOutlet var buttonReviewTest: UIButton!
    @IBOutlet var buttonSubmitTest: UIButton!
    
    @IBOutlet var labelCountDownTimer: UILabel!
    
    //MARK:- Variables
    
    var arrayQuestions = NSMutableArray()
    var arrayOriginalQuestions = NSMutableArray()
    var questionTag = 0
    var questionNumber = 1
    var instructionString = ""
    
    var lectureID = ""
    var assessmentID = ""
    var challengeID = ""
    var generateTestID = ""
    
    var isAssessment = true
    var isChallenge = true
    var isGenerateTest = true
    
    var seconds = 60
    var timer = Timer()
    var totalDuration = Int()
    var statusCount = 0
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    var isExamCompleted = false
    
    lazy var assessmentTVC: OFAAssessmentQuestionTableViewController? = {
        let assessmentTVC = self.storyboard?.instantiateViewController(withIdentifier: "AssessmentTVC") as! OFAAssessmentQuestionTableViewController
        return assessmentTVC
    }()
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.slideMenuController()?.removeLeftGestures()
        self.webViewInstructions.loadHTMLString(self.instructionString, baseURL: nil)
        self.showInstructionPopUp()
        blur()
        animateIn()
        
        self.buttonProceed.layer.cornerRadius = self.buttonProceed.frame.height/2
        self.buttonCancel.layer.cornerRadius = self.buttonProceed.frame.height/2
        
        let stringVar = String()
        let fontVar = UIFont(fa_fontSize: 25)
        let faType1 = stringVar.fa.fontAwesome(.fa_chevron_left)
        let faType2 = stringVar.fa.fontAwesome(.fa_chevron_right)
        
        self.buttonPrevious.titleLabel?.font = fontVar
        self.buttonPrevious.setTitle(" \(faType1)", for: .normal)
        
        self.buttonNext.titleLabel?.font = fontVar
        self.buttonNext.setTitle(" \(faType2)", for: .normal)
        
        if self.arrayQuestions.count == 1 {
            self.buttonNext.isHidden = true
            self.buttonPrevious.isHidden = true
        }
        self.buttonPrevious.isHidden=true
        self.questionNumber = self.arrayQuestions.count-(self.arrayQuestions.count-1)
        self.getHeading(questionNumber: self.questionNumber)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_menu_black_24dp"), style: .plain, target: self, action: #selector(self.questionListPressed))
        
        for i in 0..<self.arrayQuestions.count {
            var dicQuestion = self.arrayQuestions[i] as! Dictionary<String,Any>
            dicQuestion["time_taken"] = "1"
            dicQuestion["q_status"] = "" // 0-Answered, 1-ReviseLater, 2-Attended
            dicQuestion["isAnswered"]="0"
            dicQuestion["selected_option_id"] = ""
            dicQuestion["selected_options"] = []
            dicQuestion["descriptive_answer"] = "Give your Answer"
            
            self.arrayQuestions.replaceObject(at: i, with: dicQuestion)
        }
        self.assessmentTVC?.tableView.reloadData()
//        self.displayAssessmentQuestions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OFAUtils.lockOrientation(.portrait)
        OFAUtils.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //MARK:- Helper Functions
    
    @objc func questionListPressed(){
        let questionList = self.storyboard?.instantiateViewController(withIdentifier: "AssessmentQuestionList") as! OFAAssessmentQuestionListTableViewController
        questionList.arrayQuestions = self.arrayQuestions
        questionList.delegate = self
        let nav = UINavigationController(rootViewController: questionList)
        self.present(nav, animated: true, completion: nil)
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateLabel(){
        seconds -= 1
        var durationString = ""
        let duration = self.getDuration(seconds: seconds)
        if duration[0] > 0 {
            durationString = "\(duration[0]):\(duration[1]):\(duration[2])"
        }else if duration[1] > 0 {
            durationString = "00:\(duration[1]):\(duration[2])"
        }else if duration[2] >= 0 {
            durationString = "00:00:\(duration[2])"
        }
        self.labelCountDownTimer.textColor = UIColor.white
        self.labelCountDownTimer.text = OFAUtils.getStringFromDate(OFAUtils.getDateTimeFromString(durationString))
        self.labelTimerCount.text = self.labelCountDownTimer.text
        
        self.navigationItem.titleView = self.labelCountDownTimer
        if seconds <= 0 {
            timer.invalidate()
            self.labelCountDownTimer.text = "Time Over"
            self.buttonReviewTest.isHidden = true
            self.isExamCompleted = true
          
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ExamCompleted"), object: nil, userInfo: nil)
            self.assessmentTVC?.tableView.reloadData()
            
            removeBlur()
            animateOutSubmitPopUp()
            
            self.submitAssessmentToGetAssessmentResult()
        }
    }
    
    func getDuration(seconds:Int) -> [Int]{
        let hours = seconds/3600
        let minutes = (seconds%3600)/60
        let second = seconds % 60
        return [hours,minutes,second]
    }
    
    func showScoreCard(dicScoreCardDetails:NSDictionary){
        let scoreCardTVC = self.storyboard?.instantiateViewController(withIdentifier: "AssessmentScoreCard") as! OFAAssessmentScoreCardTableViewController
        scoreCardTVC.dicScoreCardDetails = dicScoreCardDetails
        scoreCardTVC.lectureID = self.lectureID
        scoreCardTVC.delegate = self
        scoreCardTVC.isAssessment = isAssessment
        scoreCardTVC.isChallenge = isChallenge
        scoreCardTVC.isGenerateTest = isGenerateTest
        self.navigationController?.pushViewController(scoreCardTVC, animated: true)
    }
    
    func displayAssessmentQuestions(){
        
        if let vc = assessmentTVC {
            removeBlur()
            animateOut()
            
            var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
            assessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
            assessmentTVC?.delegate = self
            assessmentTVC?.questionId = "\(dicQuestion["id"]!)"
            assessmentTVC?.currentTimer.invalidate()
            assessmentTVC?.initiateTimerForQuestion()
            
            if "\(dicQuestion["q_type"]!)" == "1"{
                assessmentTVC?.isSingleSelection = true
                assessmentTVC?.isDescriptiveType = false
                assessmentTVC?.isMultipleChoice = false
            }else if "\(dicQuestion["q_type"]!)" == "2"{
                assessmentTVC?.isMultipleChoice = true
                assessmentTVC?.isDescriptiveType = false
                assessmentTVC?.isSingleSelection = false
            }else if "\(dicQuestion["q_type"]!)" == "3"{
                assessmentTVC?.isDescriptiveType = true
                assessmentTVC?.isSingleSelection = false
                assessmentTVC?.isMultipleChoice = false
                if "\(dicQuestion["descriptive_answer"]!)" != "Give your Answer"{
                    assessmentTVC?.textViewDescription.text = "\(dicQuestion["descriptive_answer"]!)"
                }else{
                    assessmentTVC?.textViewDescription.text = "Give your Answer"
                }
            }
            if "\(dicQuestion["q_status"]!)" == ""{
                dicQuestion["q_status"] = "2"
            }
            assessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
            self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
            
            assessmentTVC?.dicQuestion = dicQuestion 
            if let arrayOption = dicQuestion["options"] as? NSArray{
                assessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
            }
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.viewContainer.bounds
            self.viewContainer.addSubview(vc.view)
        }
    }
    
    //MARK:- Helper Functions
    
    func getHeading(questionNumber:Int){
        self.labelQuestionHeading.text = "Question \(questionNumber) / \(self.arrayQuestions.count)"
    }
    
    //MARK:- Button Actions
    
    @IBAction func previousQuestionAction(_ sender: UIButton) {
        self.questionTag -= 1
        self.questionNumber -= 1
        if self.questionTag == 0 {
            self.buttonPrevious.isHidden = true
        }
        self.buttonReviseLater.isSelected = false
        self.buttonNext.isHidden = false
        self.getHeading(questionNumber: self.questionNumber)
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        assessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
        assessmentTVC?.delegate = self
        assessmentTVC?.questionId = "\(dicQuestion["id"]!)"
        assessmentTVC?.currentTimer.invalidate()
//        assessmentTVC?.currentTimePeriod = 1
        assessmentTVC?.initiateTimerForQuestion()
        
        if "\(dicQuestion["q_type"]!)" == "1"{
            assessmentTVC?.isSingleSelection = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isMultipleChoice = false
        }else if "\(dicQuestion["q_type"]!)" == "2"{
            assessmentTVC?.isMultipleChoice = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isSingleSelection = false
        }else if "\(dicQuestion["q_type"]!)" == "3"{
            if "\(dicQuestion["descriptive_answer"]!)" != "Give your Answer"{
                assessmentTVC?.textViewDescription.text = "\(dicQuestion["descriptive_answer"]!)"
            }
            assessmentTVC?.isDescriptiveType = true
            assessmentTVC?.isSingleSelection = false
            assessmentTVC?.isMultipleChoice = false
        }
        
        if "\(dicQuestion["q_status"]!)" == ""{
            dicQuestion["q_status"] = "2"
        }
        if "\(dicQuestion["q_status"]!)" == "1"{
            self.buttonReviseLater.isSelected = true
        }
        
        assessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
        
        assessmentTVC?.dicQuestion = dicQuestion
        if let arrayOption = dicQuestion["options"] as? NSArray{
            assessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
        }else{
            assessmentTVC?.arrayOptions.removeAllObjects()
        }
        self.assessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }
    
    @IBAction func reviseLaterPressed(_ sender: UIButton) {
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        if self.buttonReviseLater.isSelected{
            self.buttonReviseLater.isSelected = false
            if "\(dicQuestion["isAnswered"]!)" == "1"{
                dicQuestion["isAnswered"] = "1"
                dicQuestion["q_status"] = "0"
            }else{
                dicQuestion["isAnswered"] = "0"
                dicQuestion["q_status"] = "2"
            }
        }else{
            self.buttonReviseLater.isSelected = true//dicQuestion["isAnswered"]="0"
            dicQuestion["q_status"] = "1"
            if "\(dicQuestion["isAnswered"]!)" == "1"{
                dicQuestion["isAnswered"] = "1"
            }else{
                dicQuestion["isAnswered"] = "0"
            }
        }
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
    }
    
    @IBAction func nextQuestionPressed(_ sender: UIButton) {
        if self.questionNumber == self.arrayQuestions.count-1{
            self.buttonNext.isHidden = true
        }
        self.buttonPrevious.isHidden=false
        self.buttonReviseLater.isSelected = false
        self.questionNumber += 1
        self.questionTag += 1
        self.getHeading(questionNumber: self.questionNumber)
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        assessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
        assessmentTVC?.delegate = self
        assessmentTVC?.questionId = "\(dicQuestion["id"]!)"
        assessmentTVC?.currentTimer.invalidate()
//        assessmentTVC?.currentTimePeriod = 1
        assessmentTVC?.initiateTimerForQuestion()
        
        if "\(dicQuestion["q_type"]!)" == "1"{
            assessmentTVC?.isSingleSelection = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isMultipleChoice = false
            
        }else if "\(dicQuestion["q_type"]!)" == "2"{
            assessmentTVC?.isMultipleChoice = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isSingleSelection = false
        }else if "\(dicQuestion["q_type"]!)" == "3"{
            if "\(dicQuestion["descriptive_answer"]!)" != "Give your Answer"{
                assessmentTVC?.textViewDescription.text = "\(dicQuestion["descriptive_answer"]!)"
            }
            assessmentTVC?.isDescriptiveType = true
            assessmentTVC?.isSingleSelection = false
            assessmentTVC?.isMultipleChoice = false
        }
        if "\(dicQuestion["q_status"]!)" == ""{
            dicQuestion["q_status"] = "2"
        }
        if "\(dicQuestion["q_status"]!)" == "1"{
            self.buttonReviseLater.isSelected = true
        }
        assessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
        assessmentTVC?.dicQuestion = dicQuestion
        if let arrayOption = dicQuestion["options"] as? NSArray{
            assessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
        }else{
            assessmentTVC?.arrayOptions.removeAllObjects()
        }
        self.assessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        removeBlur()
        animateOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func proceedPressed(_ sender: UIButton) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(self.submitAssessmentPressed))
        self.displayAssessmentQuestions()
        self.runTimer()
    }
    
    @IBAction func reviewTestPressed(_ sender: UIButton) {
        removeBlur()
        animateOutSubmitPopUp()
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        assessmentTVC?.currentTimer.invalidate()
//        assessmentTVC?.currentTimePeriod = 1
        self.submitAssessmentToGetAssessmentResult()
    }
    
    func submitAssessmentToGetAssessmentResult(){
        assessmentTVC?.currentTimer.invalidate()
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicSelectedOptions = NSMutableDictionary()
        let dicSelectedAnswerTimeLog = NSMutableDictionary()
        
        for item in self.arrayQuestions{
            let dicQuestion = item as! NSDictionary
            if "\(dicQuestion["q_type"]!)" == "1"{
                if "\(dicQuestion["isAnswered"]!)" == "1"{
                    dicSelectedOptions.setValue("\(dicQuestion["selected_option_id"]!)", forKey: "\(dicQuestion["id"]!)")
                    dicSelectedAnswerTimeLog.setValue("\(dicQuestion["time_taken"]!)", forKey: "\(dicQuestion["id"]!)")
                }
            }else if "\(dicQuestion["q_type"]!)" == "2"{
                if "\(dicQuestion["isAnswered"]!)" == "1"{
                    if let arraySelectedOptions = dicQuestion["selected_options"] as? NSArray{
                        let selectedOptions = arraySelectedOptions.componentsJoined(by: ",")
                        dicSelectedOptions.setValue(selectedOptions, forKey: "\(dicQuestion["id"]!)")
                        dicSelectedAnswerTimeLog.setValue("\(dicQuestion["time_taken"]!)", forKey: "\(dicQuestion["id"]!)")
                    }
                }
            }else if "\(dicQuestion["q_type"]!)" == "3"{
                if "\(dicQuestion["descriptive_answer"]!)" != "Give your Answer"{
                    dicSelectedOptions.setValue("\(dicQuestion["descriptive_answer"]!)", forKey: "\(dicQuestion["id"]!)")
                }
            }
        }
        let assessmentDuration = self.totalDuration - seconds
        var id = ""
        var parameter = ""
        var apiKey = ""
        if self.assessmentID != ""{
            id = self.assessmentID
            parameter = "assessment_id"
            apiKey = "api/course/save_user_assesment"
            self.isAssessment = true
            self.isChallenge = false
            self.isGenerateTest = false
        }else if self.challengeID != ""{
            id = self.challengeID
            parameter = "challenge_id"
            apiKey = "api/course/save_challenge"
            self.isAssessment = false
            self.isChallenge = true
            self.isGenerateTest = false
        }else if self.generateTestID != ""{
            id = self.generateTestID
            parameter = "exam_id"
            apiKey = "api/course/save_usergeneratedtest"
            self.isAssessment = false
            self.isChallenge = false
            self.isGenerateTest = true
        }
        let dicParameters = NSDictionary(objects: [domainKey,user_id,id,"\(assessmentDuration)",dicSelectedOptions,dicSelectedAnswerTimeLog,accessToken], forKeys: ["domain_key" as NSCopying,"user_id" as NSCopying,parameter as NSCopying,"time_taken" as NSCopying,"answers" as NSCopying,"answer_time_log" as NSCopying,"token" as NSCopying,])
        
        Alamofire.request(userBaseURL+apiKey, method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                self.removeBlur()
                self.animateOutSubmitPopUp()
                self.timer.invalidate()
                self.assessmentTVC?.currentTimer.invalidate()
                //temporary support
                //            self.slideMenuController()?.addLeftGestures()
                //            _ = self.navigationController?.popViewController(animated: true)
                if "\(dicResult["message"]!)" == "Assesment under validation"{
                    let validationAlert = UIAlertController(title: "Success", message: "Assesment under validation, You can view your results under 'Results' tab after verification!", preferredStyle: .alert)
                    validationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.saveLectureProgress()
                        _ = self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(validationAlert, animated: true, completion: nil)
                }else{
                    self.showScoreCard(dicScoreCardDetails:dicResult)
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
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
    
    @objc func submitAssessmentPressed(){
        self.customizeSubmitPopUp()
        self.isExamCompleted = true
        self.showSubmitPopUp()
        blur()
        animateInSubmitPopUp()
    }
    
    func customizeSubmitPopUp(){
        self.viewTimerBackGround.layer.cornerRadius = self.viewTimerBackGround.frame.size.height/2
        self.viewAnsweredBG.layer.cornerRadius = self.viewAnsweredBG.frame.size.height/2
        self.viewSkippedBG.layer.cornerRadius = self.viewSkippedBG.frame.size.height/2
        self.viewReviseLaterBG.layer.cornerRadius = self.viewReviseLaterBG.frame.size.height/2
        self.viewUnAttemptedBG.layer.cornerRadius = self.viewUnAttemptedBG.frame.size.height/2
        self.viewUnAttemptedBG.layer.borderColor = OFAUtils.getColorFromHexString(ofabeeCellBackground).cgColor
        self.viewUnAttemptedBG.layer.borderWidth = 1.0
        
        self.buttonReviewTest.layer.cornerRadius = self.buttonReviewTest.frame.size.height/2
        self.buttonSubmitTest.layer.cornerRadius = self.buttonSubmitTest.frame.size.height/2
        
        self.labelTimerCount.text = self.labelCountDownTimer.text
        var answeredCount = 0
        var skippedCount = 0
        var reviseLaterCount = 0
//        var unAttemptedCount = 0
        for item in self.arrayQuestions{
            let dicQuestion = item as! NSDictionary
            if "\(dicQuestion["q_status"]!)" == "0"{
                answeredCount += 1
            }else if "\(dicQuestion["q_status"]!)" == "1"{
                reviseLaterCount += 1
            }else if "\(dicQuestion["q_status"]!)" == "2"{
                skippedCount += 1
            }
        }
        self.labelAnsweredCount.text = "\(answeredCount)"
        self.labelSkippedCount.text = "\(skippedCount)"
        self.labelReviseLaterCount.text = "\(reviseLaterCount)"
        self.labelUnAttemptedCount.text = "\(self.arrayQuestions.count-(answeredCount+skippedCount+reviseLaterCount))" 
    }
    
    
    //MARK:- Assessment Answer Delegate
    
    //single
    func replaceQuestionArray(with arrayNewOptions: NSArray, selectedOption: String) {
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        dicQuestion["options"] = arrayNewOptions
        dicQuestion["selected_option_id"] = selectedOption
        dicQuestion["q_status"] = "0"
        dicQuestion["isAnswered"]="1"
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
    }
    //multiple
    func replaceQuestionArray(with selectedOptions: NSArray, answerStatus: String) {
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        dicQuestion["selected_options"] = selectedOptions
        dicQuestion["q_status"] = answerStatus
        dicQuestion["isAnswered"]="1"
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
    }
    //Descriptive
    func replaceQuestionArrayWithDescriptiveAnswer(answer: String) {
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        dicQuestion["descriptive_answer"] = answer
        dicQuestion["q_status"] = "0"
        dicQuestion["isAnswered"]="1"
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
    }
    
    //MARK:- QuestionList Delegate
    
    func sendQuestionTagSelected(selectedTag: Int) {
        self.questionTag = selectedTag
        self.questionNumber = self.questionTag+1
        if self.questionNumber == self.arrayQuestions.count{
            self.buttonNext.isHidden = true
            self.buttonPrevious.isHidden=false
        }
        if self.questionNumber == 1{
            self.buttonNext.isHidden = false
            self.buttonPrevious.isHidden=true
        }
        self.buttonReviseLater.isSelected = false
        self.getHeading(questionNumber: self.questionNumber)
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        assessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
        assessmentTVC?.delegate = self
        assessmentTVC?.questionId = "\(dicQuestion["id"]!)"
        assessmentTVC?.currentTimer.invalidate()
        assessmentTVC?.initiateTimerForQuestion()
        
        if "\(dicQuestion["q_type"]!)" == "1"{
            assessmentTVC?.isSingleSelection = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isMultipleChoice = false
        }else if "\(dicQuestion["q_type"]!)" == "2"{
            assessmentTVC?.isMultipleChoice = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isSingleSelection = false
        }else if "\(dicQuestion["q_type"]!)" == "3"{
            assessmentTVC?.isDescriptiveType = true
            assessmentTVC?.isSingleSelection = false
            assessmentTVC?.isMultipleChoice = false
            if "\(dicQuestion["descriptive_answer"]!)" != "Give your Answer"{
                assessmentTVC?.textViewDescription.text = "\(dicQuestion["descriptive_answer"]!)"
            }else{
                assessmentTVC?.textViewDescription.text = "Give your Answer"
            }
        }
        if "\(dicQuestion["q_status"]!)" == ""{
            dicQuestion["q_status"] = "2"
        }
        if "\(dicQuestion["q_status"]!)" == "1"{
            self.buttonReviseLater.isSelected = true
        }
        assessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
        
        assessmentTVC?.dicQuestion = dicQuestion
        if let arrayOption = dicQuestion["options"] as? NSArray{
            assessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
        }
        self.assessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }
    
    //MARK:- Attend Again Delegate
    
    func attendAgainSelected(selectedTag: Int) {
        seconds = totalDuration
        self.runTimer()
        self.questionTag = selectedTag
        self.questionNumber = self.questionTag+1
        self.arrayQuestions.removeAllObjects()
        var arrayQnz = NSArray()
        if let heroObject = UserDefaults.standard.value(forKey: "OriginalAssessmentQuestions") as? NSData {
           arrayQnz  = NSKeyedUnarchiver.unarchiveObject(with: heroObject as Data) as! NSArray
        }
//        let arrayQnz = UserDefaults.standard.value(forKey: "OriginalAssessmentQuestions") as! NSArray
        self.arrayOriginalQuestions = arrayQnz.mutableCopy() as! NSMutableArray
        self.arrayQuestions = self.arrayOriginalQuestions

        self.arrayOriginalQuestions = self.arrayQuestions
        if self.questionNumber == self.arrayQuestions.count{
            self.buttonNext.isHidden = true
            self.buttonPrevious.isHidden=false
        }
        if self.questionNumber == 1{
            self.buttonNext.isHidden = false
            self.buttonPrevious.isHidden=true
        }
        self.buttonReviseLater.isSelected = false
        self.getHeading(questionNumber: self.questionNumber)
        for i in 0..<self.arrayQuestions.count {
            var dicQuestion = self.arrayQuestions[i] as! Dictionary<String,Any>
            dicQuestion["time_taken"] = "1"
            dicQuestion["q_status"] = "" // 0-Answered, 1-ReviseLater, 2-Attended
            dicQuestion["isAnswered"]="0"
            dicQuestion["selected_option_id"] = ""
            dicQuestion["selected_options"] = []
            dicQuestion["descriptive_answer"] = "Give your Answer"
            
            self.arrayQuestions.replaceObject(at: i, with: dicQuestion)
        }
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        assessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
        assessmentTVC?.delegate = self
        assessmentTVC?.questionId = "\(dicQuestion["id"]!)"
        assessmentTVC?.currentTimer.invalidate()
        assessmentTVC?.initiateTimerForQuestion()
        
        
        
        if "\(dicQuestion["q_type"]!)" == "1"{
            assessmentTVC?.isSingleSelection = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isMultipleChoice = false
        }else if "\(dicQuestion["q_type"]!)" == "2"{
            assessmentTVC?.isMultipleChoice = true
            assessmentTVC?.isDescriptiveType = false
            assessmentTVC?.isSingleSelection = false
        }else if "\(dicQuestion["q_type"]!)" == "3"{
            assessmentTVC?.isDescriptiveType = true
            assessmentTVC?.isSingleSelection = false
            assessmentTVC?.isMultipleChoice = false
            if "\(dicQuestion["descriptive_answer"]!)" != "Give your Answer"{
                assessmentTVC?.textViewDescription.text = "\(dicQuestion["descriptive_answer"]!)"
            }else{
                assessmentTVC?.textViewDescription.text = "Give your Answer"
            }
        }
        if "\(dicQuestion["q_status"]!)" == ""{
            dicQuestion["q_status"] = "2"
        }
        if "\(dicQuestion["q_status"]!)" == "1"{
            self.buttonReviseLater.isSelected = true
        }
        assessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
        
        assessmentTVC?.dicQuestion = dicQuestion
        if let arrayOption = dicQuestion["options"] as? NSArray{
            assessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
        }
        self.assessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }
    
    //MARK:- iPopUp Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OFAUtils.lockOrientation(.portrait)
        instructionPopUpView.setNeedsFocusUpdate()
        self.viewSubmitPopUp.setNeedsFocusUpdate()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        
        instructionPopUpView.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)!-((rootView?.frame.height)!/4)))
        instructionPopUpView.center = view.center
        
        self.viewSubmitPopUp.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)!-((rootView?.frame.height)!/4)))
        self.viewSubmitPopUp.center = view.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if touches.first != nil{
            if isExamCompleted{
//                removeBlur()
//                animateOutSubmitPopUp()
            }else{
                removeBlur()
                animateOut()
            }
        }
    }
    
    @objc func touchesView(){//tapAction
        
        if isExamCompleted{
//            removeBlur()
//            animateOutSubmitPopUp()
        }else{
            removeBlur()
            animateOut()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        OFAUtils.lockOrientation(.allButUpsideDown)
        removeBlur()
        animateOut()
    }
    
    public func removeBlur() {
        blurEffectView.removeFromSuperview()
    }
    
    func showSubmitPopUp(){
        if !OFAUtils.isiPhone(){
            instructionPopUpView.frame.origin.x = 0
            instructionPopUpView.frame.origin.y = 0
        }
        else{
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            if GlobalVariables.sharedManager.rotated() == true{
                self.viewSubmitPopUp.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/4)))
            }
            else {
                self.viewSubmitPopUp.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/4)))
            }
        }
        self.viewSubmitPopUp.layer.cornerRadius = 10 //make oval view edges
    }
    
    func showInstructionPopUp(){
        if !OFAUtils.isiPhone(){
            instructionPopUpView.frame.origin.x = 0
            instructionPopUpView.frame.origin.y = 0
        }
        else{
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            if GlobalVariables.sharedManager.rotated() == true{
                instructionPopUpView.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/4)))
            }
            else {
                instructionPopUpView.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)! - ((rootView?.frame.height)!/4)))
            }
        }
        instructionPopUpView.layer.cornerRadius = 5 //make oval view edges
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
        //        self.view.addSubview(instructionPopUpView)
        rootView?.addSubview(instructionPopUpView)
        instructionPopUpView.center = (rootView?.center)!
        instructionPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        instructionPopUpView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.instructionPopUpView.alpha = 1
            self.instructionPopUpView.transform = CGAffineTransform.identity
        }
    }
    func animateInSubmitPopUp() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        //        self.view.addSubview(instructionPopUpView)
        rootView?.addSubview(self.viewSubmitPopUp)
        self.viewSubmitPopUp.center = (rootView?.center)!
        self.viewSubmitPopUp.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        self.viewSubmitPopUp.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.viewSubmitPopUp.alpha = 1
            self.viewSubmitPopUp.transform = CGAffineTransform.identity
        }
    }
    
    public func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.instructionPopUpView.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.instructionPopUpView.alpha = 0
        }) { (success:Bool) in
            self.instructionPopUpView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.instructionPopUpView.removeFromSuperview()
        }
    }
    public func animateOutSubmitPopUp () {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewSubmitPopUp.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.viewSubmitPopUp.alpha = 0
        }) { (success:Bool) in
            self.viewSubmitPopUp.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.viewSubmitPopUp.removeFromSuperview()
        }
    }
}
