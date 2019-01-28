//
//  OFALoginPasswordTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 28/01/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit

class OFALoginPasswordTableViewController: UITableViewController {

    @IBOutlet weak var textPassword: JJMaterialTextfield!
    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var buttonGenerateOTP: UIButton!
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
        if OFAUtils.isWhiteSpace(textPassword.text!){
            OFAUtils.showToastWithTitle("Please enter password")
        }else{
            //Login using password from medknit server
        }
    }

    @IBAction func generateOTPPressed(_ sender: UIButton) {
        
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
