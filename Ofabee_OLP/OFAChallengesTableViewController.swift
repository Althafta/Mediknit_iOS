//
//  OFAChallengesTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

class OFAChallengesTableViewController: UITableViewController,HADropDownDelegate {

    @IBOutlet var viewDropDown: HADropDown!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet var buttonDropDown: UIButton!
    @IBOutlet var buttonChooseCategory: UIButton!
    
    var offset = 1
    var index = 0
    
    var selectedCategoryId = ""
    
    var arrayChallenges = NSMutableArray()
    var arrayCategories = NSMutableArray()
    var refreshController = UIRefreshControl()
    
    let chooseCategoryDropDown = DropDown()
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.viewDropDown.delegate = self
        self.viewDropDown.title = "Select a Category"
        self.viewDropDown.textAllignment = .left
        self.tableHeaderView.backgroundColor = OFAUtils.getColorFromHexString(backgroundColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Online Test"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        self.refreshController.tintColor = .white//OFAUtils.getColorFromHexString(barTintColor)
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshInitiated(){
        self.offset = 1
        self.index = 0
        self.buttonChooseCategory.setTitle("Select a Category", for: .normal)
//        self.arrayChallenges.removeAllObjects()
        self.loadChallenges(with: "", userID: self.user_id, offset: self.offset, token: self.accessToken)
    }
    
    func loadChallenges(with categoryId:String,userID:String,offset:Int,token:String){
        if(index-1 >= self.arrayChallenges.count) {
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [categoryId,userID,"\(offset)",domainKey,token], forKeys: ["category_id" as NSCopying,"user_id" as NSCopying,"offset" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/browse_challenges", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                if let arrCategories = dicBody["categories"] as? NSArray{
                    if arrCategories.count > 0 {
                        self.arrayCategories.removeAllObjects()
                        var arrayCategoryTitles = [String]()
                        for item in arrCategories{
                            let dicCategoryDetails = item as! NSDictionary
                            self.arrayCategories.add(dicCategoryDetails)
                            arrayCategoryTitles.append("\(dicCategoryDetails["ct_name"]!)")
                        }
//                        self.viewDropDown.items = arrayCategoryTitles
                        self.chooseCategoryDropDown.anchorView = self.buttonChooseCategory
                        self.chooseCategoryDropDown.bottomOffset = CGPoint(x: 0, y: self.buttonChooseCategory.bounds.height)
                        self.chooseCategoryDropDown.dataSource = arrayCategoryTitles
                        self.chooseCategoryDropDown.selectionAction = { [weak self] (index, item) in
                            
                            let dicCategory = self?.arrayCategories[index] as! NSDictionary
                            self?.selectedCategoryId = "\(dicCategory["id"]!)"
                            self?.buttonChooseCategory.setTitle("\(dicCategory["ct_name"]!)", for: .normal)
                            self?.arrayChallenges.removeAllObjects()
                            self?.tableView.reloadData()
                            self?.index = (self?.arrayChallenges.count)!-1
                            self?.loadChallenges(with: (self?.selectedCategoryId)!, userID: (self?.user_id)!, offset: 1, token: (self?.accessToken)!)
                        }
                    }else{
                        //                        OFAUtils.showToastWithTitle("Empty Categories")
                    }
                }
//
                let arrChallenges = dicBody["challenges"] as! NSArray
                if arrChallenges.count > 0 {
//                    self.arrayChallenges.removeAllObjects()
                    for item in arrChallenges{
                        let dicChallengeDetails = item as! NSDictionary
                        self.arrayChallenges.add(dicChallengeDetails)
                    }
                    self.refreshController.endRefreshing()
                    OFAUtils.removeLoadingView(nil)
                    self.tableView.reloadData()
                }else{
                    self.arrayChallenges.removeAllObjects()
                    OFAUtils.removeLoadingView(nil)
                    self.refreshController.endRefreshing()
                    self.tableView.reloadData()
                    OFAUtils.showToastWithTitle("Test Empty")
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
        return self.arrayChallenges.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyChallengesCell", for: indexPath) as! OFAChallengesListTableViewCell

        let dicChallengeDetails = self.arrayChallenges[indexPath.row] as! NSDictionary
        
        var endStatus = ""
        let endDate = self.getDateFromString("\(dicChallengeDetails["cz_end_date"]!)")
        let endTime = OFAUtils.getStringTimeFromDate(endDate)
        if endDate < Date(){
            endStatus = "Ended "
            cell.viewDateBackground.backgroundColor = OFAUtils.getColorFromHexString(materialRedColor)
        }else if endDate > Date(){
            endStatus = "Ends "
            cell.viewDateBackground.backgroundColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
        }
        let dateString = self.getStringFromDate(endDate)
        let arrayDateString = dateString.components(separatedBy: " ")
        
        cell.customizeCellWithDetails(endStatus: endStatus+"on", endDateStatus: endStatus+"at", endTime: endTime, endDate: arrayDateString[0], endMonth: arrayDateString[1], challengeTitle: "\(dicChallengeDetails["cz_title"]!)")

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewDropDown.isCollapsed = true
        viewDropDown.collapseTableView()
        let dicChallengeDetails = self.arrayChallenges[indexPath.row] as! NSDictionary
        if let dicChallengeStatus = dicChallengeDetails["challenge_status"] as? NSDictionary{
            self.getChallengeZoneQuestions(challenge_id: "\(dicChallengeStatus["id"]!)", challengeStatus: "\(dicChallengeStatus["status"]!)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        viewDropDown.isCollapsed = true
        viewDropDown.collapseTableView()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 87
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row  == self.arrayChallenges.count-1 {
            self.index = index + 10
            self.offset += 1
            self.loadChallenges(with: self.selectedCategoryId, userID: self.user_id, offset: self.offset, token: self.accessToken)
        }
    }
    
    //MARK:- Challenge helper
    
    func getChallengeZoneQuestions(challenge_id:String,challengeStatus:String){
        ///api/course/get_challenge_zone_questions
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [challenge_id,self.user_id,domainKey,self.accessToken], forKeys: ["challenge_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/get_challenge_zone_questions", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
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
                if challengeStatus == "1"{
                    //Assessment with answer explanation
                    print(challengeStatus+" show assessment with answers")
                    let dicBody = dicResult["body"] as! NSDictionary
                    let arrayQuestions = dicBody["questions"] as! NSArray
                    let challengeAssessmentVC = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeAssessmentContainerVC") as! OFAChallengeAssessmentContainerViewController
                    challengeAssessmentVC.arrayQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
                    self.navigationItem.title = "\(dicBody["cz_title"]!)"
                    self.navigationController?.pushViewController(challengeAssessmentVC, animated: true)
                }else if challengeStatus == "2"{
                    //ScoreCard
                    let scoreCard = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeScoreCard") as! OFAChallengeScoreCardTableViewController
                    scoreCard.dicScoreCardDetails = dicResult["body"] as! NSDictionary
                    scoreCard.isChallenge = true
                    let dicBody = dicResult["body"] as! NSDictionary
                    scoreCard.navigationTitle = "\(dicBody["cz_title"]!)"
                    self.navigationController?.pushViewController(scoreCard, animated: true)
                }else if challengeStatus == "3"{
                    //Attend Assessment
                    print(challengeStatus+" show assessment to answers")
                    let dicBody = dicResult["body"] as! NSDictionary
                    let duration = "\(dicBody["cz_duration"]!)"
                    let challengeID = "\(dicBody["id"]!)"
                    let arrayQuestions = dicBody["questions"] as! NSArray
                    let assessmentVC = self.storyboard?.instantiateViewController(withIdentifier: "AssessmentContainerVC") as! OFAAssessmentContainerViewController
                    assessmentVC.instructionString = "\(dicBody["instructions"]!)"
                    assessmentVC.seconds = Int(duration)! * 60
                    assessmentVC.totalDuration = Int(duration)! * 60
                    assessmentVC.challengeID = challengeID
//                    self.navigationItem.title = "\(dicBody["cz_title"]!)"
                    assessmentVC.arrayQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
                    //                assessmentVC.arrayOriginalQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
//                    UserDefaults.standard.setValue(arrayQuestions.mutableCopy() as! NSMutableArray, forKey: "OriginalAssessmentQuestions")
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: arrayQuestions.mutableCopy() as! NSMutableArray), forKey: "OriginalAssessmentQuestions")
                    self.navigationController?.pushViewController(assessmentVC, animated: true)
                }else if challengeStatus == "4"{
                    //Score card
                    let scoreCard = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeScoreCard") as! OFAChallengeScoreCardTableViewController
                    scoreCard.dicScoreCardDetails = dicResult["body"] as! NSDictionary
                    scoreCard.isChallenge = true
                    let dicBody = dicResult["body"] as! NSDictionary
                    scoreCard.navigationTitle = "\(dicBody["cz_title"]!)"
                    self.navigationController?.pushViewController(scoreCard, animated: true)
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func chooseCategoryPressed(_ sender: UIButton) {
        self.customizeDropDown(self)
        self.chooseCategoryDropDown.show()
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        let appearance = chooseCategoryDropDown
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        //        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 10
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
    }
    
    //MARK:- DropDown Delegates

    func didSelectItem(dropDown: HADropDown, at index: Int) {
        let dicCategory = self.arrayCategories[index] as! NSDictionary
        self.selectedCategoryId = "\(dicCategory["id"]!)"
        self.viewDropDown.title = "\(dicCategory["ct_name"]!)"
        self.arrayChallenges.removeAllObjects()
        self.tableView.reloadData()
        self.index = self.arrayChallenges.count-1
        self.loadChallenges(with: self.selectedCategoryId, userID: self.user_id, offset: 1, token: self.accessToken)
    }
    
    //MARK:- Date Helper
    
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
