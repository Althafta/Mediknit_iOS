
//
//  OFACourseDetailsCurriculumTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift

protocol CourseDetailsCurriculumDelegate{
//    func updateRowHeightForCurriculum(with array:NSMutableArray,rowCount:Int,sectionCount:Int)
    func totalHeightForTableView(height:CGFloat)
//    func getNumberOfRows(rows:Int)
}

class OFACourseDetailsCurriculumTableViewCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var buttonFullCurriculum: UIButton!
    @IBOutlet var tableViewCurriculumList: UITableView!
    var delegate:CourseDetailsCurriculumDelegate!
    
    var arraySections = NSMutableArray()
    var arrayLectures = NSMutableArray()
    var totalRowCount = 0
    var totalSectionCount = 0
    var isShowMoreSelected = false
    
    var rowCount = 0
    var maximumHeight = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tableViewCurriculumList.isScrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK:- TableView Delegate 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.totalSectionCount = self.arraySections.count
        if isShowMoreSelected{
            return self.arraySections.count
        }
        if self.arraySections.count < 3{
            return self.arraySections.count
        }else{
            return 3
        }
    }
    
    func getCurriculumList(for section:Int) -> NSMutableArray{
        var arrayCurriculum = NSMutableArray()
        let dicSection = self.arraySections[section] as! NSDictionary
        arrayCurriculum = (dicSection["lectures"] as! NSArray).mutableCopy() as! NSMutableArray
        return arrayCurriculum
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let arrLectures = self.getCurriculumList(for: section)
        
        self.totalRowCount += arrLectures.count
        
        if isShowMoreSelected == true {
            let totalHeight = (self.totalRowCount * 85) + (self.totalSectionCount * 60)
            self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
            return arrLectures.count
        }else{
            if section < 2{
                self.delegate.totalHeightForTableView(height: CGFloat(self.totalRowCount * 85  + 3 * 60)+44)
            }
            if arrLectures.count >= 3{
                return 3
            }else{
                return arrLectures.count
            }
        }
//        self.arrayLectures = arrLectures
        
//        self.totalRowCount += arrLectures.count
//
//        if isShowMoreSelected == true {
//            let totalHeight = (self.totalRowCount * 85) + (self.totalSectionCount * 60)
//            self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
//            return arrLectures.count
//        }else{
//            if arrLectures.count > 3 {
//                if self.arraySections.count==1{
//                    let totalHeight = (3 * 85) + (self.totalSectionCount * 60)+44
//                    if self.maximumHeight < totalHeight {
//                        self.maximumHeight = totalHeight
//                    }
//
//                    self.delegate.totalHeightForTableView(height: CGFloat(self.maximumHeight))
//                    return 3
//                }
//                let totalHeight = (arrLectures.count * 85) + (self.totalSectionCount * 60)+44+44+44
//                if self.maximumHeight < totalHeight {
//                    self.maximumHeight = totalHeight
//                }
//                self.delegate.totalHeightForTableView(height: CGFloat(self.maximumHeight))//315
//                return 3
//            }else{
//                let totalHeight = (arrLectures.count * 85) + (self.totalSectionCount * 60)
//                if self.maximumHeight < totalHeight {
//                    self.maximumHeight = totalHeight
//                }
//                self.delegate.totalHeightForTableView(height: CGFloat(self.maximumHeight))
//                return arrLectures.count
//            }
//        }
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let dicSection = self.arraySections[section] as! NSDictionary
//        let arrLectures = dicSection["lectures"] as! NSArray
//        self.arrayLectures = arrLectures.mutableCopy() as! NSMutableArray
//
//        self.totalRowCount += arrLectures.count
//
//        if isShowMoreSelected == true {
//            let totalHeight = (self.totalRowCount * 85) + (self.totalSectionCount * 60)
//            self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
//            return arrLectures.count
//        }else{
//            if arrayLectures.count >= 3{
////                let totalHeight = (3*85)
//                let totalHeight = (3 * 85) + (self.totalSectionCount * 60)+44
//                print(totalHeight)
//                self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
//                rowCount = 3
//            }else if arrayLectures.count == 2{
//                let totalHeight = (2 * 85) + (self.totalSectionCount * 60)+44
//                print(totalHeight)
//                self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
//                rowCount = 2
//            }else if arrayLectures.count == 1{
//                let totalHeight = (1 * 85) + (self.totalSectionCount * 60)+44
//                print(totalHeight)
//                self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
//                rowCount = 1
//            }
//            return rowCount
////            if arrLectures.count > 3 {
////                if self.arraySections.count==1{
////                    let totalHeight = (3 * 85) + (self.totalSectionCount * 60)+44
////                    self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
////                    return 3
////                }else{
////                    let totalHeight = (3 * 85) + (self.totalSectionCount * 60)+44
////                    self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))//315
////                    return 3
////                }
////            }else{
////                let totalHeight = (arrLectures.count * 85) + (self.totalSectionCount * 60)
////                self.delegate.totalHeightForTableView(height: CGFloat(totalHeight))
////                return arrLectures.count
////            }
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewCurriculumList.dequeueReusableCell(withIdentifier: "CurriculumDetailsList", for: indexPath) as! OFACourseCurriculumTableViewCell
//        let dicSection = self.getCurriculumList(for:indexPath.section)[indexPath.section] as! NSDictionary
//        let arrLectures = dicSection["lectures"] as! NSArray
        let dicLecture = self.getCurriculumList(for:indexPath.section)[indexPath.row] as! NSDictionary
        
        let details = self.getCurriculumDetail(indexPath: indexPath)
        
        cell.customizeCellWithDetails(curriculumTitle: "\(dicLecture["cl_lecture_name"]!)", curriculumType: details, count: "\(indexPath.row + 1)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 60)
        label.textAlignment = .left
        label.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        let dicSection = self.arraySections[section] as! NSDictionary
        label.text = "     Section \(section+1): \(dicSection["s_name"]!)"
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func getCurriculumDetail(indexPath:IndexPath)->String{
        var detailString = ""
        var curriculumType = ""
        let dicSection = self.arraySections[indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        let dicLecture = arrLectures[indexPath.row] as! NSDictionary

        curriculumType = "\(dicLecture["cl_lecture_type"]!)"

        if curriculumType == "1"{//video
            let duration = "\(dicLecture["duration_hm"]!)"
            let arrString = duration.components(separatedBy: ":")
            
            let stringVar = String()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_play_circle_o)
            
            detailString = "\(faType)   Video - \(arrString[0]) hr \(arrString[1]) min"
        }else if curriculumType == "2"{//Doc
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_file_word_o)
            
            detailString = "\(faType)   Document"
        }else if curriculumType == "3"{//Assessment
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_file)
            
            detailString = "\(faType)   Assessment - \(dicLecture["num_of_question"]!) questions"
        }else if curriculumType == "4"{//youtube
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_youtube)
            
            detailString = "\(faType)   Youtube"
        }else if curriculumType == "5"{//text
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_file_text)
            
            detailString = "\(faType)   Text - \(dicLecture["num_of_question"]!) questions"
        }else if curriculumType == "6"{//wikipedia
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_wikipedia_w)
            
            detailString = "\(faType)   Wiki"
        }else if curriculumType == "7"{//live
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_file_movie_o)
            
            let duration = "\(dicLecture["duration_live"]!)"
            let arrString = duration.components(separatedBy: ":")
            detailString = "\(faType)   Live - \(arrString[0]) hr \(arrString[1]) min"
        }else if curriculumType == "8"{//Descriptive
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_file)
            
            detailString = "\(faType)   Descriptive - \(dicLecture["num_of_question"]!) questions"
        }else if curriculumType == "9"{//recording
            
            let stringVar = String()
//            let fontVar = UIFont()
//            fontVar.fa.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_file_audio_o)
            
            detailString = "\(faType)   Recording"
        }
        return detailString
    }
    @IBAction func showFullCurriculumPressed(_ sender: UIButton) {
        self.totalRowCount = 0
        self.buttonFullCurriculum.isHidden = true
        self.isShowMoreSelected = true
        self.tableViewCurriculumList.reloadData()
    }
}
