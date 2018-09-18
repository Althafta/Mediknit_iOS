//
//  OFAMyProfileTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAMyProfileTableViewController: UITableViewController {

    @IBOutlet var imageViewBG: UIImageView!
    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var labelEmail: UILabel!
    @IBOutlet var labelPhone: UILabel!
    @IBOutlet var textViewBio: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem(isSidemenuEnabled: true)
        
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewBio.dropShadow()
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "profileEdit"), style: .plain, target: self, action: #selector(self.editPressed))
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Profile"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        if OFASingletonUser.ofabeeUser.user_imageURL != nil{
            self.imageViewUser.sd_setImage(with: URL(string: OFASingletonUser.ofabeeUser.user_imageURL!), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
            self.labelUserName.text = OFASingletonUser.ofabeeUser.user_name!
            self.labelEmail.text = OFASingletonUser.ofabeeUser.user_email!
            if OFASingletonUser.ofabeeUser.user_phone! == "0"{
                self.labelPhone.text = "Not Available"
            }else{
                self.labelPhone.text = OFASingletonUser.ofabeeUser.user_phone!
            }
            self.textViewBio.text = OFASingletonUser.ofabeeUser.user_about!
        }else{
            self.imageViewUser.image = #imageLiteral(resourceName: "Default image")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK:- Button Actions
    
    @objc func editPressed(){
        let editProfile = self.storyboard?.instantiateViewController(withIdentifier: "EditMyProfileTVC") as! OFAEditMyProfileTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(editProfile, animated: true)
    }
}
