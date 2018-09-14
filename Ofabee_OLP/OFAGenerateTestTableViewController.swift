//
//  OFAGenerateTestTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAGenerateTestTableViewController: UITableViewController {

//    lazy var generateTestVC: OFAGenerateTestSelectOptionViewController? = {
//        let generateTestVC = self.storyboard?.instantiateViewController(withIdentifier: "GenerateTestSelectOptionVC") as! OFAGenerateTestSelectOptionViewController
//        return generateTestVC
//    }()
    
    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var buttonPlus: UIButton!
//    @IBOutlet var popUpGenerateTest: UIView!
//
//    @IBOutlet var buttonCancel: UIButton!
//    @IBOutlet var buttonGenerate: UIButton!
    
    var arrayGeneratedTestResults = NSMutableArray()
    var offset = 1
    var index = 0
    var refreshController = UIRefreshControl()
    var selectedTest = ""
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    var blurEffectView = UIVisualEffectView()
    
    
    //Generate test variables
    var selectedCategoryId = ""
    var selectedDuration = ""
    var selectedDifficultyMode = ""
    var selectedTopics = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
        
        self.buttonPlus.clipsToBounds = true
        self.buttonPlus.layer.cornerRadius = self.buttonPlus.frame.width/2
        self.buttonPlus.dropShadow()
        
//        self.buttonCancel.layer.cornerRadius = self.buttonCancel.frame.height/2
//        self.buttonGenerate.layer.cornerRadius = self.buttonGenerate.frame.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Generate Test"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
        self.refreshInitiated()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        self.navigationItem.title = ""
//        removeBlur()
//        animateOut()
    }
    
    func refreshInitiated(){
        self.offset = 1
        self.index = 0
        
        self.arrayGeneratedTestResults.removeAllObjects()
        self.loadGeneratedTestResults(with: self.user_id, offset: self.offset, token: self.accessToken)
    }
    
    func loadGeneratedTestResults(with userID:String,offset:Int,token:String){
        if(index-1 >= self.arrayGeneratedTestResults.count) {
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [userID,"\(offset)",domainKey,token], forKeys: ["user_id" as NSCopying,"offset" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/user_generated_results", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                let arrGeneratedTest = dicBody["user_generated_attempts"] as! NSArray
                if arrGeneratedTest.count > 0 {
                    for item in arrGeneratedTest{
                        let dicGenerateTestDetails = item as! NSDictionary
                        self.arrayGeneratedTestResults.add(dicGenerateTestDetails)
                    }
                    self.refreshController.endRefreshing()
                    OFAUtils.removeLoadingView(nil)
                    self.tableView.reloadData()
                }else{
//                    self.arrayGeneratedTestResults.removeAllObjects()
                    OFAUtils.removeLoadingView(nil)
                    self.tableView.reloadData()
//                    OFAUtils.showToastWithTitle("No Results Found")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                self.refreshController.endRefreshing()
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayGeneratedTestResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenerateTestResultCell", for: indexPath) as! OFAGenerateTestResultsTableViewCell

        let dicGenerateTestDetails = self.arrayGeneratedTestResults[indexPath.row] as! NSDictionary
        
        let createTimeString = "\(dicGenerateTestDetails["uga_attempted_date"]!)"
        let createdDate = self.getDateFromString(createTimeString)
        let dateString = self.getStringFromDate(createdDate)
        
        var durationString = ""
        let duration = self.getDuration(seconds: Int("\(dicGenerateTestDetails["uga_duration"]!)")!)
        if duration[0] > 0 {
            durationString = "\(duration[0]) hr \(duration[1]) m \(duration[2]) s"
        }else if duration[1] > 0 {
            durationString = "\(duration[1]) m \(duration[2]) s"
        }else if duration[2] >= 0 {
            durationString = " \(duration[2]) s"
        }
        
        cell.customizeCellWithDetails(dateString: dateString, resultTitle: "\(dicGenerateTestDetails["uga_title"]!)", score: "Score \(dicGenerateTestDetails["total_mark"]!)", timeTaken: "Time Taken \(durationString)")

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dicGenerateTestDetails = self.arrayGeneratedTestResults[indexPath.row] as! NSDictionary
        
        self.selectedTest = "\(dicGenerateTestDetails["uga_title"]!)"
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.user_id,"\(dicGenerateTestDetails["id"]!)",domainKey,self.accessToken], forKeys: ["user_id" as NSCopying,"attempt_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/user_generated_test_report", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                if "\(dicResult["message"]!)" == "Invalid data!" {
                    let sessionAlert = UIAlertController(title: "Invalid Result", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if let dicBody = dicResult["body"] as? NSDictionary{
                    let scoreCard = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeScoreCard") as! OFAChallengeScoreCardTableViewController
                    scoreCard.dicScoreCardDetails = dicBody
                    scoreCard.isGenerateTest = true
                    scoreCard.navigationTitle = self.selectedTest
                    self.navigationController?.pushViewController(scoreCard, animated: true)
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                self.refreshController.endRefreshing()
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableFooterView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 97
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "   Previous test results"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row  == self.arrayGeneratedTestResults.count-1 {
            self.index = index + 10
            self.offset += 1
            self.loadGeneratedTestResults(with: self.user_id, offset: self.offset, token: self.accessToken)
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        let selectionVC = self.storyboard?.instantiateViewController(withIdentifier: "selectionVC") as! OFAGenerateTestSelectionViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(selectionVC, animated: true)
    }
    
    //MARK:- Helper Functions
    
    func getDuration(seconds:Int) -> [Int]{
        let hours = seconds/3600
        let minutes = (seconds%3600)/60
        let second = seconds % 60
        return [hours,minutes,second]
    }
    
    func getDateFromString(_ stringDate:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        let local = Locale(identifier: "en_US")
        dateFormatter.locale=local
        return dateFormatter.date(from: stringDate)!
    }
    
    func getStringFromDate(_ date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat="dd MMM"
        let local = Locale(identifier: "en_US")
        formatter.locale=local
        return formatter.string(from: date)
    }
}
