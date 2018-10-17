//
//  OFACurriculumTextViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/19/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFACurriculumTextViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var webViewDetails: UIWebView!
    @IBOutlet var buttonCurriculum: UIButton!
    @IBOutlet var buttonQA: UIButton!
    
    var textContent = ""
    var textTitle = ""
    var percentage = ""
    var lectureID = ""
    var originalPercentage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.originalPercentage = self.percentage
        self.buttonCurriculum.layer.cornerRadius = self.buttonCurriculum.frame.height/2
        self.buttonQA.layer.cornerRadius = self.buttonQA.frame.height/2
        
        self.webViewDetails.loadHTMLString(self.textContent, baseURL: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.textTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let totalHeight = self.webViewDetails.scrollView.contentSize.height
        let scrollHeight = self.webViewDetails.scrollView.contentOffset.y + self.webViewDetails.frame.size.height
        if scrollHeight == self.webViewDetails.scrollView.contentSize.height{
            self.percentage = "100"
        }else{
            let percentageScrolled:CGFloat = (scrollHeight/totalHeight)*100
            self.percentage = "\(Int(percentageScrolled))"
        }
        if Int(self.percentage)! > Int(self.originalPercentage)!{
            self.saveLectureProgress()
        }
    }
    
    //MARK:- Save lecture percentage
    
    func saveLectureProgress(){
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.lectureID,self.percentage,user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"percentage" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
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
    
    @IBAction func curriculumPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func QandAPressed(_ sender: UIButton) {
        let QandATabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        QandATabTVC.isPresented = false
        self.navigationController?.pushViewController(QandATabTVC, animated: true)
    }

    //MARK:- webView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let floatPercentage = NumberFormatter().number(from: self.percentage) else { return }
        let position = (self.webViewDetails.scrollView.contentSize.height * CGFloat(floatPercentage)) / 100
        let scrollPoint = CGPoint(x: 0, y: position)
        webView.scrollView.setContentOffset(scrollPoint, animated: true)
    }
}
