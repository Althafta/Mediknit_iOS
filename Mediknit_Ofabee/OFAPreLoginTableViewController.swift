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
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
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
        
//        OFAUtils.setBackgroundForTableView(tableView: self.tableView)
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
            
            let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
            let dicParameters = NSDictionary(objects: [givenName!,familyName!,email!,idToken!,domainKey], forKeys: ["first_name" as NSCopying,"last_name" as NSCopying,"email" as NSCopying,"id_token" as NSCopying,"domain_key" as NSCopying])
            self.loginAPICallWith(parameters: dicParameters, givenName: givenName!, familyName: familyName!, email: email!)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        OFAUtils.showToastWithTitle("Failed with error: \(error.localizedDescription)")
    }
    
    func loginAPICallWith(parameters:NSDictionary,givenName:String,familyName:String,email:String){
        Alamofire.request(userBaseURL+"api/authenticate/social_signup", method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            
            if let result = responseJSON.result.value {
                let dicResponse = result as! NSDictionary
                if let token = dicResponse["token"] {
                    let dicResult = dicResponse["body"] as! NSDictionary
                    
                    UserDefaults.standard.set(token as! String, forKey: ACCESS_TOKEN)
                    UserDefaults.standard.set("\(dicResult["id"]!)", forKey: USER_ID)
                    
                    let userDetails = User(context: self.context)
                    userDetails.user_name = "\(dicResult["us_name"]!)"
                    userDetails.user_email = "\(dicResult["us_email"]!)"
                    userDetails.user_image = "\(dicResult["us_image"]!)"
                    userDetails.user_phone = "\(dicResult["us_phone"]!)"
                    userDetails.user_about = "\(dicResult["us_about"]!)"
                    userDetails.user_id =  "\(dicResult["id"]!)"
                    userDetails.otp_status = "\(dicResult["otp_status"]!)"
                    
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.saveContext()
                    
                    OFASingletonUser.ofabeeUser.initWithDictionary(dicData: dicResult)
                    
                    delegate.initializeBrowserCourse()
                    
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")//"Logged in successfully" message from DB
                }else{
                     OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicResponse["message"]!)", cancelButtonTitle: "OK")
                }
            }else {
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Some error occured, try again later", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
}
