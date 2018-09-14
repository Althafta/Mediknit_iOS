//
//  OLPOTPTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAOTPTableViewController: UITableViewController {

    @IBOutlet var textOTP: UITextField!
    @IBOutlet var labelCountDown: UILabel!
    @IBOutlet var buttonResendOTP: UIButton!
    @IBOutlet weak var buttonDone: UIButton!
    
    var userEmail = ""
    var seconds = 60
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonResendOTP.isHidden = true
        self.buttonResendOTP.layer.cornerRadius = self.buttonResendOTP.frame.height/2
        self.buttonResendOTP.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
        self.buttonDone.layer.cornerRadius = self.buttonDone.frame.height/2
        self.buttonDone.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        
        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
        self.runTimer()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tapAction(){
        self.view.endEditing(true)
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabel), userInfo: nil, repeats: true)
    }
    
    func updateLabel(){
        seconds -= 1
        self.labelCountDown.text = "\(seconds)" + " seconds left"
        if seconds <= 0 {
            timer.invalidate()
            self.textOTP.isEnabled = false
            self.labelCountDown.isHidden = true
            self.buttonResendOTP.isHidden = false
        }
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
    
    @IBAction func resendOTPPressed(_ sender: UIButton) {
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects:[userEmail,domainKey], forKeys:["email_id" as NSCopying,"domain_key" as NSCopying])
        Alamofire.request(userBaseURL+"api/authenticate/send_otp", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            self.labelCountDown.isHidden = false
            self.buttonResendOTP.isHidden = true
            self.textOTP.isEnabled = true
            self.seconds = 60
            self.runTimer()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if OFAUtils.isWhiteSpace(self.textOTP.text!){
            OFAUtils.showToastWithTitle("Enter OTP you recieved")
            return
        }
        OFAUtils.showLoadingViewWithTitle("Verifying")
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects:[self.textOTP.text!,userEmail,domainKey], forKeys:["otp_number" as NSCopying,"email_id" as NSCopying,"domain_key" as NSCopying])
        Alamofire.request(userBaseURL+"api/authenticate/verify_otp", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.initializeLoginPage()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
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
