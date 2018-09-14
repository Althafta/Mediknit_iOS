//
//  OFAGenerateTestSelectionViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/13/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAGenerateTestSelectionViewController: UIViewController,didItemSelected {
    
    @IBOutlet var buttonCategory: UIButton!
    @IBOutlet var buttonDifficulty: UIButton!
    @IBOutlet var buttonTopics: UIButton!
    @IBOutlet var buttonDuration: UIButton!
    
    @IBOutlet var buttonCancel: UIButton!
    @IBOutlet var buttonGenerate: UIButton!
    
    var arraySelectedTopics = NSMutableArray()
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    
    var arrayCategories = NSMutableArray()
    var arrayDifficulty = NSMutableArray()
    var arrayTopics = NSMutableArray()
    var arrayDuration = NSMutableArray()
    
    var selectedCategoryId = ""
    var selectedDuration = ""
    var selectedDifficultyMode = ""
    var selectedTopics = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
//        self.navigationController?.navigationBar.barTintColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
        
        self.buttonCategory.layer.borderWidth = 1.0
        self.buttonCategory.layer.borderColor = OFAUtils.getColorFromHexString("484d4d").cgColor
        self.buttonDifficulty.layer.borderWidth = 1.0
        self.buttonDifficulty.layer.borderColor = OFAUtils.getColorFromHexString("484d4d").cgColor
        self.buttonTopics.layer.borderWidth = 1.0
        self.buttonTopics.layer.borderColor = OFAUtils.getColorFromHexString("484d4d").cgColor
        self.buttonDuration.layer.borderWidth = 1.0
        self.buttonDuration.layer.borderColor = OFAUtils.getColorFromHexString("484d4d").cgColor
        
        self.buttonCategory.layer.cornerRadius = self.buttonCategory.frame.height/2
        self.buttonDifficulty.layer.cornerRadius = self.buttonDifficulty.frame.height/2
        self.buttonTopics.layer.cornerRadius = self.buttonTopics.frame.height/2
        self.buttonDuration.layer.cornerRadius = self.buttonDuration.frame.height/2
        
        self.buttonCancel.layer.cornerRadius = self.buttonCancel.frame.height/2
        self.buttonGenerate.layer.cornerRadius = self.buttonGenerate.frame.height/2
        
        self.getCategoryList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        //        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.title = "Generate Test"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK:- Button Actions
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        let listItem = self.storyboard?.instantiateViewController(withIdentifier:"GenerateTestItemListTVC") as! OFAGenerateTestItemListTableViewController
        self.navigationItem.title = "Select Category"
        
        listItem.isTopics = false
        listItem.isCategory = true
        listItem.isDifficulty = false
        listItem.isDuration = false
        
        listItem.delegate=self
        listItem.arrayItems = self.arrayCategories
        self.navigationController?.pushViewController(listItem, animated: true)
    }
    
    @IBAction func difficultyPressed(_ sender: UIButton) {
        let listItem = self.storyboard?.instantiateViewController(withIdentifier:"GenerateTestItemListTVC") as! OFAGenerateTestItemListTableViewController
        self.navigationItem.title = "Select Difficulty"
        
        listItem.delegate=self
        
        listItem.isTopics = false
        listItem.isCategory = false
        listItem.isDifficulty = true
        listItem.isDuration = false
        
        listItem.arrayItems = self.arrayDifficulty
        self.navigationController?.pushViewController(listItem, animated: true)
    }
    
    @IBAction func topicsPressed(_ sender: UIButton) {
        let listItem = self.storyboard?.instantiateViewController(withIdentifier:"GenerateTestItemListTVC") as! OFAGenerateTestItemListTableViewController
        self.navigationItem.title = "Select Topics"
        
        listItem.delegate=self
        
        listItem.isTopics = true
        listItem.isCategory = false
        listItem.isDifficulty = false
        listItem.isDuration = false
        
        listItem.arraySelectedTopics = self.arraySelectedTopics
        
        listItem.arrayItems = self.arrayTopics
        self.navigationController?.pushViewController(listItem, animated: true)
    }
    
    @IBAction func durationPressed(_ sender: UIButton) {
        let listItem = self.storyboard?.instantiateViewController(withIdentifier:"GenerateTestItemListTVC") as! OFAGenerateTestItemListTableViewController
        self.navigationItem.title = "Select Duration"
        
        listItem.delegate=self
        
        listItem.isTopics = false
        listItem.isCategory = false
        listItem.isDifficulty = false
        listItem.isDuration = true
        
        listItem.arrayItems = self.arrayDuration
        self.navigationController?.pushViewController(listItem, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func generateTestPressed(_ sender: UIButton) {
        if self.selectedCategoryId == "" || self.selectedDifficultyMode == "" || self.selectedTopics.count <= 0 || self.selectedDuration == "" {
            OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Missing", message: "Every fields must be selected", cancelButtonTitle: "OK")
            return
        }
        let dicParameters = NSDictionary(objects: [self.selectedCategoryId,self.selectedDuration,self.selectedTopics,self.selectedDifficultyMode,self.user_id,self.domainKey,self.accessToken], forKeys: ["category_id" as NSCopying,"duration" as NSCopying,"assessment_category" as NSCopying,"mode" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/generate_test_and_get_usergenerated_questions", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let dicGeneratedTest = dicBody["generated_challenge"] as! NSDictionary
                let duration = "\(dicGeneratedTest["uga_duration"]!)"
                let generateTestID = "\(dicGeneratedTest["id"]!)"
                let arrayQuestions = dicGeneratedTest["questions"] as! NSArray
                let assessmentVC = self.storyboard?.instantiateViewController(withIdentifier: "AssessmentContainerVC") as! OFAAssessmentContainerViewController
                assessmentVC.instructionString = "\(dicBody["instructions"]!)"
                assessmentVC.seconds = Int(duration)! * 60
                assessmentVC.totalDuration = Int(duration)! * 60
                assessmentVC.generateTestID = generateTestID
                self.navigationItem.title = "\(dicGeneratedTest["uga_title"]!)"
                assessmentVC.arrayQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
                //                assessmentVC.arrayOriginalQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
//                UserDefaults.standard.setValue(arrayQuestions.mutableCopy() as! NSMutableArray, forKey: "OriginalAssessmentQuestions")
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: arrayQuestions.mutableCopy() as! NSMutableArray), forKey: "OriginalAssessmentQuestions")
                self.navigationController?.pushViewController(assessmentVC, animated: true)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Generate Test Helpers
    
    func getCategoryList(){
        let dicParameters = NSDictionary(objects: [self.user_id,self.domainKey,self.accessToken], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/list_all_categories", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let arrCategories = dicBody["categories"] as! NSArray
                if arrCategories.count > 0 {
                    for item in arrCategories{
                        let dicCategories = item as! NSDictionary
                        self.arrayCategories.add(dicCategories)
                    }
                    OFAUtils.removeLoadingView(nil)
                }else{
                    OFAUtils.removeLoadingView(nil)
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
    
    func getDetails(using categoryId:String){
        let dicParameters = NSDictionary(objects: [self.user_id,categoryId,self.domainKey,self.accessToken], forKeys: ["user_id" as NSCopying,"category_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/user_generate_test_options", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let arrDifficulty = dicBody["difficulty"] as! NSArray
                if arrDifficulty.count > 0 {
                    for item in arrDifficulty{
                        let dicDifficulty = item as! NSDictionary
                        self.arrayDifficulty.add(dicDifficulty)
                    }
                    OFAUtils.removeLoadingView(nil)
                }else{
                    OFAUtils.removeLoadingView(nil)
                }
                
                let arrTopics = dicBody["topics"] as! NSArray
                if arrTopics.count > 0 {
                    for item in arrTopics{
                        let dicTopics = item as! NSDictionary
                        self.arrayTopics.add(dicTopics)
                    }
                    OFAUtils.removeLoadingView(nil)
                }else{
                    OFAUtils.removeLoadingView(nil)
                }
                
                let arrDuration = dicBody["duration"] as! NSArray
                if arrDuration.count > 0 {
                    for item in arrDuration{
                        let dicDuration = item as! NSDictionary
                        self.arrayDuration.add(dicDuration)
                    }
                    OFAUtils.removeLoadingView(nil)
                }else{
                    OFAUtils.removeLoadingView(nil)
                }
                
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Item Selection Delegate
    
    func getSelectedCategory(dicCategory:NSDictionary){
        self.buttonCategory.setTitle("\(dicCategory["ct_name"]!)", for: .normal)
        
        self.arrayDifficulty.removeAllObjects()
        self.arrayTopics.removeAllObjects()
        self.arrayDuration.removeAllObjects()
        self.selectedCategoryId = "\(dicCategory["id"]!)"
        self.getDetails(using: "\(dicCategory["id"]!)")
    }
    
    func getSelectedDifficulty(dicItem: NSDictionary) {
        self.selectedDifficultyMode = "\(dicItem["type"]!)"
        self.buttonDifficulty.setTitle("\(dicItem["level"]!)", for: .normal)
    }
    
    func getSelectedDuration(dicItem: NSDictionary, position: String) {
        self.selectedDuration = position
        self.buttonDuration.setTitle("\(dicItem["time"]!)", for: .normal)
    }
    
    func getSelectedTopics(arrayTopicsSelected: NSMutableArray) {
        self.arraySelectedTopics = arrayTopicsSelected
        var arraySelectedTopicString = [String]()
        for item in arrayTopicsSelected{
            let dicDetails = item as! NSDictionary
            arraySelectedTopicString.append("\(dicDetails["qc_category_name"]!)")
            self.selectedTopics.append("\(dicDetails["id"]!)")
        }
        self.buttonTopics.setTitle(arraySelectedTopicString.joined(separator: ","), for: .normal)
    }
    
}
