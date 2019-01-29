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
    
    @IBAction func registerPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isFieldValid(){
            OFAUtils.showLoadingViewWithTitle("Loading")
            let userID = UserDefaults.standard.value(forKey: USER_ID) as! String
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
                    //call API to our server and get User details
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
            //            OFAUtils.showToastWithTitle("Password mismatch")
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
