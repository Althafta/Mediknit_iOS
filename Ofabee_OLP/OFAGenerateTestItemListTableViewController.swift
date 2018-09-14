//
//  OFAGenerateTestItemListTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/9/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

protocol didItemSelected {
    func getSelectedCategory(dicCategory:NSDictionary)
    func getSelectedDifficulty(dicItem:NSDictionary)
    func getSelectedDuration(dicItem:NSDictionary,position:String)
    func getSelectedTopics(arrayTopicsSelected:NSMutableArray)
}

class OFAGenerateTestItemListTableViewController: UITableViewController {

    var isTopics = false
    var isCategory = false
    var isDifficulty = false
    var isDuration = false
    
    var arrayItems = NSMutableArray()
    var delegate:didItemSelected!
    
    var arraySelectedTopics = NSMutableArray()
    
    var barButtonSelectAll = UIBarButtonItem()
    var barButtonRemoveAll = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isTopics{
            self.barButtonSelectAll = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(self.selectAllTopicsPressed))
            self.navigationItem.rightBarButtonItem = self.barButtonSelectAll
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.arraySelectedTopics.count > 0 {
            self.delegate.getSelectedTopics(arrayTopicsSelected: self.arraySelectedTopics)
        }
    }
    
    func selectAllTopicsPressed(){
        self.barButtonRemoveAll = UIBarButtonItem(title: "Remove All", style: .plain, target: self, action: #selector(self.removeAllTopicsPressed))
        self.navigationItem.rightBarButtonItem = self.barButtonRemoveAll
        if self.arrayItems.count > 0 {
            for i in 0...self.arrayItems.count-1{
                let dicDetails = self.arrayItems[i] as! NSDictionary
                self.arraySelectedTopics.add(dicDetails)
            }
        }else{
//            self.barButtonSelectAll.isEnabled = false
        }
        self.tableView.reloadData()
    }
    
    func removeAllTopicsPressed(){
        self.barButtonSelectAll = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(self.selectAllTopicsPressed))
        self.navigationItem.rightBarButtonItem = self.barButtonSelectAll
        self.arraySelectedTopics.removeAllObjects()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemList", for: indexPath)

        let dicDetails = self.arrayItems[indexPath.row] as! NSDictionary
        if isCategory{
            cell.textLabel?.text = "\(dicDetails["ct_name"]!)"
        }else if isDifficulty{
            cell.textLabel?.text = "\(dicDetails["level"]!)"
        }else if isTopics{
            cell.textLabel?.text = "\(dicDetails["qc_category_name"]!)"
            if self.arraySelectedTopics.contains(dicDetails){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }else if isDuration{
            cell.textLabel?.text = "\(dicDetails["time"]!)"
        }
        cell.tintColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        let dicDetails = self.arrayItems[indexPath.row] as! NSDictionary
        if isTopics{
            if cell?.accessoryType == .checkmark{
                cell?.accessoryType = .none
                self.arraySelectedTopics.remove(dicDetails)
            }else{
                cell?.accessoryType = .checkmark
                self.arraySelectedTopics.add(dicDetails)
            }
        }else{
            cell?.accessoryType = .checkmark
            if isCategory{
                self.delegate.getSelectedCategory(dicCategory: dicDetails)
            }else if isDifficulty{
                self.delegate.getSelectedDifficulty(dicItem: dicDetails)
            }else if isDuration{
                self.delegate.getSelectedDuration(dicItem: dicDetails, position: "\(indexPath.row)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
   
}
