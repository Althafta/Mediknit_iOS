//
//  OFAPreLoginTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "HomeIcon"), style: .plain, target: self, action: #selector(self.homePressed))
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
    
    @objc func homePressed(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.initializeHomeGridPage()
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
    
    @IBAction func signInWithFacebookPressed(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        OFAUtils.showLoadingViewWithTitle(nil)
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (loginResult, error) in
            if error == nil {
                let fbLoginResult : FBSDKLoginManagerLoginResult = loginResult!
                if fbLoginResult.isCancelled != true {
                    if fbLoginResult.grantedPermissions.contains("email") {
                        self.getFBUserDetails()
                    }
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showToastWithTitle("You have declined permission for Facebook")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle((error?.localizedDescription)!)
            }
        }
        OFAUtils.removeLoadingView(nil)
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
    
    //MARK:- Facebook helpers
    
    func getFBUserDetails(){
        OFAUtils.showLoadingViewWithTitle(nil)
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (graphRequestConnection, result, error) in
                if error==nil{
                    let dictDetails = result as! NSDictionary
                    self.sendFacebookDetailsToBackend(dicDetails: dictDetails)
                    OFAUtils.removeLoadingView(nil)
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showToastWithTitle((error?.localizedDescription)!)
                }
            })
        }
    }
    
    func sendFacebookDetailsToBackend(dicDetails:NSDictionary){
        //{"email":"admin123@ofabee.com","fullname":"admin123","image_url":"http://beta.ofabee.com/uploads/beta.ofabee.com/user/d9a41c55170d08e0e996d7b5ad3694b9.jpg","domain_key":"6"}
        if dicDetails["email"] == nil || "\(dicDetails["email"]!)" == ""{
            self.askForEmailAlert(dicDetails: dicDetails)
        }else{
            self.apiForFacebook(dicDetails: dicDetails, email: "\(dicDetails["email"]!)")
        }
    }
    
    func apiForFacebook(dicDetails:NSDictionary,email:String){
        let fullName = "\(dicDetails["first_name"]!)" + " \(dicDetails["last_name"]!)"
        let dicPicture = dicDetails["picture"] as! NSDictionary
        let dicData = dicPicture["data"] as! NSDictionary
        let fbImageURL = "\(dicData["url"]!)"//"http://graph.facebook.com/\(dicDetails["id"]!)/picture"
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        OFAUtils.showLoadingViewWithTitle("Loading")
        let dicParameters = NSDictionary(objects: [email,fullName,fbImageURL,domainKey], forKeys: ["email" as NSCopying,"fullname" as NSCopying,"image_url" as NSCopying,"domain_key" as NSCopying])
        Alamofire.request(userBaseURL+"api/authenticate/fb_login", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value {
                let dicResponse = result as! NSDictionary
                let dicResult = dicResponse["body"] as! NSDictionary
                
                UserDefaults.standard.set("\(dicResponse["token"]!)", forKey: ACCESS_TOKEN)
                UserDefaults.standard.set("\(dicResult["id"]!)", forKey: USER_ID)
                
                let userDetails = User(context: self.context)
                userDetails.user_name = "\(dicResult["us_name"]!)"
                userDetails.user_email = "\(dicResult["us_email"]!)"
                userDetails.user_image = "\(dicResult["us_image"]!)"
                userDetails.user_phone = "\(dicResult["us_phone"]!)"
                userDetails.user_about = "\(dicResult["us_about"]!)"
                userDetails.user_id =  "\(dicResult["id"]!)"
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.saveContext()
                
                OFASingletonUser.ofabeeUser.initWithDictionary(dicData: dicResult)
                
//                delegate.initializeBrowserCourse()
                delegate.initializeHomeGridPage()
                
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:"Some error occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func askForEmailAlert(dicDetails:NSDictionary) {
        var alertTextField : UITextField?
        let emailAlert = UIAlertController(title: NSLocalizedString("Enter your email ID", comment: "") , message: "Your mail ID cannot be fetched from Facebook", preferredStyle: UIAlertControllerStyle.alert)
        emailAlert.addTextField { (textField) -> Void in
            alertTextField = textField
            textField.placeholder = "Email"
            textField.borderStyle=UITextBorderStyle.none
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .done
            textField.becomeFirstResponder()
        }
        emailAlert.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: UIAlertActionStyle.default, handler: { (alert) -> Void in
            self.view.endEditing(true)
            
            if !OFAUtils.checkEmailValidation((alertTextField?.text)!){
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle:nil, message: (NSLocalizedString("Invalid Email format", comment: "")), cancelButtonTitle: "OK")
            }
            else{
                self.emailEntered = (alertTextField?.text!)!
                self.apiForFacebook(dicDetails: dicDetails, email: self.emailEntered)
            }
        }))
        emailAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.destructive, handler: { (alert) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(emailAlert, animated: true, completion: nil)
    }

}
