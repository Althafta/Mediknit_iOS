//
//  OLPRegisterTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFARegisterTableViewController: UITableViewController {

    @IBOutlet var textFullName: JJMaterialTextfield!
    @IBOutlet var textPhone: JJMaterialTextfield!
    @IBOutlet var textEmail: JJMaterialTextfield!
    @IBOutlet var textPassword: JJMaterialTextfield!
    
    @IBOutlet weak var buttonRegister: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonRegister.layer.cornerRadius = self.buttonRegister.frame.height/2
        self.buttonRegister.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tapAction(){
        self.view.endEditing(true)
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
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isFieldValidity() {
            let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
            let dicParameters = NSDictionary(objects:[self.textFullName.text!,self.textEmail.text!,self.textPassword.text!,self.textPhone.text!,domainKey], forKeys:["name" as NSCopying,"email" as NSCopying,"password" as NSCopying,"phone" as NSCopying,"domain_key" as NSCopying])
            OFAUtils.showLoadingViewWithTitle("Registering")
            Alamofire.request(userBaseURL+"api/authenticate/register", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
                if let result = responseJSON.result.value {
                    let dicResult = result as! NSDictionary
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                    if "\(dicResult["success"]!)" == "1"{
                        let otpPage = self.storyboard?.instantiateViewController(withIdentifier: "OTPTVC") as! OFAOTPTableViewController
                        self.navigationItem.title = ""
                        otpPage.userEmail = self.textEmail.text!
                        OFAUtils.removeLoadingView(nil)
                        self.navigationController?.pushViewController(otpPage, animated: true)
                    }
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Some error occured, try again later", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
        }
    }
    
    func isFieldValidity() -> Bool {
        if OFAUtils.isWhiteSpace(self.textFullName.text!){
            OFAUtils.showToastWithTitle("Enter Name")
           return false
        }
        if OFAUtils.isWhiteSpace(self.textPhone.text!){
            OFAUtils.showToastWithTitle("Enter Phone")
            return false
        }
        if OFAUtils.isWhiteSpace(self.textEmail.text!){
            OFAUtils.showToastWithTitle("Enter Email")
            return false
        }
        if !OFAUtils.checkEmailValidation(self.textEmail.text!) {
            OFAUtils.showToastWithTitle("Enter a valid Email")
            return false
        }
        
        if OFAUtils.isWhiteSpace(self.textPassword.text!){
            OFAUtils.showToastWithTitle("Enter Name")
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
