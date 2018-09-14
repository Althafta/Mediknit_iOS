//
//  OFALeftSideMenuTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import FAPanels

class OFALeftSideMenuTableViewController: UITableViewController {

    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelUserName: UILabel!
    
    @IBOutlet var buttonLinkedIn: UIButton!
    @IBOutlet var buttonInstagram: UIButton!
    @IBOutlet var buttonYoutube: UIButton!
    @IBOutlet var buttonTwitter: UIButton!
    @IBOutlet var buttonPintrest: UIButton!
    @IBOutlet var buttonFacebook: UIButton!

    var arraySideMenu = ["Home","My Courses","Refer A Friend","Store","Blog","Upcoming Events","My Profile","Logout"]
    //var arrayIdentifiers = ["MyCourseTVC","ChallengesTVC","ReferContainerVC","WebViewController","WebViewControllerBlog","WebViewEventsController","ProfileTVC",""]
    var arrayIdentifiers = ["HomePageGrid","MyCoursesContainerVC","ReferContainerVC","WebViewController","WebViewControllerBlog","WebViewEventsController","ProfileTVC",""]

    var arrayLinks = ["https://www.linkedin.com/in/drppvijayan/","https://www.instagram.com/drppvijayan/?hl=en","https://www.youtube.com/lifelinetv","https://twitter.com/drppvijayan","https://in.pinterest.com/drppvijayan/pins/","https://www.facebook.com/LifelineDr.ppVijayan"]
    
    var currentRow:Int = 0
    var currentSection = 0
    
    var lastSelectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panel!.configs.leftPanelWidth = self.view.frame.width - self.view.frame.width/5
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadProfileDetails(notification:)), name: NSNotification.Name(rawValue: "EditProfileNotification"), object: nil)
        
        self.buttonLinkedIn.fa.setTitle(.fa_linkedin_square, for: .normal)
        self.buttonInstagram.fa.setTitle(.fa_instagram, for: .normal)
        self.buttonYoutube.fa.setTitle(.fa_youtube_square, for: .normal)
        self.buttonTwitter.fa.setTitle(.fa_twitter_square, for: .normal)
        self.buttonPintrest.fa.setTitle(.fa_pinterest, for: .normal)
        self.buttonFacebook.fa.setTitle(.fa_facebook, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = UIColor.white.cgColor
        if OFASingletonUser.ofabeeUser.user_imageURL != nil{
            self.imageViewUser.sd_setImage(with: URL(string: OFASingletonUser.ofabeeUser.user_imageURL!), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
            self.labelUserName.text = OFASingletonUser.ofabeeUser.user_name!
        }else{
            self.imageViewUser.image = #imageLiteral(resourceName: "Default image")
        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func loadProfileDetails(notification:Notification){
        let dicUserInfo = notification.userInfo! as NSDictionary
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = UIColor.white.cgColor
        if OFASingletonUser.ofabeeUser.user_imageURL != nil{
            self.imageViewUser.sd_setImage(with: URL(string: "\(dicUserInfo["image"]!)"), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
            self.labelUserName.text = "\(dicUserInfo["name"]!)"
        }else{
            self.imageViewUser.image = #imageLiteral(resourceName: "Default image")
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arraySideMenu.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! OFALeftSideTableViewCell
        
        cell.textLabel?.text = self.arraySideMenu[indexPath.row]
        if indexPath.row == currentRow {//&& indexPath.section == currentSection {
            cell.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
//            cell.textLabel?.textColor = .white
        }else{
            cell.backgroundColor = UIColor.white
//            cell.textLabel?.textColor = .black
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentRow = indexPath.row
        currentSection = indexPath.section
        
        lastSelectedRow=currentRow

        let identifier = self.arrayIdentifiers[indexPath.row]
        
        
        if indexPath.row == 7{
            self.logout()
        }else{
            let centerVC: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: identifier))!
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            
            panel!.configs.bounceOnCenterPanelChange = true
            panel!.center(centerNavVC, afterThat: {
                print("Executing block after changing center panelVC From Left Menu")
            })
        }
        
        self.tableView .reloadRows(at: [IndexPath(row: currentRow, section: currentSection),IndexPath(row: lastSelectedRow, section: 0)], with:UITableViewRowAnimation.fade)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 182
    }
    
    func logout(){
        //close FAPanel - left side
        let logoutAlert = UIAlertController(title: "Do you want to logout?", message: nil, preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.logout()
        }))
        logoutAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(logoutAlert, animated: true, completion: nil)
    }
    
    //MARK:- Button Actions
    
    @IBAction func socialButtonsPressed(_ sender: UIButton) {
        let socialWebView = self.storyboard?.instantiateViewController(withIdentifier: "SocialLinksVC") as! OFAWebViewSocialLinksViewController
        socialWebView.contentURL = self.arrayLinks[sender.tag]
        let centerNavVC = UINavigationController(rootViewController: socialWebView)
        panel!.configs.bounceOnCenterPanelChange = true
        panel!.center(centerNavVC, afterThat: {
            print("Executing block after changing center panelVC From Left Menu")
        })
    }
}
