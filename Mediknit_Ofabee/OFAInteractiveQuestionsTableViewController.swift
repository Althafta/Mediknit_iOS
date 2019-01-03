//
//  OFAInteractiveQuestionsTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 09/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAInteractiveQuestionsTableViewController: UITableViewController {

    @IBOutlet weak var textViewQuestionHeader: UITextView!
    @IBOutlet weak var textViewAnswerDescription: UITextView!
    @IBOutlet weak var labelSolution: UILabel!
    
    var questionString = ""
    var explanationString = ""
    
    var arrayOptions = NSMutableArray()
    var dicOptions = NSDictionary()
    var arrayQuestions = NSArray()
    
    var optionIndex = ["a","b","c","d","e","f","g","h","i","j"]
    var pageIndex = Int()
    
    var continueBarButton = UIBarButtonItem()
    var questionID = ""
    var selectedChoice = ""
    var lectureID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.arrayQuestions = UserDefaults.standard.value(forKey: "QuestionArray") as! NSArray
        self.pageIndex = UserDefaults.standard.value(forKey: "PageIndex") as! Int
        
        self.continueBarButton = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(self.continuePressed))
        self.continueBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.continueBarButton
        
        self.textViewQuestionHeader.text = OFAUtils.getHTMLAttributedString(htmlString: self.questionString)
        self.textViewAnswerDescription.text = OFAUtils.getHTMLAttributedString(htmlString: self.explanationString)
        self.textViewAnswerDescription.isHidden = true
        self.labelSolution.isHidden = true
        self.textViewAnswerDescription.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewAnswerDescription.layer.borderWidth = 1.0
        self.textViewAnswerDescription.layer.cornerRadius = 10.0
        
        self.dicOptions = (self.arrayQuestions[self.pageIndex] as! NSDictionary)["options"] as! NSDictionary
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        OFAUtils.lockOrientation(.portrait)
        OFAUtils.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    @objc func continuePressed(){
        if self.pageIndex+1 >= self.arrayQuestions.count{
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "InteractiveQuestionCompleted")))
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.pageIndex += 1
        UserDefaults.standard.setValue(self.pageIndex, forKey: "PageIndex")
        let interactiveQuestions = self.storyboard?.instantiateViewController(withIdentifier: "InteractiveQuestionsTVC") as! OFAInteractiveQuestionsTableViewController
        interactiveQuestions.questionString = "\((arrayQuestions[self.pageIndex] as! NSDictionary)["question"]!)"
        interactiveQuestions.explanationString = "\((arrayQuestions[self.pageIndex] as! NSDictionary)["explanation"]!)"
        self.navigationController?.pushViewController(interactiveQuestions, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5//self.arrayOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InteractiveOptionCell", for: indexPath) as! OFAVideoInteractiveQuestionTableViewCell
        
        cell.optionIndex = "\(self.dicOptions["correct"]!)"
        if "\(self.dicOptions[self.optionIndex[indexPath.row]]!)" != ""{
            cell.textViewOption.text = "\(self.optionIndex[indexPath.row]).   \(self.dicOptions[self.optionIndex[indexPath.row]]!)"
        }else{
            cell.textViewOption.text = ""
        }
        if cell.cellSelected == true{
            cell.imageViewStatus.isHidden = false
        }else{
            cell.imageViewStatus.isHidden = true
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! OFAVideoInteractiveQuestionTableViewCell
        if cell.textViewOption.text == ""{
            OFAUtils.showToastWithTitle("Select an option")
            return
        }
        cell.cellSelected = true
        cell.imageViewStatus.isHidden = false
        let correctAnser = "\(self.dicOptions["correct"]!)"
        let selectedIndex = self.optionIndex[indexPath.row]
        self.selectedChoice = selectedIndex
        self.questionID = "\((self.arrayQuestions[self.pageIndex] as! NSDictionary)["id"]!)"
        self.lectureID = "\((self.arrayQuestions[self.pageIndex] as! NSDictionary)["lecture_id"]!)"
        if correctAnser == selectedIndex{
            cell.imageViewStatus.tintColor = UIColor.green
            cell.imageViewStatus.image = UIImage(named: "Right_Answer")//right
        }else{
            cell.imageViewStatus.tintColor = UIColor.red
            cell.imageViewStatus.image = UIImage(named: "Wrong_Answer")//wrong
        }
        self.textViewAnswerDescription.isHidden = false
        self.labelSolution.isHidden = false
        self.continueBarButton.isEnabled = true
        self.tableView.allowsSelection = false
        self.saveInteractiveQuestion()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }

    //MARK:- Save interactive questions
    
    func saveInteractiveQuestion(){
        let userID = UserDefaults.standard.value(forKey: USER_ID) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [userID,domainKey,accessToken,self.questionID,self.selectedChoice,self.lectureID], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying,"question_id" as NSCopying,"selected_choice" as NSCopying,"lecture_id" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/save_lecture_percentage", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if responseJSON.result.value != nil{
//                print(dicResult)
            }else{
                print(responseJSON.error?.localizedDescription ?? "")
            }
        }
    }
}
