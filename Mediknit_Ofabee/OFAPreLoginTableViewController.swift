//
//  OFAPreLoginTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import GoogleSignIn

class OFAPreLoginTableViewController: UITableViewController,GIDSignInDelegate,GIDSignInUIDelegate {

    var emailEntered = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var buttonSignInEmail: UIButton!
    @IBOutlet var buttonSignInGoogle: UIButton!
    @IBOutlet var buttonBrowseCourse: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        self.buttonSignInEmail.layer.cornerRadius = self.buttonSignInEmail.frame.height/2
        self.buttonSignInGoogle.layer.cornerRadius = self.buttonSignInGoogle.frame.height/2
        self.buttonBrowseCourse.layer.cornerRadius = self.buttonSignInEmail.frame.height/2
        
        self.buttonSignInGoogle.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.buttonSignInGoogle.layer.borderWidth = 1.0
        
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
    
    @IBAction func signInWithGooglePressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
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
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.pushViewController(browseCourse, animated: true)
    }

    //MARK:- Google Sign In Delegate
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            OFAUtils.showToastWithTitle("\(error.localizedDescription)")
        }else{
            //let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            var dicJSONRequest = Dictionary<String,Any>()
            let dicContent = NSDictionary(objects: [givenName!,familyName!,email!,idToken!], forKeys: ["first_name" as NSCopying,"last_name" as NSCopying,"email" as NSCopying,"id_token" as NSCopying])
            dicJSONRequest["request_body"] = NSDictionary(objects: ["social_signup",dicContent], forKeys: ["action" as NSCopying,"content" as NSCopying])
            let dicParameters = dicJSONRequest
//            self.loginAPICallWith(parameters: dicParameters, givenName: givenName!, familyName: familyName!, email: email!, isSocial: true)
            OFAUtils.showToastWithTitle("Send data to backend")
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        OFAUtils.showToastWithTitle("Failed with error: \(error.localizedDescription)")
    }
}
