//
//  OFALoginPasswordTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 28/01/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFALoginPasswordTableViewController: UITableViewController {

    @IBOutlet weak var textPassword: JJMaterialTextfield!
    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var buttonGenerateOTP: UIButton!
    
    var emailID = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userDetails: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonSignIn.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        self.buttonSignIn.layer.cornerRadius = self.buttonSignIn.frame.height/2
        self.buttonGenerateOTP.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        self.buttonGenerateOTP.layer.cornerRadius = self.buttonSignIn.frame.height/2
        
        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }
    
    @objc func tapAction(){
        self.view.endEditing(true)
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
    
    //MARK:- Button Actions
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        let forgotPasswordTVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordTVC") as! OFAForgotPasswordTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(forgotPasswordTVC, animated: true)
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        if OFAUtils.isWhiteSpace(self.textPassword.text!){
            OFAUtils.showToastWithTitle("Enter password")
            return
        }
        OFAUtils.showLoadingViewWithTitle("Loading")
        
        let dicParameters = NSDictionary(objects: [self.textPassword.text!,self.emailID], forKeys: ["password" as NSCopying,"email" as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        let timeStamp = "\(OFAUtils.getTimeStamp())"
        let secretString = "POST+\(jsonString!)+\(timeStamp)"
        let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        
        var request = URLRequest(url: URL(string: loginBaseURL + "login-using-password")!)
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
                if let dicData = dicResponse["data"] as? NSDictionary{
                    //call API to our server and get User details
                    let arrayCourses = dicData["courses"] as! NSArray
                    let dataCoursesArray = NSKeyedArchiver.archivedData(withRootObject: arrayCourses)
                    UserDefaults.standard.setValue(dataCoursesArray, forKey: Subscribed_Courses)
                    let userID = UserDefaults.standard.value(forKey: CLIENT_USER_ID) as! String
                    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
                    let fcmToken = UserDefaults.standard.value(forKey: FCM_token) as! String
                    let dicParameters = NSDictionary(objects: [userID,self.emailID,domainKey,"ios","\(OFAUtils.getAppVersion())","\(OFAUtils.getDeviceID())",fcmToken], forKeys: ["user_id" as NSCopying,"email" as NSCopying,"domain_key" as NSCopying,"platform" as NSCopying,"app_version" as NSCopying,"device" as NSCopying,"fcm_token" as NSCopying])
                    OFAUtils.showLoadingViewWithTitle("Fetching user details")
                    Alamofire.request(userBaseURL+"api/authenticate/login_api", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON(completionHandler: { (responseJSON) in
                        OFAUtils.removeLoadingView(nil)
                        if let result = responseJSON.result.value {
                            print(result)
                            let dicResponse = result as! NSDictionary
                            if responseJSON.response?.statusCode == 202{
                                //input field missing-----> redirection to Register page
                                //Basic Details page
                                OFAUtils.showToastWithTitle("Please re-enter your details")
                                let registerUser = self.storyboard?.instantiateViewController(withIdentifier: "RegisterTVC") as! OFARegisterTableViewController
                                registerUser.emailID = self.emailID
                                self.navigationItem.title = ""
                                self.navigationController?.pushViewController(registerUser, animated: true)
                            }else if responseJSON.response?.statusCode == 203{
                                //invalid user/password
                                OFAUtils.removeLoadingView(nil)
                                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                            }else if responseJSON.response?.statusCode == 204{
                                // mail not verified
                                let sessionAlert = UIAlertController(title: "OTP not verified", message: nil, preferredStyle: .alert)
                                sessionAlert.addAction(UIAlertAction(title: "Verify OTP", style: .default, handler: { (action) in
                                    let otpPage = self.storyboard?.instantiateViewController(withIdentifier: "OTPTVC") as! OFAOTPTableViewController
                                    self.navigationItem.title = ""
                                    otpPage.emailID = self.emailID
                                    OFAUtils.removeLoadingView(nil)
                                    self.navigationController?.pushViewController(otpPage, animated: true)
                                }))
                                sessionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                                    
                                }))
                                self.present(sessionAlert, animated: true, completion: nil)
                            }else if let token = dicResponse["token"] {
                                let dicBody = dicResponse["body"] as! NSDictionary
                                
                                UserDefaults.standard.setValue(self.emailID, forKey: EMAIL)
                                UserDefaults.standard.set(token as! String, forKey: ACCESS_TOKEN)
                                UserDefaults.standard.set("\(dicBody["id"]!)", forKey: USER_ID)
                                
                                let userDetails = User(context: self.context)
                                userDetails.user_name = "\(dicBody["us_name"]!)"
                                userDetails.user_email = "\(dicBody["us_email"]!)"
                                userDetails.user_image = "\(dicBody["us_image"]!)"
                                userDetails.user_phone = "\(dicBody["us_phone"]!)"
                                userDetails.user_about = "\(dicBody["us_about"]!)"
                                userDetails.user_id =  "\(dicBody["id"]!)"
                                userDetails.otp_status = "\(dicBody["otp_status"]!)"
                                
                                let delegate = UIApplication.shared.delegate as! AppDelegate
                                delegate.saveContext()
                                
                                OFASingletonUser.ofabeeUser.initWithDictionary(dicData: dicBody)
                                if "\(dicBody["otp_status"]!)" == "1"{
                                    delegate.initializeBrowserCourse()
                                }else{
                                    let sessionAlert = UIAlertController(title: "OTP not verified", message: nil, preferredStyle: .alert)
                                    sessionAlert.addAction(UIAlertAction(title: "Verify OTP", style: .default, handler: { (action) in
                                        let otpPage = self.storyboard?.instantiateViewController(withIdentifier: "OTPTVC") as! OFAOTPTableViewController
                                        self.navigationItem.title = ""
                                        otpPage.emailID = "\(dicBody["us_email"]!)"
                                        OFAUtils.removeLoadingView(nil)
                                        self.navigationController?.pushViewController(otpPage, animated: true)
                                    }))
                                    sessionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                                        
                                    }))
                                    self.present(sessionAlert, animated: true, completion: nil)
                                }
                                
                                OFAUtils.removeLoadingView(nil)
                                OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")//"Logged in successfully" message from DB
                            }else{
                                OFAUtils.removeLoadingView(nil)
                                self.navigationController?.popToRootViewController(animated: true)
                                OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
//                                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                            }
                        }else {
                            OFAUtils.removeLoadingView(nil)
                            if responseJSON.response?.statusCode == 500{
                                
                            }else{
                                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Some error occured, try again later", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                            }
                        }
                    })
                }else if "\(dicResponse["status"]!)" == "error"{
                    OFAUtils.removeLoadingView(nil)
                    if let errorMessage = dicResponse["messages"] as? String{
                        OFAUtils.showAlertViewControllerWithTitle(nil, message: errorMessage, cancelButtonTitle: "OK")
                    }
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }

    @IBAction func generateOTPPressed(_ sender: UIButton) {
        OFAUtils.showLoadingViewWithTitle("Loading")
        
        let dicParameters = NSDictionary(objects: [self.emailID], forKeys: ["email" as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        let timeStamp = "\(OFAUtils.getTimeStamp())"
        let secretString = "POST+\(jsonString!)+\(timeStamp)"
        let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        
        var request = URLRequest(url: URL(string: loginBaseURL + "generate-otp-for-login")!)
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
                    OTPPage.isFromLogin = false
                    OTPPage.isFromLoginPassword = true
                    OTPPage.emailID = self.emailID
                    self.navigationItem.title = ""
                    self.navigationController?.pushViewController(OTPPage, animated: true)
                }else{
                    OFAUtils.showToastWithTitle("\(dicResponse["messages"]!)")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Textfield Delegate
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
