//
//  OFAChallengeScoreCardTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 10/31/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAChallengeScoreCardTableViewController: UITableViewController {

    @IBOutlet var labelMyScore: UILabel!
    @IBOutlet var labelTotalScore: UILabel!
    @IBOutlet var labelMyAttempted: UILabel!
    @IBOutlet var labelAttempted: UILabel!
    @IBOutlet var labelTimeTaken: UILabel!
    @IBOutlet var labelRightAnswer: UILabel!
    @IBOutlet var labelWrongAnswers: UILabel!
    @IBOutlet var labelAccuracyPercentage: UILabel!
    @IBOutlet var labelAverageSpeed: UILabel!
    
    @IBOutlet var imageViewBadge: UIImageView!
    @IBOutlet var imageViewAttempted: UIImageView!
    @IBOutlet var imageViewTimeTaken: UIImageView!
    @IBOutlet var imageViewRightAnswer: UIImageView!
    @IBOutlet var imageViewWrongAnswer: UIImageView!
    @IBOutlet var viewPieChart: OFAPieChartView!
    @IBOutlet var viewSemiCirclePieChart: OFASemiCirclePieChart!
    
    @IBOutlet var buttonDetailedReport: UIButton!
    @IBOutlet var labelFullDate: UILabel!
    
    var dicScoreCardDetails = NSDictionary()
    var navigationTitle = ""
    var fullDateString = ""
    var isChallenge = false
    var isGenerateTest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = OFAUtils.getColorFromHexString("E3E9ED")
        self.imageViewBadge.layer.cornerRadius = self.imageViewBadge.frame.height/2
        self.imageViewAttempted.layer.cornerRadius = self.imageViewAttempted.frame.height/2
        self.imageViewTimeTaken.layer.cornerRadius = self.imageViewTimeTaken.frame.height/2
        self.imageViewRightAnswer.layer.cornerRadius = self.imageViewRightAnswer.frame.height/2
        self.imageViewWrongAnswer.layer.cornerRadius = self.imageViewWrongAnswer.frame.height/2
        
        self.viewSemiCirclePieChart.layer.cornerRadius = self.viewSemiCirclePieChart.frame.height/2
        self.viewPieChart.layer.cornerRadius = self.viewPieChart.frame.height/2
        
        self.populateScoreCard(dicScoreCard: dicScoreCardDetails)
        self.labelFullDate.text = fullDateString
        self.buttonDetailedReport.layer.cornerRadius = self.buttonDetailedReport.frame.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.navigationTitle
    }
    
    func populateScoreCard(dicScoreCard:NSDictionary){
        if let dicResult = dicScoreCard["results"] as? NSDictionary{
            let myScore  = "\(dicResult["marks_scored"]!)"
            
            var durationString = ""
            var averageText = ""
            
            let duration = self.getDuration(seconds: Int("\(dicResult["time_taken"]!)")!)
            if duration[0] > 0 {
                durationString = "\(duration[0]) hr \(duration[1]) m \(duration[2]) s"
                averageText = " Qns / hr"
            }else if duration[1] > 0 {
                durationString = "\(duration[1]) m \(duration[2]) s"
                averageText = " Qns / min"
            }else if duration[2] >= 0 {
                durationString = " \(duration[2]) s"
                averageText = " Qns / sec"
            }
            
            self.labelMyScore.text = myScore
            self.labelTotalScore.text = "/\(dicResult["total_mark"]!)"
            self.labelMyAttempted.text = "\(dicResult["total_attended"]!)"
            self.labelAttempted.text = "/\(dicResult["total_questions"]!)"
            self.labelTimeTaken.text = durationString
            self.labelRightAnswer.text = "\(dicResult["right_answers"]!)"
            self.labelWrongAnswers.text = "\(dicResult["wrong_answers"]!)"
            self.labelAccuracyPercentage.text = "\(dicResult["accuracy"]!) %"
            
            self.viewSemiCirclePieChart.backgroundColor = .clear
            
            let strTimeTaken = "\(dicResult["time_taken"]!)"
            guard let timeTaken = NumberFormatter().number(from: strTimeTaken) else { return }
            
            let strAttended = "\(dicResult["total_attended"]!)"
            guard let totalAttended = NumberFormatter().number(from: strAttended) else { return }
            
            let averageValue =  (totalAttended as! CGFloat)/(timeTaken as! CGFloat)
            let x = averageValue
            let y = Double(round(100*x)/100)
            self.labelAverageSpeed.text = "\(y)"+averageText
            
            let totalValuePartial:CGFloat = 180
            let totalValueFull:CGFloat = 360
            
            self.viewSemiCirclePieChart.partialSegments = [
                PartialSegment(color: OFAUtils.getColorFromHexString("00a6a9"), value: (totalValuePartial * averageValue)/100),
//                PartialSegment(color: OFAUtils.getColorFromHexString("cedadb"), value: totalValuePartial)
            ]
            self.viewPieChart.segments = [
                Segment(color: OFAUtils.getColorFromHexString("00a6a9"), value: (totalValueFull * (dicResult["accuracy"] as! CGFloat))/100),
//                Segment(color: OFAUtils.getColorFromHexString(ofabeeGreenColorCode), value: totalValueFull)
            ]
        }else{
            OFAUtils.showToastWithTitle("Failed to load score card")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getDuration(seconds:Int) -> [Int]{
        let hours = seconds/3600
        let minutes = (seconds%3600)/60
        let second = seconds % 60
        return [hours,minutes,second]
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    @IBAction func detailedReportPressed(_ sender: UIButton) {
        let dicResult = self.dicScoreCardDetails["results"] as! NSDictionary
        let detailedView = self.storyboard?.instantiateViewController(withIdentifier: "DetailedViewVC") as! OFADetailedReportViewController
        if isChallenge{
            detailedView.webURLString = URL_CHALLENGE_ZONE + "\(dicResult["attempt_id"]!)"
        }else if isGenerateTest{
            detailedView.webURLString = URL_USER_GENERATED_TEST + "\(dicResult["attempt_id"]!)"
        }else {
            detailedView.webURLString = URL_ASSESSMENT + "\(dicResult["attempt_id"]!)"
        }
        self.navigationController?.pushViewController(detailedView,animated: true)
    }
}
/*
 let URL_ASSESSMENT = "http://onlineprofesor.com/assesment_report/assesment_report_sample/(attempt_id)";
 let URL_CHALLENGE_ZONE = "http://onlineprofesor.com/assesment_report/challenge_zone_report/(attempt_id)";
 let URL_USER_GENERATED_TEST = "http://onlineprofesor.com/assesment_report/user_generated_test_report/";
 */
