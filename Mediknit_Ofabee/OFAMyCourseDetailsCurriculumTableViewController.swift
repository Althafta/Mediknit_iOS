//
//  OFAMyCourseDetailsCurriculumTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import FontAwesomeKit_Swift
import STRatingControl
import Photos

class OFAMyCourseDetailsCurriculumTableViewController: UITableViewController,MyCourseCurriculumContainerDelegate,STRatingControlDelegate {

    var course_id = ""
    var arraySections = NSMutableArray()
    var dicCourseDetails = NSDictionary()
    var imageBaseURL = ""
    
    var dicLastPlayed = NSDictionary()
    var refreshController = UIRefreshControl()
    
    @IBOutlet var viewRatingPopup: UIView!
    @IBOutlet weak var ratingView: STRatingControl!
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    var myCourseContainerViewController = OFAMyCourseCurriculumListContainerViewController()
//    lazy var myCourseContainerViewController : OFAMyCourseCurriculumListContainerViewController? = {
//        let myCourseContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "") as! OFAMyCourseCurriculumListContainerViewController
//        return myCourseContainerViewController
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
        
        self.refreshController.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        self.refreshController.addTarget(self, action: #selector(self.refreshInitiated), for: .valueChanged)
       self.tableView.refreshControl = self.refreshController
        
        self.ratingView.delegate = self
//        self.ratingView.rating = self.rating
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCurriculum()
        let parentVC = self.parent as! OFAMyCourseCurriculumListContainerViewController
        parentVC.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.animateOut()
        self.removeBlur()
    }
    
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(animated)
        viewRatingPopup.setNeedsFocusUpdate()
        self.loadCurriculum()
    }
    
    @objc func refreshInitiated(){
        self.loadCurriculum()
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "CurriculumRefresh"), object: nil)
    }
    
    func loadCurriculum(){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Curriculum")
        Alamofire.request(userBaseURL+"api/course/course_curriculum", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let dicCourse = dicBody["course"] as! NSDictionary
                let arrTopics = dicCourse["topics"] as! NSArray
                self.arraySections.removeAllObjects()
                for item in arrTopics {
                    let dicTopic = item as! NSDictionary
                    self.arraySections.add(dicTopic)
                }
                if dicBody["user_image_url"] != nil{
                    self.imageBaseURL = "\(dicBody["user_image_url"]!)"
                }
                self.refreshController.endRefreshing()
                self.tableView.reloadData()
            }else{
                self.refreshController.endRefreshing()
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.arraySections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dicSection = self.arraySections[section] as! NSDictionary
        let arrCurriculumLectures = dicSection["lectures"] as! NSArray
        return arrCurriculumLectures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCourseDetailsCurriculum", for: indexPath) as! OFAMyCourseDetailsCurriculumTableViewCell

        let dicSection = self.arraySections[indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        if let dicLecture = arrLectures[indexPath.row] as? NSDictionary{
            let details = self.curriculumDetail(indexPath: indexPath)
            var percentage:CGFloat = 0
            
            if dicLecture["ll_percentage"] == nil{
                percentage = 0
            }else{
                guard let n = NumberFormatter().number(from: "\(dicLecture["ll_percentage"]!)")
                    else{
                        return UITableViewCell()
                }
                percentage = CGFloat(n)
            }
            var curriculumType = ""
            var image = UIImage()
            
            curriculumType = "\(dicLecture["cl_lecture_type"]!)"
            
            if curriculumType == "1"{//video
                image = #imageLiteral(resourceName: "Video")
            }else if curriculumType == "2"{//Doc
                image = #imageLiteral(resourceName: "Document")
            }else if curriculumType == "7"{//Assessment
                image = #imageLiteral(resourceName: "Assessment")
            }else if curriculumType == "4"{//youtube
                image = #imageLiteral(resourceName: "Video")
            }else if curriculumType == "5"{//text
                image = #imageLiteral(resourceName: "Document")
            }else if curriculumType == "6"{//wikipedia
            }else if curriculumType == "3"{//live
                image = #imageLiteral(resourceName: "Video")
            }else if curriculumType == "8"{//Descriptive
                image = #imageLiteral(resourceName: "Assessment")
            }else if curriculumType == "9"{//recording
                image = #imageLiteral(resourceName: "Video")
            }
            cell.imageViewIcon.image = image
//            cell.labelDetails.font = UIFont.fontAwesome(ofSize: 14)
            let stringVar = String()
            let fontVar = UIFont.fa?.fontSize(15)
            let faType = stringVar.fa.fontAwesome(.fa_ellipsis_v)
            cell.labelDetails.font = fontVar
            
//            cell.customizeCellWithDetails(curriculumTitle: "\(dicLecture["cl_lecture_name"]!)", details: details, percentage: percentage, serialNumber: "\(indexPath.row + 1)", downloadStatus: "\(dicLecture["cl_downloadable"]!)", completeStatus: "",viewText: "\(dicLecture["ll_attempt"]!)/\(dicLecture["cl_limited_access"]!) Views", viewStatus:"\(dicLecture["cl_limited_access"]!)" == "0" ? true : false)
            
            cell.customizeCellWithDetails(curriculumTitle: "\(dicLecture["cl_lecture_name"]!)", details: details, percentage: percentage, serialNumber: "\(indexPath.row + 1)")
            cell.buttonAction.indexPath = indexPath
            cell.buttonDownload.indexPath = indexPath
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dicSection = self.arraySections[indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        if let dicLecture = arrLectures[indexPath.row] as? NSDictionary{
            var curriculumType = ""
            curriculumType = "\(dicLecture["cl_lecture_type"]!)"
            if curriculumType == "1"{
                self.getVideoDetails(lectureId: "\(dicLecture["id"]!)", percentage: "\(dicLecture["ll_percentage"]!)")
            }
//            else if curriculumType == "2"{
//                self.getPDFViewControllerWithLectureId(lectureId: "\(dicLecture["id"]!)", percentage: "\(dicLecture["ll_percentage"]!)")
//            }
            else if curriculumType == "7"{
//                let dicAssessment = dicLecture["assesment"] as! NSDictionary
//                self.getAssessment(lectureId: "\(dicLecture["id"]!)", lectureTitle: "\(dicLecture["cl_lecture_name"]!)",duration:"\(dicAssessment["a_duration"]!)",assessmentID: "\(dicLecture["assessment_id"]!)")
                let assessmentAlert = UIAlertController(title: nil, message: "Assessments can be attended in PC/Laptop", preferredStyle: .alert)
                assessmentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    assessmentAlert.dismiss(animated: true, completion: nil)
                }))
                self.present(assessmentAlert, animated: true, completion: nil)
            }
//            else if curriculumType == "4"{
//                self.getYoutubeDetails(lectureId: "\(dicLecture["id"]!)")
//            }else if curriculumType == "5"{
//                self.getTextDetails(lectureId: "\(dicLecture["id"]!)", percentage: "\(dicLecture["ll_percentage"]!)")
//            }else if curriculumType == "3"{//live
//                self.getVideoDetails(lectureId: "\(dicLecture["id"]!)", percentage: "")
//            }else if curriculumType == "8"{
//                let dicDescriptive = dicLecture["descriptive"] as! NSDictionary
//                let arrayComments = dicDescriptive["comments"] as! NSArray
////                self.getDescriptiveDetails(lectureId: "\(dicLecture["id"]!)", commentsArray: arrayComments)
//                if let dicDescriptive = dicLecture["descriptive"] as? NSDictionary {
//                    if dicDescriptive["dt_total_mark"] != nil{
//                        self.getDescriptiveDetails(lectureId: "\(dicLecture["id"]!)", commentsArray: arrayComments, marks: "\(dicDescriptive["marks"]!)", totalMarks: "\(dicDescriptive["dt_total_mark"]!)")
//                    }else{
//                        if "\(dicDescriptive["marks"]!)" == "-1"{
//                            self.getDescriptiveDetails(lectureId: "\(dicLecture["id"]!)", commentsArray: arrayComments, marks: "\(dicDescriptive["marks"]!)", totalMarks: "")
//                        }
//                    }
////                    self.getDescriptiveDetails(lectureId: "\(dicLecture["id"]!)", commentsArray: arrayComments, marks: "\(dicDescriptive["marks"]!)", totalMarks: "\(dicDescriptive["dt_total_mark"]!)")
//                }else{
//                    OFAUtils.showToastWithTitle("Invalid Test")
//                }
//            }
            else{
                OFAUtils.showToastWithTitle("under development")
            }
        }else{
            OFAUtils.showToastWithTitle("Some error occured, Try again later")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dicSection = self.arraySections[section] as! NSDictionary
        let sectionTitle = OFAUtils.getHTMLAttributedString(htmlString:"\(dicSection["s_name"]!)")
//        return "      Section \(section+1): \(sectionTitle)"
        return "      \(sectionTitle)"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dicSection = self.arraySections[indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        if let dicLecture = arrLectures[indexPath.row] as? NSDictionary{
            var percentage:CGFloat = 0
            
            if dicLecture["ll_percentage"] == nil {
                percentage = 0
            }else{
                guard let n = NumberFormatter().number(from: "\(dicLecture["ll_percentage"]!)")
                    else { return 128 }
                percentage = CGFloat(n)
                if percentage >= 100 {
//                    if "\(dicLecture["cl_limited_access"]!)" == "0"{
//                        return 128
//                    }else{
                        return 107
//                    }
                }else{
//                    if "\(dicLecture["cl_downloadable"]!)" == "0"{
//                        return 128
//                    }
                    return 128
                }
//                return 128
            }
        }
        return 170
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.arraySections.count-1{
            return 30
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = OFAUtils.getColorFromHexString(sectionBackgroundColor)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let dicSection = self.arraySections[indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        let rowActionQandA = UITableViewRowAction(style: .normal, title: "Q & A") { (rowAction, indexPath) in
            if let dicLecture = arrLectures[indexPath.row] as? NSDictionary{
                let QandATabCVC = self.storyboard?.instantiateViewController(withIdentifier: "QandAContainerVC") as! OFALectureQAndAContainerViewController
                LECTURE_ID = "\(dicLecture["id"]!)"
                self.navigationController?.pushViewController(QandATabCVC, animated: true)
            }
        }
        let rowActionRatingLecture = UITableViewRowAction(style: .normal, title: "Rating") { (rowAction, indexPath) in
            if let dicLecture = arrLectures[indexPath.row] as? NSDictionary{
                LECTURE_ID = "\(dicLecture["id"]!)"
                 self.ratingView.rating = ("\(dicLecture["rating"]!)" == "<null>" || "\(dicLecture["rating"]!)" == "") ? 0 : Int("\(dicLecture["rating"]!)")!
                self.showRatingPopUp()
                self.animateIn()
                self.blur()
            }
        }
        rowActionQandA.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
        rowActionRatingLecture.backgroundColor = OFAUtils.getColorFromHexString(ofabeeGreenColorCode)
        
        if let dicLecture = arrLectures[indexPath.row] as? NSDictionary{
            if "\(dicLecture["cl_lecture_type"]!)" == "7" || "\(dicLecture["ll_percentage"]!)" != "100"{
                return []
            }
        }
        
        return [rowActionQandA,rowActionRatingLecture]
    }
    
    //MARK:- STRatingControl Delegate
    
    func didSelectRating(_ control: STRatingControl, rating: Int) {
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [LECTURE_ID,COURSE_ID,"\(rating)",user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"course_id" as NSCopying,"rating" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        print(dicParameters)
        Alamofire.request(userBaseURL+"api/course/save_rating_review", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                print(dicResult)
                OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                self.removeBlur()
                self.animateOut()
                self.refreshInitiated()
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Button Actions

    @IBAction func actionButtonPressed(_ sender: OFACustomButton) {
        let dicSection = self.arraySections[sender.indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        if let dicLecture = arrLectures[sender.indexPath.row] as? NSDictionary{
            self.getLectureDownloadURL(lecture_id: "\(dicLecture["id"]!)", curriculumType: "\(dicLecture["cl_lecture_type"]!)")
        }
    }
    
    @IBAction func completeAction(_ sender: UIButton) {
        print("Complete pressed")
    }
    
    @IBAction func downloadActionPressed(_ sender: OFACustomButton) {
        print("Download pressed")
//        let videoImageUrl = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
//        self.downloadVideoLinkAndCreateAsset(videoImageUrl)
        let dicSection = self.arraySections[sender.indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        if let dicLecture = arrLectures[sender.indexPath.row] as? NSDictionary{
            OFAUtils.showLoadingViewWithTitle("Downloading")
//            OFAUtils.showToastWithTitle("Downloading")
            self.getLectureDownloadURL(lecture_id: "\(dicLecture["id"]!)", curriculumType: "\(dicLecture["cl_lecture_type"]!)")
        }
    }
    
    //MARK:- get Download URL Helper
    
    func getLectureDownloadURL(lecture_id:String,curriculumType:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicParameters = NSDictionary(objects: [lecture_id,user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/download_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
//                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if let dicBody = dicResult["body"] as? NSDictionary{
                    if let urlString = dicBody["url"]{
                        self.getLectureFile(urlString: urlString as! String, lecture_id: lecture_id, curriculumType: curriculumType, fileName: "\(dicBody["file_name"]!)")
//                                            if curriculumType == "1"{
//                                                self.downloadVideoLinkAndCreateAsset(videoLink: urlString as! String)
//                                            }else if curriculumType == "2"{
//                                                self.documentDownloadPressed(pdfURL: urlString as! String)
//                                            }else{
//                                                OFAUtils.showToastWithTitle("Download not available for this lecture")
//                                            }
                    }
                }
                
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func getLectureFile(urlString:String,lecture_id:String ,curriculumType:String, fileName:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        
        let dicParameters = NSDictionary(objects: [lecture_id,user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(urlString, method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseData { (responseJSON) in
            if let dicResultData = responseJSON.result.value{
                OFAUtils.removeLoadingView("Download completed")
                if curriculumType == "1"{
                    
                    
                    let myVideoVarData = dicResultData
                    
                    //Now writeing the data to the temp diroctory.
                    let tempPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    let tempDocumentsDirectory: AnyObject = tempPath[0] as AnyObject
                    
                    let tempDataPath = tempDocumentsDirectory.appendingPathComponent(fileName) as String
                    try? myVideoVarData.write(to: URL(fileURLWithPath: tempDataPath), options: [])
                    
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({

                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: tempDataPath)!)}) { completed, error in
                                    if completed {
                                        print("Video asset created")
                                        OFAUtils.showToastWithTitle("Lecture saved successfully")
                                    } else {
                                        print(error!)
                                        OFAUtils.showToastWithTitle("Failed to save lecture")
                                    }
                            }
                        }
                    })
                }else if curriculumType == "2"{
//                    self.documentDownloadPressed(pdfURL: urlString as! String)
                    let data = dicResultData//the stuff from your web request or other method of getting pdf
                    let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                    //            activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
                    self.present(activityViewController, animated: true, completion: nil)
                }else{
                    OFAUtils.showToastWithTitle("Download not available for this lecture")
                }

            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    //MARK:- Download Helpers
    
    func savePdf(pdfURLString:String){
        let pdfURL = URL(string:pdfURLString)
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\((pdfURL?.lastPathComponent)!)"
        let pdfDoc = try! Data(contentsOf:URL(string: pdfURLString)!)
//        fileManager.createFile(atPath: paths, contents: pdfDoc as Data?, attributes: nil)

        if fileManager.fileExists(atPath: paths){
            print("document already present")
        }
        else {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pdfDoc as Data], applicationActivities: nil)
//            activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func documentDownloadPressed(pdfURL:String){
        self.savePdf(pdfURLString: pdfURL)
    }
    
    func downloadVideoLinkAndCreateAsset(videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                
                // use guard to unwrap your optional url
                guard let location = location else { return }
                
                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent)
                
                do {
                    
                    try FileManager.default.copyItem(at: location, to: destinationURL)
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        
                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                    if completed {
                                        print("Video asset created")
                                    } else {
                                        print(error!)
                                    }
                            }
                        }
                    })
                    
                } catch { print(error) }
                
                }.resume()
    }
    
    //MARK:- Container View Delegate
    
    func lastPlayedLecture(dicLecture: NSDictionary) {
        print(dicLecture)
        if dicLecture.count > 0{
            var curriculumType = ""
            curriculumType = "\(dicLecture["cl_lecture_type"]!)"
            if curriculumType == "1"{
                self.getVideoDetails(lectureId: "\(dicLecture["id"]!)", percentage: "\(dicLecture["ll_percentage"]!)")
            }else if curriculumType == "2"{
                self.getPDFViewControllerWithLectureId(lectureId: "\(dicLecture["id"]!)", percentage: "\(dicLecture["ll_percentage"]!)")
            }else if curriculumType == "7"{
//                let dicAssessment = dicLecture["assesment"] as! NSDictionary
//                self.getAssessment(lectureId: "\(dicLecture["id"]!)", lectureTitle: "\(dicLecture["cl_lecture_name"]!)",duration:"\(dicAssessment["a_duration"]!)",assessmentID: "\(dicLecture["assessment_id"]!)")
                let assessmentAlert = UIAlertController(title: nil, message: "Assessments can be attended in PC/Laptop", preferredStyle: .alert)
                assessmentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    assessmentAlert.dismiss(animated: true, completion: nil)
                }))
                self.present(assessmentAlert, animated: true, completion: nil)
            }else if curriculumType == "4"{
                self.getYoutubeDetails(lectureId: "\(dicLecture["id"]!)")
            }else if curriculumType == "5"{
                self.getTextDetails(lectureId: "\(dicLecture["id"]!)", percentage: "\(dicLecture["ll_percentage"]!)")
            }else if curriculumType == "3"{//live
                self.getVideoDetails(lectureId: "\(dicLecture["id"]!)", percentage: "")
            }else if curriculumType == "8"{
                let dicDescriptive = dicLecture["descriptive"] as! NSDictionary
                let arrayComments = dicDescriptive["comments"] as! NSArray
                //                self.getDescriptiveDetails(lectureId: "\(dicLecture["id"]!)", commentsArray: arrayComments)
                if let dicDescriptive = dicLecture["descriptive"] as? NSDictionary {
                    self.getDescriptiveDetails(lectureId: "\(dicLecture["id"]!)", commentsArray: arrayComments, marks: "\(dicDescriptive["marks"]!)", totalMarks: "\(dicDescriptive["dt_total_mark"]!)")
                }else{
                    OFAUtils.showToastWithTitle("Invalid Test")
                }
            }
            else{
                OFAUtils.showToastWithTitle("under development")
            }
        }else{
            OFAUtils.showToastWithTitle("No Lectures to play")
        }
    }
    
    //MARK:- Content Delivery Helpers
    
    func getDuration(seconds:Int) -> [Int]{
        let hours = seconds/3600
        let minutes = (seconds%3600)/60
        let second = seconds % 60
        return [hours,minutes,second]
    }
    
    //MARK:- Video
    
    func getVideoDetails(lectureId:String, percentage:String){
        var urlString = ""
        var videoTitle = ""
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,lectureId,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let videoPlayer = self.storyboard?.instantiateViewController(withIdentifier: "CurriculumVideoPlayer") as! VGVerticalVideoViewController
                if let dicBody = dicResult["body"] as? NSDictionary{
                    if "\(dicBody["play_status"]!)" == "0"{
                        OFAUtils.removeLoadingView(nil)
                        OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "\(dicBody["message"]!)", cancelButtonTitle: "OK")
                        return
                    }
                    urlString = "\(dicBody["full_name"]!)"// filename
                    videoTitle = "\(dicBody["lecture_name"]!)"// lecture_name
                    if let liveVideoStatus = dicBody["live_status"] as? String{
                        videoPlayer.isLiveVideo = true
                        if liveVideoStatus == "0" || liveVideoStatus == ""{
                            let sessionAlert = UIAlertController(title: "Live Streaming ended", message: nil, preferredStyle: .alert)
                            sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                                sessionAlert.dismiss(animated: true, completion: nil)
                            }))
                            self.present(sessionAlert, animated: true, completion: nil)
                            return
                        }
                    }
                    
                    if let dicInteractiveQuestion = dicBody["intractive_questions"] as? NSDictionary{
                        videoPlayer.dicInteractiveQuestion = dicInteractiveQuestion
                    }
                    videoPlayer.arrayQuestionTimes = dicBody["intractive_questions_time"] as! NSArray
                    print(dicBody["intractive_questions_time"] as! NSArray)
                    videoPlayer.videoURLString = urlString
                    videoPlayer.videoTitle = videoTitle
                    videoPlayer.lectureID = lectureId
                    videoPlayer.percentage = Float64(percentage)!
                    videoPlayer.rating = ("\(dicBody["rating"]!)" == "<null>" || "\(dicBody["rating"]!)" == "") ? 0 : Int("\(dicBody["rating"]!)")!
                    videoPlayer.isFirstTime = "\(dicBody["is_first_time"]!)" == "1" ? true : false
                    videoPlayer.avPlayer.pause()
                    self.navigationController?.children[1].navigationItem.title = ""
                    self.navigationController?.pushViewController(videoPlayer, animated: true)
                }else{
                    OFAUtils.removeLoadingView(nil)
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: nil, message: "Try again later", cancelButtonTitle: "OK")
                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Document
    
    func getPDFViewControllerWithLectureId(lectureId:String,percentage:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,lectureId,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                if #available(iOS 11.0, *) {
                    let pdfViewer = self.storyboard?.instantiateViewController(withIdentifier: "PDFDocumentVC") as! OFAPDFDocumentViewController
                    pdfViewer.pdfTitle = "\(dicBody["lecture_name"]!)"
                    pdfViewer.pdfURLString = "\(dicBody["filename"]!)"
                    pdfViewer.lectureID = lectureId
                    pdfViewer.percentage = percentage
                    self.navigationController?.children[1].navigationItem.title = ""
                    self.navigationController?.pushViewController(pdfViewer, animated: true)
                } else {
                    // Fallback on earlier versions
                    OFAUtils.showToastWithTitle("You need to update ur phone to ios 11 to view PDFs")
                }
                
//                let pdfURL = URL(string: "\(dicBody["filename"]!)")
//                do {
//                    let pdfData = try Data(contentsOf: pdfURL!)
//                    let pdfDocument = try! PDFDocument(fileData: pdfData as NSData)
////                    pdfDocument.currentPage = 3
//                    let pdfVC = PDFViewController(document: pdfDocument)
//                    pdfVC.annotationController.annotationTypes = [
//                        PDFHighlighterAnnotation.self
//                    ]
//                    self.navigationController?.childViewControllers[1].navigationItem.title = ""
//                    pdfVC.title = "\(dicBody["lecture_name"]!)"
//                    let sampleView = UIView()
//                    sampleView.frame = CGRect(x: 0, y: pdfVC.view.frame.maxY-200, width: pdfVC.view.frame.width, height: 180)
//                    sampleView.backgroundColor = UIColor.red
//                    pdfVC.view.addSubview(sampleView)
//                    pdfVC.view.bringSubview(toFront: sampleView)
//                    self.navigationController?.pushViewController(pdfVC, animated: true)
//                }catch{
//                    OFAUtils.showToastWithTitle("Invalid PDF URL")
//                }
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Text
    
    func getTextDetails(lectureId:String,percentage:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,lectureId,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let textVC = self.storyboard?.instantiateViewController(withIdentifier: "CurriculumTextVC") as! OFACurriculumTextViewController
                textVC.textContent = "\(dicBody["lecture_content"]!)"
                textVC.textTitle = "\(dicBody["lecture_name"]!)"
                textVC.lectureID = lectureId
                textVC.percentage = percentage
                self.navigationController?.children[1].navigationItem.title = ""
                self.navigationController?.pushViewController(textVC, animated: true)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Youtube
    
    func getYoutubeDetails(lectureId:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,lectureId,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let youtubePlayerVC = self.storyboard?.instantiateViewController(withIdentifier: "YoutubePlayerVC") as! OFAYoutubeVideoViewController
                youtubePlayerVC.videoURL = OFAUtils.getYoutubeId(youtubeUrl: "\(dicBody["filename"]!)")//"\(dicBody["filename"]!)"
                youtubePlayerVC.isBrowseCourse = false
                youtubePlayerVC.lectureID = lectureId
                self.navigationController?.children[1].navigationItem.title = "\(dicBody["lecture_name"]!)"
                self.navigationController?.pushViewController(youtubePlayerVC, animated: true)
//                self.present(youtubePlayerVC, animated: true, completion: nil)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Descriptive
    
    func getDescriptiveDetails(lectureId:String,commentsArray:NSArray,marks:String,totalMarks:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,lectureId,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_lecture", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                
                let descriptiveVC = self.storyboard?.instantiateViewController(withIdentifier: "DescriptiveTVC") as! OFADescriptiveTableViewController
                
                descriptiveVC.lecture_id = lectureId
                descriptiveVC.pdfURLString = "\(dicBody["filename"]!)"
                descriptiveVC.descriptiveContent = "\(dicBody["lecture_description"]!)"
                descriptiveVC.arrayComments = commentsArray.mutableCopy() as! NSMutableArray
                descriptiveVC.imageBaseURL = self.imageBaseURL
                if marks == "-1"{
                    descriptiveVC.marks = "Not Reviewed"
                }else{
                    descriptiveVC.marks = marks+" / "+totalMarks
                }
                
                self.navigationController?.children[1].navigationItem.title = "\(dicBody["lecture_name"]!)"
                self.navigationController?.pushViewController(descriptiveVC, animated: true)
                
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- Get Assessment Questions
    
    func getAssessment(lectureId:String,lectureTitle:String,duration:String,assessmentID:String){
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [COURSE_ID,user_id,lectureId,domainKey,accessToken], forKeys: ["course_id" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading Lecture")
        Alamofire.request(userBaseURL+"api/course/get_curriculum_questions", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                OFAUtils.removeLoadingView(nil)
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }else if "\(dicResult["message"]!)" == "Attempts expired!"{
                    OFAUtils.showToastWithTitle("Attempts expired!!!")
                    OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: "Attempts expired!!!", cancelButtonTitle: "OK")
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let arrayQuestions = dicBody["questions"] as! NSArray
                let assessmentVC = self.storyboard?.instantiateViewController(withIdentifier: "AssessmentContainerVC") as! OFAAssessmentContainerViewController
                assessmentVC.instructionString = "\(dicBody["instructions"]!)"
                assessmentVC.seconds = Int(duration)! * 60
                assessmentVC.totalDuration = Int(duration)! * 60
                assessmentVC.assessmentID = assessmentID
                assessmentVC.lectureID = lectureId
                self.navigationController?.children[1].navigationItem.title = lectureTitle
                assessmentVC.arrayQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
//                assessmentVC.arrayOriginalQuestions = arrayQuestions.mutableCopy() as! NSMutableArray
//                UserDefaults.standard.setValue(arrayQuestions.mutableCopy() as! NSMutableArray, forKey: "OriginalAssessmentQuestions")
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: arrayQuestions.mutableCopy() as! NSMutableArray), forKey: "OriginalAssessmentQuestions")
                self.navigationController?.pushViewController(assessmentVC, animated: true)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithinViewControllerWithTitle(viewController: self, alertTitle: "Warning", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    //MARK:- Font Awesome helper-Curriculum Details
    
    func curriculumDetail(indexPath:IndexPath) -> String{
        var detailString = ""
        var curriculumType = ""
        let dicSection = self.arraySections[indexPath.section] as! NSDictionary
        let arrLectures = dicSection["lectures"] as! NSArray
        let dicLecture = arrLectures[indexPath.row] as! NSDictionary
        
        curriculumType = "\(dicLecture["cl_lecture_type"]!)"
        
        if curriculumType == "1"{//video
            var durationString = ""
            let duration = self.getDuration(seconds: Int("\(dicLecture["cl_duration"]!)")!)
            if duration[0] > 0 {
                durationString = "\(duration[0]) hr \(duration[1]) m \(duration[2]) s"
            }else if duration[1] > 0 {
                durationString = "\(duration[1]) m \(duration[2]) s"
            }else if duration[2] >= 0 {
                durationString = " \(duration[2]) s"
            }
            detailString = "  video - duration - \(durationString)"
        }else if curriculumType == "2"{//Doc
            detailString = "  Document"
        }else if curriculumType == "7"{//Assessment
            detailString = "  Assessment - \(dicLecture["num_of_question"]!) questions"
        }else if curriculumType == "4"{//youtube
            detailString = "  Youtube"
        }else if curriculumType == "5"{//text
            detailString = "  Text "//- \(dicLecture["num_of_question"]!) questions"
        }else if curriculumType == "6"{//wikipedia
            detailString = "  Wiki"
        }else if curriculumType == "3"{//live
            detailString = "  Live "
        }else if curriculumType == "8"{//Descriptive
            detailString = "  Descriptive "//- \(dicLecture["num_of_question"]!) questions"
        }else if curriculumType == "9"{//recording
            detailString = "  Recording"
        }
        return detailString
    }
    
    //MARK:- iPopUP Functions
    
//    override func viewDidAppear(_ animated: Bool) {
//        viewRatingPopup.setNeedsFocusUpdate()
//    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        
        viewRatingPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: 146))
        viewRatingPopup.center = view.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if touches.first != nil{
            removeBlur()
            animateOut()
        }
    }
    
    @objc func touchesView(){//tapAction
        removeBlur()
        animateOut()
    }
    
    public func removeBlur() {
        blurEffectView.removeFromSuperview()
    }
    
    func showRatingPopUp(){
        if !OFAUtils.isiPhone(){
            viewRatingPopup.frame.origin.x = 0
            viewRatingPopup.frame.origin.y = 0
        }
        else{
            viewRatingPopup.frame.origin.x = 0
            viewRatingPopup.frame.origin.y = 0
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            if GlobalVariables.sharedManager.rotated() == true{
                viewRatingPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: 146))
            }
            else {
                viewRatingPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 50, height: 146))
            }
        }
        viewRatingPopup.layer.cornerRadius = 10 //make oval view edges
    }
    
    func blur(){
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        let rootView = delegate.window?.rootViewController?.view
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds//(rootView?.bounds)!
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.view.addSubview(blurEffectView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.touchesView))
        singleTap.numberOfTapsRequired = 1
        self.blurEffectView.addGestureRecognizer(singleTap)
    }
    
    func animateIn() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        //        self.view.addSubview(viewRatingPopup)
        rootView?.addSubview(viewRatingPopup)
        viewRatingPopup.center = (rootView?.center)!
        viewRatingPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        viewRatingPopup.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.viewRatingPopup.alpha = 1
            self.viewRatingPopup.transform = CGAffineTransform.identity
        }
    }
    
    public func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewRatingPopup.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.viewRatingPopup.alpha = 0
        }) { (success:Bool) in
            self.viewRatingPopup.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.viewRatingPopup.removeFromSuperview()
        }
    }
}
