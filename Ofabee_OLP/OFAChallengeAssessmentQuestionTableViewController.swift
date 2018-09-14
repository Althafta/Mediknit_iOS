//
//  OFAChallengeAssessmentQuestionTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/1/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAChallengeAssessmentQuestionTableViewController: UITableViewController,UIWebViewDelegate {

    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet var webViewQuestion: UIWebView!
    
    @IBOutlet var textViewDescription: UITextView!
    var dicQuestion = Dictionary<String,Any>()
    
    var arrayOptions = NSMutableArray()
    var isMultipleChoice = false
    var isDescriptiveType = false
    var isSingleSelection = false
    var isAnswerExplanationAvailable = false
    
    var arrayOptionAlphabets = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var arraySelectedIndices = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
        self.webViewQuestion.delegate = self
        self.webViewQuestion.scrollView.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        if let headerView = self.tableHeaderView {
            let height = self.webViewQuestion.scrollView.contentSize.height+30//headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height+60
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengesAnswerOptionCell", for: indexPath) as! OFAChallengesAssessmentAnswerOptionsTableViewCell
        
        var dicOptions = self.arrayOptions[indexPath.row] as! Dictionary<String,Any>
        cell.webViewOptions.scrollView.isScrollEnabled = false
        
        cell.webViewOptions.tag = indexPath.row
        cell.labelOptionCount.text = "\(self.arrayOptionAlphabets[indexPath.row]). "
        cell.webViewOptions.loadHTMLString("\(dicOptions["qo_options"]!)", baseURL: nil)
        
        
        cell.buttonCheckbox.tag = indexPath.row
        cell.buttonCheckbox.setImage(#imageLiteral(resourceName: "SquareUnCheck").withRenderingMode(.alwaysTemplate), for: .normal)
        cell.buttonCheckbox.setImage(#imageLiteral(resourceName: "SquareCheck").withRenderingMode(.alwaysTemplate), for: .selected)
        cell.buttonRadioButton.setImage(#imageLiteral(resourceName: "radioUnCheck").withRenderingMode(.alwaysTemplate), for: .normal)
        cell.buttonRadioButton.setImage(#imageLiteral(resourceName: "radioCheck").withRenderingMode(.alwaysTemplate), for: .selected)
        cell.buttonCheckbox.tintColor = .black
        cell.buttonRadioButton.tintColor = .black
       
        
        if self.isSingleSelection{
            cell.buttonCheckbox.isHidden = true
            cell.buttonRadioButton.isHidden = false
            if "\(dicQuestion["selected_option_id"]!)" != ""{
                let predicate = NSPredicate(format: "id == %@", "\(dicQuestion["selected_option_id"]!)")
                let dicSelectedOption = self.arrayOptions.filtered(using: predicate)[0] as! Dictionary<String,Any>
                let index = self.arrayOptions.index(of: dicSelectedOption)
                
                if index == indexPath.row {
                    cell.buttonRadioButton.isSelected = true
                }else{
                    cell.viewBackground.backgroundColor = UIColor.white
                    cell.buttonRadioButton.isSelected = false
                }
            }else{
                cell.viewBackground.backgroundColor = UIColor.white
                cell.buttonRadioButton.isSelected = false
            }
        }else if self.isMultipleChoice{
            cell.buttonRadioButton.isHidden = true
            cell.buttonCheckbox.isHidden = false
            let selectedIndices = NSMutableArray()
            for item in self.arraySelectedIndices{
                let predicate = NSPredicate(format: "id == %@", item as! String)
                let dicSelectedOption = self.arrayOptions.filtered(using: predicate)[0] as! Dictionary<String,Any>
                let index = self.arrayOptions.index(of: dicSelectedOption)
                selectedIndices.add(index)
            }
            if selectedIndices.contains(indexPath.row){
                cell.buttonCheckbox.isSelected = true
            }else{
                cell.viewBackground.backgroundColor = UIColor.white
                cell.buttonCheckbox.isSelected = false
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 83
        self.tableView.rowHeight = UITableViewAutomaticDimension
        return self.tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableFooterView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isAnswerExplanationAvailable == true {
            return self.textViewDescription.contentSize.height + 35
        }else{
            return 0
        }
    }

    //MARK:- WebView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.viewDidLayoutSubviews()
        self.tableView.scrollsToTop = true
        self.tableHeaderView.layoutIfNeeded()
    }
    
}
