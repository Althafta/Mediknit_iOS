//
//  OFAInteractiveQuestionsTableViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 09/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAInteractiveQuestionsTableViewController: UITableViewController {

    @IBOutlet weak var textViewQuestionHeader: UITextView!
    @IBOutlet weak var textViewAnswerDescription: UITextView!
    
    var questionString = ""
    var explanationString = ""
    
    var arrayOptions = NSMutableArray()
    var dicOptions = NSDictionary()
    var arrayQuestions = NSArray()
    
    var optionIndex = ["a","b","c","d","e","f","g","h","i","j"]
    var pageIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.arrayQuestions = UserDefaults.standard.value(forKey: "QuestionArray") as! NSArray
        self.pageIndex = UserDefaults.standard.value(forKey: "PageIndex") as! Int
        
        let continueBarButton = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(self.continuePressed))
        self.navigationItem.rightBarButtonItem = continueBarButton
        
        self.textViewQuestionHeader.text = OFAUtils.getHTMLAttributedString(htmlString: self.questionString)
        self.textViewAnswerDescription.text = OFAUtils.getHTMLAttributedString(htmlString: self.explanationString)
        self.textViewAnswerDescription.isHidden = true
        
        self.dicOptions = (self.arrayQuestions[self.pageIndex] as! NSDictionary)["options"] as! NSDictionary
        self.tableView.reloadData()
    }

    @objc func continuePressed(){
        if self.pageIndex+1 >= self.arrayQuestions.count{
            //dismiss and continue lecture
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
        
        cell.textViewOption.text = "\(self.dicOptions[self.optionIndex[indexPath.row]]!)"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.textViewAnswerDescription.isHidden = false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }

}
