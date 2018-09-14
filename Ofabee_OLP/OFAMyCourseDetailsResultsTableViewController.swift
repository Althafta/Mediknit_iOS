//
//  OFAMyCourseDetailsResultsTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAMyCourseDetailsResultsTableViewController: UITableViewController {

    var offset = 1
    var index = 0
    var arrayResults = NSMutableArray()
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadResult(userID: user_id, offset: self.offset, limit: "10")
    }
    func loadResult(userID:String,offset:Int,limit:String){
        if(index-1 >= self.arrayResults.count ){
            return
        }
        let dicParameteres = NSDictionary(objects: [userID,COURSE_ID,"\(offset)",limit,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"course_id" as NSCopying,"offset" as NSCopying,"limit" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/assessment_results", method: .post, parameters: dicParameteres as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
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
                if "\(dicResult["message"]!)" == "No results found" {
                    OFAUtils.showToastWithTitle("No results found")
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let dicAssessmentCourses = dicBody["assessment_courses"] as! NSDictionary
                let arrResults = dicAssessmentCourses["attempts"] as! NSArray
//                self.arrayResults.removeAllObjects()
                for item in arrResults{
                    let dicResults = item as! NSDictionary
                    self.arrayResults.add(dicResults)
                }
                self.tableView.reloadData()
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCourseResultCell", for: indexPath) as! OFAMyCourseResultsTableViewCell

        let dicResultDetails = self.arrayResults[indexPath.row] as! NSDictionary
        
        let createTimeString = "\(dicResultDetails["aa_attempted_date"]!)"
        let createdDate = self.getDateFromString(createTimeString)
        let dateString = self.getStringFromDate(createdDate)
        
        var durationString = ""
        let duration = self.getDuration(seconds: Int("\(dicResultDetails["aa_duration"]!)")!)
        if duration[0] > 0 {
            durationString = "\(duration[0]) hr \(duration[1]) m \(duration[2]) s"
        }else if duration[1] > 0 {
            durationString = "\(duration[1]) m \(duration[2]) s"
        }else if duration[2] >= 0 {
            durationString = " \(duration[2]) s"
        }
        cell.customizeCellWithDetails(dateString: dateString, resultTitle: "\(dicResultDetails["cl_lecture_name"]!)", score: "Score \("\(dicResultDetails["total_mark"]!)")", timeTaken: "Time Taken \(durationString)")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dicResultDetails = self.arrayResults[indexPath.row] as! NSDictionary
        
        let createTimeString = "\(dicResultDetails["aa_attempted_date"]!)"
        let createdDate = self.getDateFromString(createTimeString)
        let dateString = self.getFullStringFromDate(createdDate)
        let dicParameteres = NSDictionary(objects: [user_id,"\(dicResultDetails["a_attempt_id"]!)",domainKey,accessToken], forKeys: ["user_id" as NSCopying,"attempt_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/get_single_assessment_details", method: .post, parameters: dicParameteres as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
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
                if "\(dicResult["success"]!)" == "1"{
                    let scoreCard = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeScoreCard") as! OFAChallengeScoreCardTableViewController
                    scoreCard.dicScoreCardDetails = dicResult["body"] as! NSDictionary
                    scoreCard.fullDateString = dateString
                    self.navigationController?.pushViewController(scoreCard, animated: true)
                }else if "\(dicResult["success"]!)" == "2"{
                    OFAUtils.showAlertViewControllerWithTitle(nil, message: "Assessment under validation", cancelButtonTitle: "OK")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row  == self.arrayResults.count-1 {
            self.index = index + 10
            self.offset += 1
            let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
            self.loadResult(userID: user_id, offset: self.offset, limit: "10")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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
    
    func getFullStringFromDate(_ date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat="dd MMMM yyyy"
        let local = Locale(identifier: "en_US")
        formatter.locale=local
        return formatter.string(from: date)
    }
}
