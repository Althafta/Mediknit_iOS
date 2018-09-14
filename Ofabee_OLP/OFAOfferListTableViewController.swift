//
//  OFAOfferListTableViewController.swift
//  Life_Line
//
//  Created by Administrator on 6/27/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAOfferListTableViewController: UITableViewController {

    var arrayOffers = NSMutableArray()
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getOffers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //AMRK:- Get Offers
    
    func getOffers(){
        let dicParameters = NSDictionary(objects: [domainKey,accessToken,user_id], forKeys: ["domain_key" as NSCopying,"token" as NSCopying,"user_id" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/referral/offers", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                self.arrayOffers = arrayData.mutableCopy() as! NSMutableArray
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
        return self.arrayOffers.count
    }
    /*
     {
     code = "";
     "created_at" = "2018-06-08 12:54:56";
     description = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.";
     expire = "2018-06-08 04:24:56";
     id = 1;
     "is_active" = 0;
     title = hello;
     type = 1;
     },
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offerList", for: indexPath) as! OFAOfferListTableViewCell
        
        let dicOfferDetails = self.arrayOffers[indexPath.row] as! NSDictionary
        cell.customizeCellWithDetails(offerTitle: "\(dicOfferDetails["title"]!)", offerDescription: "\(dicOfferDetails["description"]!)", offerCode: "\(dicOfferDetails["code"]!)", offerExpiry: OFAUtils.getDateStringFromDate(OFAUtils.getDateFromString("\(dicOfferDetails["expire"]!)")))
        cell.buttonUseCode.tag = indexPath.row
        (cell.buttonUseCode.isHidden,cell.labelStaticUseCode.isHidden,cell.labelStaticExpiry.isHidden,cell.labelExpiry.isHidden) = "\(dicOfferDetails["type"]!)" == "1" ? (true,true,true,true) : (false,false,false,false)
//        cell.labelStaticUseCode.isHidden = "\(dicOfferDetails["type"]!)" == "1" ? true : false
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        self.tableView.estimatedRowHeight = 200
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        let dicOfferDetails = self.arrayOffers[indexPath.row] as! NSDictionary
        return "\(dicOfferDetails["type"]!)" == "1" ? 144 :  220
//        return self.tableView.rowHeight
    }
//
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.backgroundColor = OFAUtils.getColorFromHexString(backgroundColor)
//    }
    
    //MARK:- Button Actions
    
    @IBAction func useCodePressed(_ sender: UIButton) {
        let dicOfferDetails = self.arrayOffers[sender.tag] as! NSDictionary
        UIPasteboard.general.string = "\(dicOfferDetails["code"]!)"
        OFAUtils.showToastWithTitle("Text copied")
    }
}
