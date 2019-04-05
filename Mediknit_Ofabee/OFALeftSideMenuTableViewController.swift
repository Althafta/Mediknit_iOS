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
    
    var arraySideMenu = ["Dashboard","My Courses","My Profile","Logout"]
    var arrayIdentifiers = ["DashboardTVC","MyCourseTVC","ProfileTVC",""]
    
    var currentRow:Int = 0
    var currentSection = 0
    
    var lastSelectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panel!.configs.leftPanelWidth = self.view.frame.width - self.view.frame.width/5
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadProfileDetails(notification:)), name: NSNotification.Name(rawValue: "EditProfileNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadUserDetails(notification:)), name: NSNotification.Name(rawValue: "EditProfileDetailsNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = OFAUtils.getColorFromHexString("8FD5FA").cgColor
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
    
    @objc func loadUserDetails(notification:Notification){
        let dicUserInfo = notification.userInfo! as NSDictionary
        self.labelUserName.text = "\(dicUserInfo["name"]!)"
        self.tableView.reloadData()
    }
    
    @objc func loadProfileDetails(notification:Notification){
        let dicUserInfo = notification.userInfo! as NSDictionary
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = OFAUtils.getColorFromHexString("8FD5FA").cgColor
        self.labelUserName.text = "\(dicUserInfo["name"]!)"
        if OFASingletonUser.ofabeeUser.user_imageURL != nil{
            self.imageViewUser.sd_setImage(with: URL(string: "\(dicUserInfo["image"]!)"), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .refreshCached)
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
        
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.text = self.arraySideMenu[indexPath.row]
        if indexPath.row == currentRow {
            cell.backgroundColor = OFAUtils.getColorFromHexString("D3EEFD")
        }else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentRow = indexPath.row
        currentSection = indexPath.section
        
        lastSelectedRow=currentRow

        let identifier = self.arrayIdentifiers[indexPath.row]
        
        
        if indexPath.row == 3{
            self.logout()
        }else{
            let centerVC: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: identifier))!
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            
            panel!.configs.bounceOnCenterPanelChange = true
            panel!.center(centerNavVC, afterThat: {
                print("Executing block after changing center panelVC From Left Menu")
            })
        }
        
        self.tableView .reloadRows(at: [IndexPath(row: currentRow, section: currentSection),IndexPath(row: lastSelectedRow, section: 0)], with:UITableView.RowAnimation.fade)
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
}
