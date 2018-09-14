//
//  OFAPreLoginTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAPreLoginTableViewController: UITableViewController {

    var emailEntered = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var buttonSignInEmail: UIButton!
    @IBOutlet var buttonSignInFacebook: UIButton!
    @IBOutlet var buttonBrowseCourse: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonSignInEmail.layer.cornerRadius = self.buttonSignInEmail.frame.height/2
        self.buttonSignInFacebook.layer.cornerRadius = self.buttonSignInEmail.frame.height/2
        self.buttonBrowseCourse.layer.cornerRadius = self.buttonSignInEmail.frame.height/2
        self.buttonSignInFacebook.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonSignInFacebook.layer.borderWidth = 1.0
        self.buttonBrowseCourse.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonBrowseCourse.layer.borderWidth = 1.0
        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
        self.tableView.backgroundColor = .white
        
        self.tableView.reloadData()
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
    
    // MARK: - Table view Functions
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !OFAUtils.isiPhone(){
            return 300
        }else{
            return 0
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func signInWithEmailPressed(_ sender: UIButton) {
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginTVC") as! OFALoginTableTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(loginPage, animated: true)
    }
    
    @IBAction func createAnAccountPressed(_ sender: UIButton) {
        let registerPage = self.storyboard?.instantiateViewController(withIdentifier: "RegisterTVC") as! OFARegisterTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(registerPage, animated: true)
    }
    
    @IBAction func browseCoursesPressed(_ sender: UIButton) {
        let browseCourse = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseTVC") as!OFABrowseCourseTableViewController
        self.navigationItem.title = ""
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.pushViewController(browseCourse, animated: true)
    }

}
