//
//  OLPLoginTableTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFALoginTableTableViewController: UITableViewController {

    @IBOutlet var textEmail: JJMaterialTextfield!
    @IBOutlet var textPassword: JJMaterialTextfield!
    @IBOutlet weak var buttonSignIn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userDetails: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonSignIn.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        self.buttonSignIn.layer.cornerRadius = self.buttonSignIn.frame.height/2
        
       OFAUtils.setBackgroundForTableView(tableView: self.tableView)
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
        UIApplication.shared.statusBarStyle = .default
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
//            checkUserLoginDetails()
            let loginPasswordTVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginPasswordTVC") as! OFALoginPasswordTableViewController
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(loginPasswordTVC, animated: true)
        }
    }
    
    func checkUserLoginDetails () {
        OFAUtils.showLoadingViewWithTitle("Loading")
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let encryptedPassword = self.textPassword.text?.md5()
        let dicParameters = NSDictionary(objects: [self.textEmail.text!,encryptedPassword!,domainKey], forKeys: ["email" as NSCopying,"password" as NSCopying,"domain_key" as NSCopying])
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
                        otpPage.userEmail = self.textEmail.text!
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
                            otpPage.userEmail = "\(dicResult["us_email"]!)"
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
