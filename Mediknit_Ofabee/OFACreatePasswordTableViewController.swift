//
//  OFACreatePasswordTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 29/01/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFACreatePasswordTableViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet var textCreatePassword: JJMaterialTextfield!
    @IBOutlet var textConfirmPassword: JJMaterialTextfield!
    @IBOutlet var buttonRegister: UIButton!
    var emailID = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userDetails: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonRegister.layer.cornerRadius = self.buttonRegister.frame.height/2
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button Actions
    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {//createPasswordPressed
        self.view.endEditing(true)
        if self.isFieldValid(){
            OFAUtils.showLoadingViewWithTitle("Loading")
            let userID = UserDefaults.standard.value(forKey: CLIENT_USER_ID) as! String
            let dicParameters = NSDictionary(objects: [self.textCreatePassword.text!,userID], forKeys: ["password" as NSCopying,"user_id" as NSCopying])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            let timeStamp = "\(OFAUtils.getTimeStamp())"
            let secretString = "POST+\(jsonString!)+\(timeStamp)"
            let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)
            
            var request = URLRequest(url: URL(string: loginBaseURL + "set-password")!)
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
                        let dicParameters = NSDictionary(objects: [userID,self.emailID,domainKey,self.textCreatePassword.text!,"ios","\(OFAUtils.getAppVersion())","\(OFAUtils.getDeviceID())",fcmToken], forKeys: ["user_id" as NSCopying,"email" as NSCopying,"domain_key" as NSCopying,"password" as NSCopying,"platform" as NSCopying,"app_version" as NSCopying,"device" as NSCopying,"fcm_token" as NSCopying])
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
                                }
                                else if let token = dicResponse["token"] {
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
//                                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                                    OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
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
    }
    
    func isFieldValid() -> Bool{
        if (self.textCreatePassword.text! as NSString).length < 8{
            OFAUtils.showToastWithTitle("Minimum of 8 characters required")
            return false
        }
        if OFAUtils.isWhiteSpace(self.textCreatePassword.text!){
            OFAUtils.showToastWithTitle("Enter password")
            return false
        }else if OFAUtils.isWhiteSpace(self.textConfirmPassword.text!){
            OFAUtils.showToastWithTitle("Confirm you password")
            return false
        }else if self.textCreatePassword.text != self.textConfirmPassword.text!{
            OFAUtils.showToastWithTitle("Password mismatch")
            return false
        }else{
            return true
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
