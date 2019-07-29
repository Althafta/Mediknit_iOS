//
//  OFAForgotPasswordTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAForgotPasswordTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet var textEmail: JJMaterialTextfield!
    @IBOutlet weak var buttonSendEmail: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonSendEmail.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        self.buttonSendEmail.layer.cornerRadius = self.buttonSendEmail.frame.height/2
        
//        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton){
        self.view.endEditing(true)
        if !OFAUtils.checkEmailValidation(self.textEmail.text!){
            OFAUtils.showToastWithTitle("Enter a registered email")
            return
        }
        OFAUtils.showLoadingViewWithTitle("Verifying")
        let dicParameters = NSDictionary(objects: [self.textEmail.text!], forKeys: ["email" as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        let timeStamp = "\(OFAUtils.getTimeStamp())"
        let secretString = "POST+\(jsonString!)+\(timeStamp)"
        let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        
        var request = URLRequest(url: URL(string: loginBaseURL + "otp-generate-email-verification")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(loginKey, forHTTPHeaderField: "KEY")
        request.setValue(loginUserName, forHTTPHeaderField: "USERNAME")
        request.setValue(timeStamp, forHTTPHeaderField: "TIMESTAMP")
        request.setValue(sha256EncodedSecretString!, forHTTPHeaderField: "SECRET")
        
        let parameterJsonData = jsonString?.data(using: .utf8)
        
        request.httpBody = parameterJsonData
        Alamofire.request(request).responseJSON { (responseJSON) in
            if let dicResponse = responseJSON.result.value as? NSDictionary{
                print(dicResponse)
                OFAUtils.removeLoadingView(nil)
                if let _ = dicResponse["data"] as? NSDictionary{
                    let OTPPage = self.storyboard?.instantiateViewController(withIdentifier: "RegisterOTPTVC") as! OFAOTPTableViewController
                    OTPPage.isBookSelection = false
                    OTPPage.isForgotPassword = true
                    OTPPage.emailID = self.textEmail.text!
                    self.navigationItem.title = ""
                    self.navigationController?.pushViewController(OTPPage, animated: true)
                }else if "\(dicResponse["status"]!)" == "validation_error"{
                    OFAUtils.showAlertViewControllerWithTitle("Error occured", message: "Please check the email entered", cancelButtonTitle: "OK")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
//    {
//        if !OFAUtils.checkEmailValidation(self.textEmail.text!){
//            OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:nil, message: (NSLocalizedString("Invalid Email format", comment: "")), cancelButtonTitle: "OK")
//        }
//        else{
//            self.sendPasswordToEmail(emailString: self.textEmail.text!)
////            OFAUtils.showToastWithTitle("New password link has been sent to your mail ID")
//        }
//    }
    
    func sendPasswordToEmail(emailString:String) {
        OFAUtils.showLoadingViewWithTitle("Loading")
        OFAUtils.removeLoadingView(nil)
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [emailString,domainKey], forKeys: ["email" as NSCopying,"domain_key" as NSCopying])
        Alamofire.request(userBaseURL+"api/authenticate/forgot", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{ 
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Unable to send Password", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    // MARK: - Table view Functions
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !OFAUtils.isiPhone(){
            return 300
        }else{
            return 0
        }
    }
    
    //MARK:- Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag+1
        let nextResponder = textField.superview?.superview?.superview?.viewWithTag(nextTag)
        if nextResponder != nil{
            nextResponder?.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return false
    }
}
