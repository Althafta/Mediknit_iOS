//
//  OFAAssessmentQuestionListTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 10/6/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

protocol didSelectRandomQuestionFromList{
    func sendQuestionTagSelected(selectedTag:Int)
}

class OFAAssessmentQuestionListTableViewController: UITableViewController {

    var arrayQuestions = NSMutableArray()
    var delegate:didSelectRandomQuestionFromList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.barTintColor = OFAUtils.getColorFromHexString(barTintColor)
        
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissViewController))
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissViewController), name: NSNotification.Name(rawValue: "ExamCompleted"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Questions"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OFAUtils.lockOrientation(.portrait)
    }
     
    @objc func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayQuestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionListCell", for: indexPath) as! OFAAssessmentQuestionListTableViewCell
        let dicQuestion = self.arrayQuestions[indexPath.row] as! NSDictionary
//        assessmentTVC?.webViewQuestion.loadHTMLString("\(dicQuestion["q_question"]!)", baseURL: nil)
      
        cell.customizeCellWithDetail(questionCount: "\(indexPath.row + 1)", questionString: OFAUtils.getHTMLAttributedString(htmlString: "\(dicQuestion["q_question"]!)"), questionStatus: "\(dicQuestion["q_status"]!)")

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.sendQuestionTagSelected(selectedTag: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 91
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }

}
