//
//  OLPRegisterTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import GoogleSignIn
import DropDown

class OFARegisterTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet var textFirstName: JJMaterialTextfield!
    @IBOutlet var textLastName: JJMaterialTextfield!
    @IBOutlet var textPassword: JJMaterialTextfield!
    @IBOutlet weak var buttonSalutation: UIButton!
    
    @IBOutlet weak var labelStaticPassword: UILabel!
    @IBOutlet weak var buttonRegister: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userDetails: [User] = []
    
    var isSocialLogin = false
    var socialFirstName = ""
    var socialLastName = ""
    var socialEmail = ""
    var emailID = ""
    
    var max_length = 30
    
    var isDeclarationSelected = false
    let chooseSalutationDropDown = DropDown()
    var salutationSelected = ""
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonRegister.layer.cornerRadius = self.buttonRegister.frame.height/2
        self.buttonRegister.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
//        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
        self.getSalutation()
        
        if isSocialLogin{
            self.textFirstName.text = self.socialFirstName
            self.textLastName.text = self.socialLastName
            self.textPassword.isHidden = true
            self.labelStaticPassword.isHidden = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.disconnectGoogleUser))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    @objc func disconnectGoogleUser(){
        let sessionAlert = UIAlertController(title: "Switch User?", message: "Switching user will disconnect current login", preferredStyle: .alert)
        sessionAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            GIDSignIn.sharedInstance().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        sessionAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            sessionAlert.dismiss(animated: true, completion: nil)
        }))
        self.present(sessionAlert, animated: true, completion: nil)
    }
    
    func getSalutation(){
//        var dicJSONRequest = Dictionary<String,Any>()
//        dicJSONRequest["request_body"] = NSDictionary(objects: ["salutation"], forKeys: ["action" as NSCopying])
//        let dicParameters = dicJSONRequest
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/authenticate/salutation", method: .post, parameters: [:], encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if  let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["success"]!)" == "1"{
                    self.max_length = dicResult["max_length"] as! Int
                    print(dicResult["salutation"] as! NSArray)
                    self.chooseSalutationDropDown.anchorView = self.buttonSalutation
                    self.chooseSalutationDropDown.bottomOffset = CGPoint(x: 0, y: self.buttonSalutation.bounds.height)
                    self.chooseSalutationDropDown.dataSource = (dicResult["salutation"] as! NSArray) as! [String]
                    self.chooseSalutationDropDown.selectionAction = { [weak self] (index, item) in
                        self?.salutationSelected = item
                        self?.buttonSalutation.setTitle(self?.salutationSelected, for: .normal)
                    }
                }
            }else{
                print("Salutation API failed")
            }
        }
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        let appearance = chooseSalutationDropDown
        
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
    
    //MARK:- Button Action
    
    @IBAction func salutationPressed(_ sender: UIButton) {
        self.customizeDropDown(self)
        self.chooseSalutationDropDown.show()
    }
    
    @IBAction func declarationPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.isDeclarationSelected = !self.isDeclarationSelected
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isFieldValidity(){
            var dicParameters = NSDictionary()
            let userId = UserDefaults.standard.value(forKey: CLIENT_USER_ID) as! String
            if !isSocialLogin{
                dicParameters = NSDictionary(objects: [userId,self.salutationSelected,self.textFirstName.text!,self.textLastName.text!,self.textPassword.text!,"0"], forKeys: ["user_id" as NSCopying,"salutation" as NSCopying,"first_name" as NSCopying,"last_name" as NSCopying,"password" as NSCopying,"open_auth" as NSCopying])
            }else{
                dicParameters = NSDictionary(objects: [userId,self.salutationSelected,self.textFirstName.text!,self.textLastName.text!,"1"], forKeys: ["user_id" as NSCopying,"salutation" as NSCopying,"first_name" as NSCopying,"last_name" as NSCopying,"open_auth" as NSCopying])
            }
            OFAUtils.showLoadingViewWithTitle("Loading")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dicParameters, options: .sortedKeys)
            let jsonString = String(data: jsonData, encoding: .utf8)
            let timeStamp = "\(OFAUtils.getTimeStamp())"
            let secretString = "POST+\(jsonString!)+\(timeStamp)"
            let base64EncodedJSONString = secretString.data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
            let sha256EncodedSecretString = base64EncodedJSONString?.hmac(algorithm: .SHA256, key: loginSecretKey)
            
            var request = URLRequest(url: URL(string: loginBaseURL + "basic-details-registration")!)
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
                        if let arrayCourses = dicData["courses"] as? NSArray{
                            let dataCoursesArray = NSKeyedArchiver.archivedData(withRootObject: arrayCourses)
                            UserDefaults.standard.setValue(dataCoursesArray, forKey: Subscribed_Courses)
                        }
                        let userID = UserDefaults.standard.value(forKey: CLIENT_USER_ID) as! String
                        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
                        let fcmToken = UserDefaults.standard.value(forKey: FCM_token) as! String
                        let dicParameters = NSDictionary(objects: [self.emailID,userID,self.salutationSelected,self.textFirstName.text!,self.textLastName.text!,self.textPassword.text!,domainKey,"ios","\(OFAUtils.getAppVersion())","\(OFAUtils.getDeviceID())",fcmToken], forKeys: ["email" as NSCopying,"user_id" as NSCopying,"salutation" as NSCopying,"firstname" as NSCopying,"lastname" as NSCopying,"password" as NSCopying,"domain_key" as NSCopying,"platform" as NSCopying,"app_version" as NSCopying,"device" as NSCopying,"fcm_token" as NSCopying])
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
    
    //MARK:- Validation Helpers
    
    func isFieldValidity() -> Bool {
        if self.salutationSelected == ""{
            OFAUtils.showToastWithTitle("Enter salutaion")
            return false
        }
        if OFAUtils.isWhiteSpace(self.textFirstName.text!){
            OFAUtils.showToastWithTitle("Enter first name")
           return false
        }
        if OFAUtils.isWhiteSpace(self.textLastName.text!){
            OFAUtils.showToastWithTitle("Enter last name")
            return false
        }
        if OFAUtils.isWhiteSpace(self.textPassword.text!) && !isSocialLogin{
            OFAUtils.showToastWithTitle("Enter password")
            return false
        }
        if !self.isDeclarationSelected{
            OFAUtils.showToastWithTitle("Declaration missing")
            return false
        }
        return true
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
        let maxLength = self.max_length
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
}
