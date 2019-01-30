//
//  OLPOTPTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAOTPTableViewController: UITableViewController {

    @IBOutlet var textOTP: UITextField!
    @IBOutlet var labelCountDown: UILabel!
    @IBOutlet var buttonResendOTP: UIButton!
    @IBOutlet weak var buttonDone: UIButton!
    
    var isBookSelection = Bool()
    var isForgotPassword = false
    var isFromLogin = false
    var isFromLoginPassword = false
    
    var isRegistrationComplete = Bool()
    var isPasswordPresent = Bool()
    
    var emailID = ""
    var seconds = 60
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonResendOTP.isHidden = true
        self.buttonResendOTP.layer.cornerRadius = self.buttonResendOTP.frame.height/2
        self.buttonResendOTP.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
        self.buttonDone.layer.cornerRadius = self.buttonDone.frame.height/2
        self.buttonDone.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
        self.runTimer()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateLabel(){
        seconds -= 1
        self.labelCountDown.text = "\(seconds)" + " seconds left"
        if seconds <= 0 {
            timer.invalidate()
            self.textOTP.isEnabled = false
            self.labelCountDown.isHidden = true
            self.buttonResendOTP.isHidden = false
            self.buttonDone.isHidden = true
        }
    }
    
    // MARK: - Table view functions
    
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
    
    @IBAction func resendOTPPressed(_ sender: UIButton) {
            OFAUtils.showLoadingViewWithTitle("Resending")
            let dicParameters = NSDictionary(objects: [self.emailID], forKeys: ["email" as NSCopying])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            let timeStamp = "\(OFAUtils.getTimeStamp())"
            let secretString = "POST+\(jsonString!)+\(timeStamp)"
            let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            
            let apiString = self.isFromLoginPassword ? "generate-otp-for-login" : "otp-generate-email-verification"
            var request = URLRequest(url: URL(string: loginBaseURL + apiString)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(loginKey, forHTTPHeaderField: "KEY")
            request.setValue(loginUserName, forHTTPHeaderField: "USERNAME")
            request.setValue(timeStamp, forHTTPHeaderField: "TIMESTAMP")
            request.setValue(sha256EncodedSecretString!, forHTTPHeaderField: "SECRET")
            
            let parameterJsonData = jsonString?.data(using: .utf8)
            request.httpBody = parameterJsonData
            
            Alamofire.request(request).responseJSON { (responseJSON) in
                if let dicResult = responseJSON.result.value as? NSDictionary{
                    print(dicResult)
                    OFAUtils.removeLoadingView(nil)
                    self.labelCountDown.isHidden = false
                    self.buttonResendOTP.isHidden = true
                    self.buttonDone.isHidden = false
                    self.textOTP.isEnabled = true
                    self.seconds = 60
                    self.runTimer()
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
//        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
//        let dicParameters = NSDictionary(objects:[self.emailID,domainKey], forKeys:["email" as NSCopying,"domain_key" as NSCopying])
//        Alamofire.request(userBaseURL+"api/authenticate/send_otp", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
//            self.labelCountDown.isHidden = false
//            self.buttonResendOTP.isHidden = true
//            self.buttonDone.isHidden = false
//            self.textOTP.isEnabled = true
//            self.seconds = 60
//            self.runTimer()
//        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if OFAUtils.isWhiteSpace(self.textOTP.text!){
            OFAUtils.showToastWithTitle("OTP field missing")
            return
        }
        OFAUtils.showLoadingViewWithTitle("Verifying")
        
        let dicParameters = NSDictionary(objects: [self.emailID,self.textOTP.text!], forKeys: ["email" as NSCopying,"otp" as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        let timeStamp = "\(OFAUtils.getTimeStamp())"
        let secretString = "POST+\(jsonString!)+\(timeStamp)"
        let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        
        let apiString = self.isFromLoginPassword ? "login-using-otp" : "verify-email-otp"
        var request = URLRequest(url: URL(string: loginBaseURL + apiString)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(loginKey, forHTTPHeaderField: "KEY")
        request.setValue(loginUserName, forHTTPHeaderField: "USERNAME")
        request.setValue(timeStamp, forHTTPHeaderField: "TIMESTAMP")
        request.setValue(sha256EncodedSecretString!, forHTTPHeaderField: "SECRET")
        
        let parameterJsonData = jsonString?.data(using: .utf8)
        request.httpBody = parameterJsonData
        
        Alamofire.request(request).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                print(dicResult)
                OFAUtils.removeLoadingView(nil)
                if let dicData = dicResult["data"] as? NSDictionary {
                    UserDefaults.standard.setValue("\(dicData["user_id"]!)", forKey: USER_ID)
                    if self.isForgotPassword{
                        //go to create password
                        let passwordTVC = self.storyboard?.instantiateViewController(withIdentifier: "CreatePasswordTVC") as! OFACreatePasswordTableViewController
                        self.navigationItem.title = ""
                        passwordTVC.emailID = self.emailID
                        self.navigationController?.pushViewController(passwordTVC, animated: true)
                    }else if self.isFromLogin{
                        //goto basic details
                        if self.isRegistrationComplete == false{
                            let registerUser = self.storyboard?.instantiateViewController(withIdentifier: "RegisterTVC") as! OFARegisterTableViewController
                            registerUser.emailID = self.emailID
                            registerUser.isSocialLogin = false
                            self.navigationItem.title = ""
                            self.navigationController?.pushViewController(registerUser, animated: true)
                        }else{
                            if self.isPasswordPresent == true{
                                //password entry
                                let passwordEntry = self.storyboard?.instantiateViewController(withIdentifier: "LoginPasswordTVC") as! OFALoginPasswordTableViewController
                                passwordEntry.emailID = self.emailID
                                self.navigationItem.title = ""
                                self.navigationController?.pushViewController(passwordEntry, animated: true)
                            }else{
                                //create password
                                let passwordTVC = self.storyboard?.instantiateViewController(withIdentifier: "CreatePasswordTVC") as! OFACreatePasswordTableViewController
                                self.navigationItem.title = ""
                                passwordTVC.emailID = self.emailID
                                self.navigationController?.pushViewController(passwordTVC, animated: true)
                            }
                        }
                    }else if self.isFromLoginPassword{
                        print("From login password and OTP verified successfully")
                        //call API to our server and get User details - email & userID
                    }else{
                        OFAUtils.removeLoadingView(nil)
                        OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                    }
                }else if let errorMessage = dicResult["messages"] as? String{
                    OFAUtils.showToastWithTitle(errorMessage)
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
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
