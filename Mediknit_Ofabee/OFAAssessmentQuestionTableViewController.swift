//
//  OFAAssessmentQuestionTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/29/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import WebKit

protocol AssessmentAnswerDelegate{
    func replaceQuestionArray(with arrayNewOptions:NSArray,selectedOption:String)
    func replaceQuestionArray(with selectedOptions:NSArray,answerStatus:String)
    func replaceQuestionArrayWithDescriptiveAnswer(answer:String)
}

class OFAAssessmentQuestionTableViewController: UITableViewController,UITextViewDelegate,UIWebViewDelegate {

    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet var webViewQuestion: UIWebView!
    
    @IBOutlet var textViewDescription: UITextView!
    
    var delegate:AssessmentAnswerDelegate!
    
    var dicQuestion = Dictionary<String,Any>()
    
    var arrayOptions = NSMutableArray()
    var questionString = ""
    var questionId = ""
    var headerHeight:CGFloat = 0
    var isMultipleChoice = false
    var isDescriptiveType = false
    var isSingleSelection = false
    
    var isAlreadySelected = true
    
    var rowHeight:CGFloat = 0
    
    var selectedIndex:Int?
    var currentRow:Int = 0
    var currentSection = 0
    
    var lastSelectedRow = 0
    
    var arrayOptionAlphabets = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var arrayIndices = [0,1,2,3,4,5,6]
    
    var arraySelectedIndices = NSMutableArray()
    
    var currentTimer = Timer()
    var currentTimePeriod = 1
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .portrait
    }
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
        self.webViewQuestion.delegate = self
        self.webViewQuestion.scrollView.isScrollEnabled = false
        self.textViewDescription.inputAccessoryView = OFAUtils.getDoneToolBarButton(tableView: self, target: #selector(self.dismissKeyboard))

        self.textViewDescription.isEditable = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        singleTap.numberOfTapsRequired=1
        self.textViewDescription.addGestureRecognizer(singleTap)
//        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tableView.rowHeight = UITableViewAutomaticDimension
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
    
    @objc func tapped(){
        self.textViewDescription.isScrollEnabled = true
        self.textViewDescription.dataDetectorTypes = []
        self.textViewDescription.isEditable = true
        self.textViewDescription.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismissKeyboard(){
        self.view.endEditing(true)
        self.textViewDescription.isScrollEnabled = false
        self.textViewDescription.dataDetectorTypes = .all
        self.textViewDescription.isEditable = false
    }
    
    func initiateTimerForQuestion(){
        self.currentTimePeriod = 1
        self.currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateCurrentTime(){
        self.currentTimePeriod += 1
        print("CurrentTime = \(self.currentTimePeriod)")
    }
    
    @objc func examCompletedNotificationObserver(){
//        self.tableView.allowsSelection = false
//        self.textViewDescription.isUserInteractionEnabled = false
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerOptionCell", for: indexPath) as! OFAAssessmentAnswerOptionTableViewCell

        NotificationCenter.default.addObserver(self, selector: #selector(self.examCompletedNotificationObserver), name: NSNotification.Name(rawValue: "ExamCompleted"), object: nil)
        var dicOptions = self.arrayOptions[indexPath.row] as! Dictionary<String,Any>
//        cell.textViewOptions.text = "\(self.arrayOptionAlphabets[indexPath.row]). " + OFAUtils.getHTMLAttributedStringForAssessmetOptions(htmlString: "\(dicOptions["qo_options"]!)")
        
//        cell.webViewOptions.delegate = self
        cell.webViewOptions.scrollView.isScrollEnabled = false
//        cell.webViewOptions.frame.size = cell.webViewOptions.sizeThatFits(.zero)
//        self.rowHeight = cell.webViewOptions.scrollView.contentSize.height
        
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

        cell.viewBackground.backgroundColor = UIColor.white
//        cell.textViewOptions.textColor = .black
//        cell.textViewOptions.backgroundColor = .white
        cell.buttonRadioButton.isSelected = false
        cell.buttonCheckbox.isSelected = false
        
        if self.isSingleSelection{
            cell.buttonCheckbox.isHidden = true
            cell.buttonRadioButton.isHidden = false
            if "\(dicQuestion["selected_option_id"]!)" != ""{
                if dicOptions["selectedIndex"] != nil{

                    let predicate = NSPredicate(format: "id == %@", "\(dicQuestion["selected_option_id"]!)")
                    let dicSelectedOption = self.arrayOptions.filtered(using: predicate)[0] as! Dictionary<String,Any>
                    let index = self.arrayOptions.index(of: dicSelectedOption)
                    
                    if index == indexPath.row {
//                        cell.viewBackground.backgroundColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
//                        cell.textViewOptions.textColor = .white
//                        cell.textViewOptions.backgroundColor = .clear
                        cell.buttonRadioButton.isSelected = true
                    }else{
                        cell.viewBackground.backgroundColor = UIColor.white
//                        cell.textViewOptions.textColor = .black
//                        cell.textViewOptions.backgroundColor = .white
                        cell.buttonRadioButton.isSelected = false
                    }
                }
            }else{
                cell.viewBackground.backgroundColor = UIColor.white
//                cell.textViewOptions.textColor = .black
//                cell.textViewOptions.backgroundColor = .white
                cell.buttonRadioButton.isSelected = false
            }
        }else if self.isMultipleChoice{
            cell.buttonRadioButton.isHidden = true
            cell.buttonCheckbox.isHidden = false
            let selectedIndices = NSMutableArray()
//            if let arraySelectedOptions = dicQuestion["selected_options"] as? NSArray{
//                print(arraySelectedOptions)
                for item in self.arraySelectedIndices{
                    let predicate = NSPredicate(format: "id == %@", item as! String)
                    let dicSelectedOption = self.arrayOptions.filtered(using: predicate)[0] as! Dictionary<String,Any>
                    let index = self.arrayOptions.index(of: dicSelectedOption)
                    selectedIndices.add(index)
                }
            if selectedIndices.contains(indexPath.row){
//                cell.viewBackground.backgroundColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
//                cell.textViewOptions.textColor = .white
//                cell.textViewOptions.backgroundColor = .clear
                cell.buttonCheckbox.isSelected = true
            }else{
                cell.viewBackground.backgroundColor = UIColor.white
//                cell.textViewOptions.textColor = .black
//                cell.textViewOptions.backgroundColor = .white
                cell.buttonCheckbox.isSelected = false
            }
//            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! OFAAssessmentAnswerOptionTableViewCell
        var dicOptions = self.arrayOptions[indexPath.row] as! Dictionary<String,Any>
        if self.isSingleSelection == true{
            currentRow = indexPath.row
            currentSection = indexPath.section
            
//            let dicSelectedAnswer = NSDictionary(object: "\(dicOptions["id"]!)", forKey: self.questionId as NSCopying)
            dicOptions["selectedIndex"] = "\(indexPath.row)"
            if dicOptions["time_taken"] != nil{
                dicOptions["timeTaken"] = Int("\(dicOptions["timeTaken"]!)")! + self.currentTimePeriod
            }else{
                dicOptions["timeTaken"] = self.currentTimePeriod
            }
//            dicOptions["answers"] = dicSelectedAnswer
            dicOptions["answer_time_log"] = "\(dicOptions["timeTaken"]!)"//NSDictionary(object: "\(dicOptions["timeTaken"]!)" , forKey: self.questionId as NSCopying)

            self.arrayOptions.replaceObject(at: indexPath.row, with: dicOptions)
            
            dicQuestion["selected_option_id"] = "\(dicOptions["id"]!)"
            self.delegate.replaceQuestionArray(with: self.arrayOptions.copy() as! NSArray, selectedOption: "\(dicQuestion["selected_option_id"]!)")
            
            lastSelectedRow=currentRow
            self.tableView.reloadData()
            
        }else if self.isMultipleChoice == true{
            if cell.buttonCheckbox.isSelected{
                cell.viewBackground.backgroundColor = UIColor.white
//                cell.textViewOptions.textColor = .black
//                cell.textViewOptions.backgroundColor = .white
                cell.buttonCheckbox.isSelected = false
                
                if self.arraySelectedIndices.contains("\(dicOptions["id"]!)"){
//                    let predicate = NSPredicate(format: "id == %@", "\(dicOptions["id"]!)")
//                    let dicSelectedOption = self.arrayOptions.filtered(using: predicate)
                    self.arraySelectedIndices.removeObject(at: self.arraySelectedIndices.index(of: "\(dicOptions["id"]!)"))
                }
                dicQuestion["selected_options"] = arraySelectedIndices.copy() as! NSArray
                var status = ""
                if self.arraySelectedIndices.count>0{
                    status = "0"
                }else{
                    status = "2"
                }
                if dicOptions["time_taken"] != nil{
                    dicOptions["timeTaken"] = Int("\(dicOptions["timeTaken"]!)")! + self.currentTimePeriod
                }else{
                    dicOptions["timeTaken"] = self.currentTimePeriod
                }
                
                dicOptions["answer_time_log"] = "\(dicOptions["timeTaken"]!)"//NSDictionary(object: "\(dicOptions["timeTaken"]!)" , forKey: self.questionId as NSCopying)
                
                self.arrayOptions.replaceObject(at: indexPath.row, with: dicOptions)
                
                self.delegate.replaceQuestionArray(with: arraySelectedIndices.copy() as! NSArray, answerStatus: status)
            }else{
                arraySelectedIndices.add("\(dicOptions["id"]!)")
//                cell.viewBackground.backgroundColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
//                cell.textViewOptions.textColor = .white
//                cell.textViewOptions.backgroundColor = .clear
                cell.buttonCheckbox.isSelected = true
                dicQuestion["selected_options"] = arraySelectedIndices.copy() as! NSArray
                self.delegate.replaceQuestionArray(with: arraySelectedIndices.copy() as! NSArray, answerStatus: "0")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 83
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableFooterView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isDescriptiveType == true {
            return self.textViewDescription.contentSize.height + 60
        }else{
            return 0
        }
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return self.tableHeaderView
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.headerHeight
//    }
    
    @IBAction func checkBoxPressed(_ sender: UIButton) {
    }
    
    //MARK:- WebView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.viewDidLayoutSubviews()
        self.tableView.scrollsToTop = true
        self.tableHeaderView.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    //MARK:- Text View Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textViewDescription.text == "Give your Answer" {
            self.textViewDescription.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.textViewDescription.text == "" {
            self.textViewDescription.text = "Give your Answer"
        }else{
            self.delegate.replaceQuestionArrayWithDescriptiveAnswer(answer: self.textViewDescription.text!)
        }
        self.tableView.reloadData()
    }
}
