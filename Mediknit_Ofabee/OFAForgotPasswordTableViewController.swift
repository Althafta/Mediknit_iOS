//
//  OFAForgotPasswordTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAForgotPasswordTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet var textEmail: JJMaterialTextfield!
    @IBOutlet weak var buttonSendEmail: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonSendEmail.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        self.buttonSendEmail.layer.cornerRadius = self.buttonSendEmail.frame.height/2
        
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

    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if !OFAUtils.checkEmailValidation(self.textEmail.text!){
            OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:nil, message: (NSLocalizedString("Invalid Email format", comment: "")), cancelButtonTitle: "OK")
        }
        else{
            self.sendPasswordToEmail(emailString: self.textEmail.text!)
            OFAUtils.showToastWithTitle("New password link has been sent to your mail ID")
        }
    }
    
    func sendPasswordToEmail(emailString:String) {
        OFAUtils.showLoadingViewWithTitle("Loading")
        OFAUtils.removeLoadingView(nil)
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [emailString,domainKey], forKeys: ["email" as NSCopying,"domain_key" as NSCopying])
        Alamofire.request(userBaseURL+"api/authenticate/forgot", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Unable to send Password", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
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
