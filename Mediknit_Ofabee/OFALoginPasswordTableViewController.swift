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
                //call API to our server and get User details
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
