//
//  OFAReferAFriendTableViewController.swift
//  Life_Line
//
//  Created by Administrator on 6/25/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAReferAFriendTableViewController: UITableViewController {

    @IBOutlet var fotterView: UIView!
    var arrayProgrammes = NSMutableArray()
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getProgrammes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func getProgrammes(){
        let dicParameters = NSDictionary(objects: [domainKey,accessToken,user_id], forKeys: ["domain_key" as NSCopying,"token" as NSCopying,"user_id" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/referral/refer_events", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let arrayData = dicResult["data"] as! NSArray
                self.arrayProgrammes = arrayData.mutableCopy() as! NSMutableArray
                self.tableView.reloadData()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayProgrammes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReferAFriendCell", for: indexPath) as! OFAReferAFriendTableViewCell
        let dicProgramme = self.arrayProgrammes[indexPath.row] as! NSDictionary
        cell.buttonRefer.tag = indexPath.row
        cell.customizeCellWithDetails(programmeDescription: "\(dicProgramme["description"]!)", imageURLString: "\(dicProgramme["image_url"]!)", programmeTitle: "\(dicProgramme["title"]!)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if OFAUtils.isiPhone(){
            return 300
        }else{
            return 500
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.fotterView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }
    
    //MARK:- Button Action
    
    @IBAction func ReferTheApplicationPressed(_ sender: UIButton) {
        let contactsList = self.storyboard?.instantiateViewController(withIdentifier: "ContactsTVC") as! OFAContactsTableViewController
        contactsList.isAppShare = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(contactsList, animated: true)
    }
    
    @IBAction func referAFriendPressed(_ sender: UIButton) {
        let contactsList = self.storyboard?.instantiateViewController(withIdentifier: "ContactsTVC") as! OFAContactsTableViewController
        contactsList.dicReferredItem = self.arrayProgrammes[sender.tag] as! NSDictionary
        contactsList.isAppShare = false
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(contactsList, animated: true)
    }
    
}
