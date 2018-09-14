//
//  OFAChallengeAssessmentContainerViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/1/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift

class OFAChallengeAssessmentContainerViewController: UIViewController {

    @IBOutlet var buttonPrevious: UIButton!
    @IBOutlet var buttonNext: UIButton!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var labelQuestionHeading: UILabel!
    
    var arrayQuestions = NSMutableArray()
    var questionTag = 0
    var questionNumber = 1
    
    lazy var challengeAssessmentTVC: OFAChallengeAssessmentQuestionTableViewController? = {
        let challengeAssessmentTVC = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeAssessmentTVC") as! OFAChallengeAssessmentQuestionTableViewController
        return challengeAssessmentTVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.buttonPrevious.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
//        self.buttonPrevious.setTitle(" \(String.fontAwesomeIcon(name: FontAwesome.chevronLeft))", for: .normal)
//
//        self.buttonNext.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
//        self.buttonNext.setTitle(" \(String.fontAwesomeIcon(name: FontAwesome.chevronRight))", for: .normal)
        
        if self.arrayQuestions.count == 1 {
            self.buttonNext.isHidden = true
            self.buttonPrevious.isHidden = true
        }
        self.buttonPrevious.isHidden=true
        self.questionNumber = self.arrayQuestions.count-(self.arrayQuestions.count-1)
        self.getHeading(questionNumber: self.questionNumber)
        
        for i in 0..<self.arrayQuestions.count {
            var dicQuestion = self.arrayQuestions[i] as! Dictionary<String,Any>
            dicQuestion["selected_option_id"] = "\(dicQuestion["q_answer"]!)"
            dicQuestion["selected_options"] = "\(dicQuestion["q_answer"]!)".components(separatedBy: ",")
            dicQuestion["descriptive_answer"] = "\(dicQuestion["q_explanation"]!)"
            
            self.arrayQuestions.replaceObject(at: i, with: dicQuestion)
        }
        
        self.challengeAssessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Helper Functions
    
    func displayAssessmentQuestions(){
        
        if let vc = challengeAssessmentTVC {
            var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
            challengeAssessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
            
            if "\(dicQuestion["q_type"]!)" == "1"{
                challengeAssessmentTVC?.isSingleSelection = true
                challengeAssessmentTVC?.isDescriptiveType = false
                challengeAssessmentTVC?.isMultipleChoice = false
            }else if "\(dicQuestion["q_type"]!)" == "2"{
                challengeAssessmentTVC?.isMultipleChoice = true
                challengeAssessmentTVC?.isDescriptiveType = false
                challengeAssessmentTVC?.isSingleSelection = false
            }else if "\(dicQuestion["q_type"]!)" == "3"{
                challengeAssessmentTVC?.isDescriptiveType = true
                challengeAssessmentTVC?.isSingleSelection = false
                challengeAssessmentTVC?.isMultipleChoice = false
            }
            if "\(dicQuestion["q_explanation"]!)" != ""{
                challengeAssessmentTVC?.isAnswerExplanationAvailable = true
            }

            challengeAssessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
            self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
            
            challengeAssessmentTVC?.dicQuestion = dicQuestion
            if let arrayOption = dicQuestion["options"] as? NSArray{
                challengeAssessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
            }
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.viewContainer.bounds
            self.viewContainer.addSubview(vc.view)
        }
    }
    
    func getHeading(questionNumber:Int){
        self.labelQuestionHeading.text = "Question \(questionNumber) / \(self.arrayQuestions.count)"
    }
    
    //MARK:- Button Actions
    
    @IBAction func previousQuestionAction(_ sender: UIButton) {
        self.questionTag -= 1
        self.questionNumber -= 1
        if self.questionTag == 0 {
            self.buttonPrevious.isHidden = true
        }
        self.buttonNext.isHidden = false
        self.getHeading(questionNumber: self.questionNumber)
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        challengeAssessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
        
        if "\(dicQuestion["q_type"]!)" == "1"{
            challengeAssessmentTVC?.isSingleSelection = true
            challengeAssessmentTVC?.isDescriptiveType = false
            challengeAssessmentTVC?.isMultipleChoice = false
        }else if "\(dicQuestion["q_type"]!)" == "2"{
            challengeAssessmentTVC?.isMultipleChoice = true
            challengeAssessmentTVC?.isDescriptiveType = false
            challengeAssessmentTVC?.isSingleSelection = false
        }else if "\(dicQuestion["q_type"]!)" == "3"{
            challengeAssessmentTVC?.isDescriptiveType = true
            challengeAssessmentTVC?.isSingleSelection = false
            challengeAssessmentTVC?.isMultipleChoice = false
        }
        if "\(dicQuestion["q_explanation"]!)" != ""{
            challengeAssessmentTVC?.textViewDescription.text = OFAUtils.getHTMLAttributedString(htmlString: "\(dicQuestion["q_explanation"]!)")
            challengeAssessmentTVC?.isAnswerExplanationAvailable = true
        }else{
            challengeAssessmentTVC?.textViewDescription.text = ""
            challengeAssessmentTVC?.isAnswerExplanationAvailable = false
        }
        
        challengeAssessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
        
        challengeAssessmentTVC?.dicQuestion = dicQuestion
        if let arrayOption = dicQuestion["options"] as? NSArray{
            challengeAssessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
        }else{
            challengeAssessmentTVC?.arrayOptions.removeAllObjects()
        }
        self.challengeAssessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }
    
    @IBAction func nextQuestionPressed(_ sender: UIButton) {
        if self.questionNumber == self.arrayQuestions.count-1{
            self.buttonNext.isHidden = true
        }
        self.buttonPrevious.isHidden=false
        self.questionNumber += 1
        self.questionTag += 1
        self.getHeading(questionNumber: self.questionNumber)
        var dicQuestion = self.arrayQuestions[self.questionTag] as! Dictionary<String,Any>
        challengeAssessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
        
        if "\(dicQuestion["q_type"]!)" == "1"{
            challengeAssessmentTVC?.isSingleSelection = true
            challengeAssessmentTVC?.isDescriptiveType = false
            challengeAssessmentTVC?.isMultipleChoice = false
            
        }else if "\(dicQuestion["q_type"]!)" == "2"{
            challengeAssessmentTVC?.isMultipleChoice = true
            challengeAssessmentTVC?.isDescriptiveType = false
            challengeAssessmentTVC?.isSingleSelection = false
        }else if "\(dicQuestion["q_type"]!)" == "3"{
            challengeAssessmentTVC?.isDescriptiveType = true
            challengeAssessmentTVC?.isSingleSelection = false
            challengeAssessmentTVC?.isMultipleChoice = false
        }
        if "\(dicQuestion["q_explanation"]!)" != ""{
            challengeAssessmentTVC?.textViewDescription.text = OFAUtils.getHTMLAttributedString(htmlString: "\(dicQuestion["q_explanation"]!)")
            challengeAssessmentTVC?.isAnswerExplanationAvailable = true
        }else{
            challengeAssessmentTVC?.textViewDescription.text = ""
            challengeAssessmentTVC?.isAnswerExplanationAvailable = false
        }
        
        challengeAssessmentTVC?.arraySelectedIndices = (dicQuestion["selected_options"] as! NSArray).mutableCopy() as! NSMutableArray
        self.arrayQuestions.replaceObject(at: self.questionTag, with: dicQuestion)
        challengeAssessmentTVC?.dicQuestion = dicQuestion
        if let arrayOption = dicQuestion["options"] as? NSArray{
            challengeAssessmentTVC?.arrayOptions = arrayOption.mutableCopy() as! NSMutableArray
        }else{
            challengeAssessmentTVC?.arrayOptions.removeAllObjects()
        }
        self.challengeAssessmentTVC?.tableView.reloadData()
        self.displayAssessmentQuestions()
    }
}
