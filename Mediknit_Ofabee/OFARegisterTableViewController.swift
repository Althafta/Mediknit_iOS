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

class OFARegisterTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet var textFirstName: JJMaterialTextfield!
    @IBOutlet var textLastName: JJMaterialTextfield!
    @IBOutlet var textSalutation: JJMaterialTextfield!
    @IBOutlet var textPassword: JJMaterialTextfield!
    
    @IBOutlet weak var buttonRegister: UIButton!
    
    var isSocialLogin = false
    var socialFirstName = ""
    var socialLastName = ""
    var socialEmail = ""
    var emailID = ""
    
    var isDeclarationSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonRegister.layer.cornerRadius = self.buttonRegister.frame.height/2
        self.buttonRegister.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
        if isSocialLogin{
            self.textFirstName.text = self.socialFirstName
            self.textLastName.text = self.socialLastName
            self.textPassword.isHidden = true
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
    
    @IBAction func declarationPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.isDeclarationSelected = !self.isDeclarationSelected
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isFieldValidity(){
            var dicParameters = NSDictionary()
            let userId = UserDefaults.standard.value(forKey: USER_ID) as! String
            if !isSocialLogin{
                dicParameters = NSDictionary(objects: [userId,self.textSalutation.text!,self.textFirstName.text!,self.textLastName.text!,self.textPassword.text!,"0"], forKeys: ["user_id" as NSCopying,"salutation" as NSCopying,"first_name" as NSCopying,"last_name" as NSCopying,"password" as NSCopying,"open_auth" as NSCopying])
            }else{
                dicParameters = NSDictionary(objects: [userId,self.textSalutation.text!,self.textFirstName.text!,self.textLastName.text!,"1"], forKeys: ["user_id" as NSCopying,"salutation" as NSCopying,"first_name" as NSCopying,"last_name" as NSCopying,"open_auth" as NSCopying])
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
                if let dicResult = responseJSON.result.value as? NSDictionary{
                    print(dicResult)
                    OFAUtils.removeLoadingView(nil)
                    //call API to our server and get User details
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
        }
    }
    
    func isFieldValidity() -> Bool {
        if OFAUtils.isWhiteSpace(self.textSalutation.text!){
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
        if OFAUtils.isWhiteSpace(self.textPassword.text!){
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

}
