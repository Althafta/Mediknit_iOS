//
//  OFAMyQuestionsTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 14/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAMyQuestionsTableViewController: UITableViewController {

    var offset = 1
    var index = 0
    var arrayMyQuestions = NSMutableArray()
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.offset = 1
        self.index = 0
        self.arrayMyQuestions.removeAllObjects()
        self.loadQuestions(userID: user_id, offset: offset, limit: "10")
    }

    func loadQuestions(userID:String,offset:Int,limit:String){
        if(index-1 >= self.arrayMyQuestions.count ){
            return
        }
        let dicParameteres = NSDictionary(objects: [userID,LECTURE_ID,"\(offset)",limit,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"lecture_id" as NSCopying,"offset" as NSCopying,"limit" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/get_my_question", method: .post, parameters: dicParameteres as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.refreshController.endRefreshing()
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let arrDiscussion = dicBody["questions"] as! NSArray
                for item in arrDiscussion{
                    let dicDiscussion = item as! NSDictionary
                    self.arrayMyQuestions.add(dicDiscussion)
                }
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
                self.tableView.scrollsToTop = true
            }else{
                OFAUtils.removeLoadingView(nil)
                self.refreshController.endRefreshing()
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
        return self.arrayMyQuestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionMyQuestionCell", for: indexPath) as! OFALectureDiscussionMyQuestionsTableViewCell

        let dicQuestion = self.arrayMyQuestions[indexPath.row] as! NSDictionary 
        
        let createTimeString = "\(dicQuestion["comment_date"]!)"
        let createdDate = OFAUtils.getDateFromString(createTimeString)
        let createTime = self.getTimeAgo(time:  UInt64(createdDate.millisecondsSince1970))
        
        cell.customizeCellWithDetails(comment: OFAUtils.getHTMLAttributedString(htmlString: "\(dicQuestion["comment"]!)"), author: "\(dicQuestion["username"]!)", dateString: createTime!, numberOfReplies: "", status: "\(dicQuestion["question"]!)")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row  == self.arrayMyQuestions.count-1 {
            self.index = index + 5
            print("New data loaded")
            self.offset += 1
            let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
            self.loadQuestions(userID: user_id, offset: self.offset, limit: "10")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 170
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }
    
    
    //MARK:- Get TimeStamp string
    
    func getTimeAgo(time:UInt64) -> String? {
        let secondMilliSecond:UInt64 = 1000
        let minuteMilliSecond:UInt64 = 60 * secondMilliSecond
        let hoursMillisecond:UInt64 = 60 * minuteMilliSecond
        //        let DAY_MILLIS:UInt64 = 24 * HOUR_MILLIS
        var time = time
        if time < 1000000000000 {
            time *= 1000
        }
        let nowMilliSecs = Date().millisecondsSince1970
        if time > nowMilliSecs || time <= 0{
            return nil
        }
        let diff = nowMilliSecs - time
        
        if diff < minuteMilliSecond {
            return "just now"
        } else if diff < 2 * minuteMilliSecond {
            return "a minute ago"
        } else if diff < 50 * minuteMilliSecond {
            return "\(diff / minuteMilliSecond)" + " mins ago"
        } else if diff < 90 * minuteMilliSecond {
            return "an hour ago"
        } else if diff < 24 * hoursMillisecond {
            return "\(diff / hoursMillisecond)" + " hrs ago"
        } else if (diff < 48 * hoursMillisecond) {
            return "yesterday";
        }else{
            let createDate = Date(milliseconds: time)
            let createTime = OFAUtils.getStringFromMilliSecondDate(date: createDate)
            return createTime
        }
    }
}
