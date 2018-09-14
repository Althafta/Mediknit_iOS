//
//  OFAContactsTableViewController.swift
//  Life_Line
//
//  Created by Administrator on 6/26/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Contacts
import Alamofire

class OFAContactsTableViewController: UITableViewController,UISearchBarDelegate {

    @IBOutlet var searchBarContacts: UISearchBar!
    var arrayContacts = [ContactStruct]()
    var filteredContactArray = [ContactStruct]()
    var contactStore = CNContactStore()
    
    var dicReferredItem = NSDictionary()
    var isAppShare = false
    
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    var arrayContactsInvited = NSArray()
    var arraySelectedContacts = NSMutableArray()
    
    var referItemType = ""
    var referItemID = ""
    var courseID = ""
    var searchString = ""
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isAppShare{
            if self.dicReferredItem.count > 0 {
                self.referItemType = "\(dicReferredItem["type"]!)"
                self.referItemID = "\(dicReferredItem["id"]!)"
            }else{
                self.referItemType = "2"
                self.referItemID = self.courseID
            }
        }else{
            self.referItemType = "3"
            self.referItemID = ""
        }
        
        self.getInvitedContacts()
        self.contactStore.requestAccess(for: CNEntityType.contacts) { (success, error) in
            if success{
                print("Authorized")
            }
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextPressed))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Select Contacts"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK:- fetch all Contacts
    
    func fetchContacts(){
        let keyDescriptor = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keyDescriptor)
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        do{
            try contactStore.enumerateContacts(with: fetchRequest) { (contact, stoppingPointer) in
                let name = contact.givenName
                let familyName = contact.familyName
                var thumbnailImage = UIImage()
//                var arrayNumberString = [String]()
                let arrayNumber = contact.phoneNumbers
                if contact.thumbnailImageData != nil {
                    thumbnailImage = UIImage(data: contact.thumbnailImageData!)!
                }else{
                    thumbnailImage = #imageLiteral(resourceName: "Default image")
                }
                for item in arrayNumber{
                    let value = item.value
//                    arrayNumberString.append(value.stringValue)
//                    print(value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ""))
                    let contactToAppend = ContactStruct(givenName: name, familyName: familyName, number: value.stringValue, thumbImage: thumbnailImage)
                    self.arrayContacts.append(contactToAppend)
                }
//                let contactToAppend = ContactStruct(givenName: name, familyName: familyName, number: arrayNumberString.joined(separator: ","))
                self.filteredContactArray = self.arrayContacts
                self.filterContacts()
                self.tableView.reloadData()
            }
        }catch{
            print("Contact fetch failed")
        }
    }
    
    //MARK:- get invited Contacts
    
    func filterContacts(){
        var arrayInvitedNumbers = [String]()
        for item in self.arrayContactsInvited{
            let dicContact = item as! NSDictionary
            arrayInvitedNumbers.append("\(dicContact["phone"]!)")
        }
        var index = 0
        for dicContact in self.filteredContactArray{
            if arrayInvitedNumbers.contains(dicContact.number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")){
                self.arrayContacts.remove(at: index)
            }
            index += 1
        }
        
        self.tableView.reloadData()
    }
    
    func getInvitedContacts(){
        var dicParameters = NSDictionary()
        if isAppShare{
            dicParameters = NSDictionary(objects: [domainKey,accessToken,user_id,"3",""], forKeys: ["domain_key" as NSCopying,"token" as NSCopying,"user_id" as NSCopying,"item_type" as NSCopying,"item_id" as NSCopying])
        }else{
            dicParameters = NSDictionary(objects: [domainKey,accessToken,user_id,self.referItemType,self.referItemID], forKeys: ["domain_key" as NSCopying,"token" as NSCopying,"user_id" as NSCopying,"item_type" as NSCopying,"item_id" as NSCopying])
        }
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/referral/get_invites", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                let arrayContacts = dicResult["contacts"] as! NSArray
                print(arrayContacts)
                self.arrayContactsInvited = arrayContacts
                self.fetchContacts()
                OFAUtils.removeLoadingView(nil)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredContactArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactList", for: indexPath) as! OFAContactListTableViewCell
        let contactDetails = filteredContactArray[indexPath.row]
        var dicDetails = Dictionary<String,Any>()
        dicDetails["name"] = contactDetails.givenName + " " + contactDetails.familyName
        dicDetails["phone"] = contactDetails.number
        cell.customizeCellWithDetails(imageDetails: contactDetails.thumbImage, name: contactDetails.givenName + " " + contactDetails.familyName, phoneNumber: contactDetails.number)
        if self.arraySelectedContacts.contains(dicDetails){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        let contactDetails = self.filteredContactArray[indexPath.row]
        var dicDetails = Dictionary<String,Any>()
        dicDetails["name"] = contactDetails.givenName + " " + contactDetails.familyName
        dicDetails["phone"] = contactDetails.number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if cell?.accessoryType == .checkmark{
            cell?.accessoryType = .none
            self.arraySelectedContacts.remove(dicDetails)
        }else{
            cell?.accessoryType = .checkmark
            self.arraySelectedContacts.add(dicDetails)
//            if self.arraySelectedContacts.count >= 10{
//                OFAUtils.showToastWithTitle("Only 10 friends can be invited at a time")
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.tintColor = OFAUtils.getColorFromHexString(barTintColor)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchBarContacts
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    //MARK:- Button Actions
    
    @objc func nextPressed(){
        if self.arraySelectedContacts.count > 0{
            let dicParameters = NSDictionary(objects: [domainKey,accessToken,user_id,self.referItemType,self.referItemID,self.arraySelectedContacts.copy() as! NSArray,"2"], forKeys: ["domain_key" as NSCopying,"token" as NSCopying,"user_id" as NSCopying,"item_type" as NSCopying,"item_id" as NSCopying,"contacts" as NSCopying,"os" as NSCopying])
            OFAUtils.showLoadingViewWithTitle("Loading")
            Alamofire.request(userBaseURL+"api/referral/refer_friend", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
                if let dicResult = responseJSON.result.value as? NSDictionary{
                    print(dicResult)
                    OFAUtils.removeLoadingView(nil)
                    self.navigationController?.popToRootViewController(animated: true)
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
        }
    }
    
    //MARK:- Searchbar Delegates
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchString = searchBar.text else {
            return
        }
        self.filteredContactArray = self.arrayContacts.filter({ (contact) -> Bool in
            if searchString == ""{
                self.filteredContactArray = self.arrayContacts
                return true
            }else{
                return contact.givenName.lowercased().contains(searchString.lowercased())
            }
        })
        self.tableView.reloadData()
    }
    
    
}
