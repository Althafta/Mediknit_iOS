//
//  OFADomainTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFADomainTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet var headerViewDomainDetails: UIView!
    
    @IBOutlet var textDomainName: OFACustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        
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
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    // MARK: - Table view functions
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerViewDomainDetails
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.view.frame.height-18
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
    
    //MARK:- Button Actions
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if OFAUtils.isWhiteSpace(self.textDomainName.text!) {
            OFAUtils.showToastWithTitle("Enter Domain Name")
            return
        }
        UserDefaults.standard.set(self.textDomainName.text!, forKey: DomainKey)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.initializePreLoginPage()
    }
}
