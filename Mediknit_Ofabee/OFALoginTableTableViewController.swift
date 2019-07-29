//
//  OLPLoginTableTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import GoogleSignIn

class OFALoginTableTableViewController: UITableViewController,GIDSignInDelegate,GIDSignInUIDelegate {

    @IBOutlet var textEmail: JJMaterialTextfield!
    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var buttonGoogleSignIn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userDetails: [User] = []
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        self.buttonSignIn.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        self.buttonSignIn.layer.cornerRadius = self.buttonSignIn.frame.height/2
        
        self.buttonGoogleSignIn.layer.borderWidth = 1.0
        self.buttonGoogleSignIn.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonGoogleSignIn.layer.cornerRadius = self.self.buttonGoogleSignIn.frame.height/2
        
//       OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        let email = UserDefaults.standard.value(forKey: EMAIL) as? String
        if UserDefaults.standard.value(forKey: EMAIL) != nil{
            self.textEmail.text = email!
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent=true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = OFAUtils.getColorFromHexString(barTintColor)
//        UIApplication.shared.statusBarStyle = .default
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

    @IBAction func signInPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if OFAUtils.isWhiteSpace(textEmail.text!) || !OFAUtils.checkEmailValidation(textEmail.text!){
            OFAUtils.showToastWithTitle("Please enter a valid email")
        }else{
            OFAUtils.showLoadingViewWithTitle("Loading")
            
            let dicParameters = NSDictionary(objects: [self.textEmail.text!], forKeys: ["email" as NSCopying])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            let timeStamp = "\(OFAUtils.getTimeStamp())"
            let secretString = "POST+\(jsonString!)+\(timeStamp)"
            let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            
            var request = URLRequest(url: URL(string: loginBaseURL+"email-verification")!)
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
                    if let dicUserData = dicResponse["data"] as? NSDictionary{
                        UserDefaults.standard.setValue("\(dicUserData["user_id"]!)", forKey: CLIENT_USER_ID)
                        if "\(dicUserData["email_verified"]!)" == "0"{//false
                            self.generateOTPForEmailVerification(isRegistrationComplete: "\(dicUserData["registration_completed"]!)" == "0" ? false : true, isPasswordPresent: "\(dicUserData["password_present"]!)" == "0" ? false : true)
                        }else{
                            UserDefaults.standard.setValue(self.textEmail.text!, forKey: EMAIL)
                            if "\(dicUserData["registration_completed"]!)" == "1"{//true
                                if "\(dicUserData["password_present"]!)" == "1"{//true
                                    //password entry
                                    let passwordEntry = self.storyboard?.instantiateViewController(withIdentifier: "LoginPasswordTVC") as! OFALoginPasswordTableViewController
                                    passwordEntry.emailID = self.textEmail.text!
                                    self.navigationItem.title = ""
                                    self.navigationController?.pushViewController(passwordEntry, animated: true)
                                }else{
                                    //create password
                                    let passwordTVC = self.storyboard?.instantiateViewController(withIdentifier: "CreatePasswordTVC") as! OFACreatePasswordTableViewController
                                    self.navigationItem.title = ""
                                    passwordTVC.emailID = self.textEmail.text!
                                    self.navigationController?.pushViewController(passwordTVC, animated: true)
                                }
                            }else{
                                //Basic Details page
                                let registerUser = self.storyboard?.instantiateViewController(withIdentifier: "RegisterTVC") as! OFARegisterTableViewController
                                registerUser.emailID = self.textEmail.text!
                                self.navigationItem.title = ""
                                self.navigationController?.pushViewController(registerUser, animated: true)
                            }
                        }
                    }else if "\(dicResponse["messages"]!)" == "Email not found"{
                        self.generateOTPForEmailVerification(isRegistrationComplete: false, isPasswordPresent: false)
                    }else{
                        OFAUtils.removeLoadingView(nil)
                        OFAUtils.showAlertViewControllerWithTitle("Authentication failed", message: "Try again later", cancelButtonTitle: "OK")
                    }
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
//            let loginPasswordTVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginPasswordTVC") as! OFALoginPasswordTableViewController
//            self.navigationItem.title = ""
//            self.navigationController?.pushViewController(loginPasswordTVC, animated: true)
        }
    }
    
    @IBAction func signInWithGooglePressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK:- Generate OTP
    
    func generateOTPForEmailVerification(isRegistrationComplete:Bool,isPasswordPresent:Bool){
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
            if let dicResult = responseJSON.result.value as? NSDictionary{
                print(dicResult)
                if let _ = dicResult["data"] as? NSDictionary{
                    OFAUtils.removeLoadingView(nil)
                    let OTPPage = self.storyboard?.instantiateViewController(withIdentifier: "RegisterOTPTVC") as! OFAOTPTableViewController
//                    OTPPage.isBookSelection = false
                    OTPPage.isFromLogin = true
                    OTPPage.emailID = self.textEmail.text!
                    OTPPage.isRegistrationComplete = isRegistrationComplete
                    OTPPage.isPasswordPresent = isPasswordPresent
                    self.navigationItem.title = ""
                    self.navigationController?.pushViewController(OTPPage, animated: true)
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Google Sign In Delegate
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print("\(error.localizedDescription)")
        }else{
            let idToken = user.userID //user.authentication.idToken // Safe to send to the server
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            OFAUtils.showLoadingViewWithTitle("Loading")
            
            let dicParameters = NSDictionary(objects: ["google",idToken!,email!,givenName!,familyName!], forKeys: ["oauth_provider" as NSCopying,"oauth_uid" as NSCopying,"email" as NSCopying,"first_name" as NSCopying,"last_name" as NSCopying])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            let timeStamp = "\(OFAUtils.getTimeStamp())"
            let secretString = "POST+\(jsonString!)+\(timeStamp)"
            let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)//.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            
            var request = URLRequest(url: URL(string: loginBaseURL + "social-media-login")!)
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
                    if let dicData = dicResult["data"] as? NSDictionary{
//                        UserDefaults.standard.setValue("\(dicData["user_id"]!)", forKey: USER_ID)
                        UserDefaults.standard.setValue("\(dicData["user_id"]!)", forKey: CLIENT_USER_ID)
                        if "\(dicData["registration_completed"]!)" == "0"{//false
                            let registerUser = self.storyboard?.instantiateViewController(withIdentifier: "RegisterTVC") as! OFARegisterTableViewController
                            registerUser.isSocialLogin = true
                            registerUser.socialFirstName = givenName!
                            registerUser.socialLastName = familyName!
                            registerUser.socialEmail = email!
                            registerUser.emailID = email!
                            self.navigationItem.title = ""
                            self.navigationController?.pushViewController(registerUser, animated: true)
                        }else{
                            //call API to our server and get User details
                            let arrayCourses = dicData["courses"] as! NSArray
                            let dataCoursesArray = NSKeyedArchiver.archivedData(withRootObject: arrayCourses)
                            UserDefaults.standard.setValue(dataCoursesArray, forKey: Subscribed_Courses)
                            let userID = UserDefaults.standard.value(forKey: CLIENT_USER_ID) as! String
                            let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
                            let fcmToken = UserDefaults.standard.value(forKey: FCM_token) as! String
                            let dicParameters = NSDictionary(objects: [userID,email!,domainKey,"ios","\(OFAUtils.getAppVersion())","\(OFAUtils.getDeviceID())",fcmToken], forKeys: ["user_id" as NSCopying,"email" as NSCopying,"domain_key" as NSCopying,"platform" as NSCopying,"app_version" as NSCopying,"device" as NSCopying,"fcm_token" as NSCopying])
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
                                        registerUser.isSocialLogin = true
                                        registerUser.socialFirstName = givenName!
                                        registerUser.socialLastName = familyName!
                                        registerUser.socialEmail = email!
                                        registerUser.emailID = email!
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
                                            otpPage.emailID = email!
                                            OFAUtils.removeLoadingView(nil)
                                            self.navigationController?.pushViewController(otpPage, animated: true)
                                        }))
                                        sessionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                                            
                                        }))
                                        self.present(sessionAlert, animated: true, completion: nil)
                                    }else if let token = dicResponse["token"] {
                                        let dicBody = dicResponse["body"] as! NSDictionary
                                        
                                        UserDefaults.standard.setValue(email!, forKey: EMAIL)
                                        UserDefaults.standard.set(token as! String, forKey: ACCESS_TOKEN)
                                        UserDefaults.standard.set("\(dicBody["id"]!)", forKey: USER_ID)
                                        print(UserDefaults.standard.value(forKey: USER_ID) as! String)
                                        
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
//                                        self.navigationController?.popToRootViewController(animated: true)
                                        OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                                        GIDSignIn.sharedInstance().signOut()
                                    }
                                }else {
                                    OFAUtils.removeLoadingView(nil)
                                    if responseJSON.response?.statusCode == 500{
                                        
                                    }else{
                                        OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Some error occured, try again later", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                                    }
                                }
                            })
                        }
                    }
                }else{
                    OFAUtils.removeLoadingView(nil)
                    GIDSignIn.sharedInstance().signOut()
                    OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Error while fetching... Failed with error: \(error.localizedDescription)")
    }
    
    //MARK:- SignIn Helpers - old
    
    func checkUserLoginDetails () {
        OFAUtils.showLoadingViewWithTitle("Loading")
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let encryptedPassword = ""//self.textPassword.text?.md5()
        let dicParameters = NSDictionary(objects: [self.textEmail.text!,encryptedPassword,domainKey], forKeys: ["email" as NSCopying,"password" as NSCopying,"domain_key" as NSCopying])
        Alamofire.request(userBaseURL+"api/authenticate/login", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            OFAUtils.removeLoadingView(nil)
            if let result = responseJSON.result.value {
                let dicResponse = result as! NSDictionary
                if responseJSON.response?.statusCode == 203{
                    //invalid user/password
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                }else if responseJSON.response?.statusCode == 204{
                    // mail not verified
                    let sessionAlert = UIAlertController(title: "OTP not verified", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Verify OTP", style: .default, handler: { (action) in
                        let otpPage = self.storyboard?.instantiateViewController(withIdentifier: "OTPTVC") as! OFAOTPTableViewController
                        self.navigationItem.title = ""
                        otpPage.emailID = self.textEmail.text!
                        OFAUtils.removeLoadingView(nil)
                        self.navigationController?.pushViewController(otpPage, animated: true)
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                }
                else if let token = dicResponse["token"] {
                    let dicResult = dicResponse["body"] as! NSDictionary
                    
                    UserDefaults.standard.setValue(self.textEmail.text!, forKey: EMAIL)
                    UserDefaults.standard.set(token as! String, forKey: ACCESS_TOKEN)
                    UserDefaults.standard.set("\(dicResult["id"]!)", forKey: USER_ID)
                    
                    let userDetails = User(context: self.context)
                    userDetails.user_name = "\(dicResult["us_name"]!)"
                    userDetails.user_email = "\(dicResult["us_email"]!)"
                    userDetails.user_image = "\(dicResult["us_image"]!)"
                    userDetails.user_phone = "\(dicResult["us_phone"]!)"
                    userDetails.user_about = "\(dicResult["us_about"]!)"
                    userDetails.user_id =  "\(dicResult["id"]!)"
                    userDetails.otp_status = "\(dicResult["otp_status"]!)"
                    
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.saveContext()
                    
                    OFASingletonUser.ofabeeUser.initWithDictionary(dicData: dicResult)
                    if "\(dicResult["otp_status"]!)" == "1"{
                        delegate.initializeBrowserCourse()
                    }else{
                        let sessionAlert = UIAlertController(title: "OTP not verified", message: nil, preferredStyle: .alert)
                        sessionAlert.addAction(UIAlertAction(title: "Verify OTP", style: .default, handler: { (action) in
                            let otpPage = self.storyboard?.instantiateViewController(withIdentifier: "OTPTVC") as! OFAOTPTableViewController
                            self.navigationItem.title = ""
                            otpPage.emailID = "\(dicResult["us_email"]!)"
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
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                }
            }else {
                OFAUtils.removeLoadingView(nil)
                if responseJSON.response?.statusCode == 500{
                    
                }else{
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Some error occured, try again later", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension String {
    func md5() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes {
//            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
            _ = CC_MD5($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
//         return Data(bytes: digest).base64EncodedString()
    }
}
