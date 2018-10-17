//
//  OFADescriptiveTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/21/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift
import Alamofire

class OFADescriptiveTableViewController: UITableViewController,UITextFieldDelegate,UIWebViewDelegate {

    var arrayComments = NSMutableArray()
    var imageBaseURL = ""
    
    @IBOutlet var webViewDescription: UIWebView!
    @IBOutlet var labelMark: UILabel!
    @IBOutlet var buttonQuestionPaper: UIButton!
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var viewFooter: UIView!
    
    @IBOutlet var textComment: UITextField!
    @IBOutlet var buttonSendComment: UIButton!
    
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
    let access_token = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
    
    var descriptiveContent = ""
    var pdfURLString = ""
    var lecture_id = ""
    var comment_id = ""
    var comment_api = ""
    var marks = ""
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textComment.delegate = self
        self.textComment.returnKeyType = .done
        
        self.labelMark.text = "Mark : \(self.marks)"
        
        self.buttonSendComment.layer.cornerRadius = self.buttonSendComment.frame.height/2
        self.buttonSendComment.clipsToBounds = true
        self.webViewDescription.delegate = self
        self.webViewDescription.scrollView.isScrollEnabled = false
        self.webViewDescription.loadHTMLString(self.descriptiveContent, baseURL: nil)
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextPressed))
        self.saveLectureProgress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = self.viewHeader {
            let height = self.webViewDescription.scrollView.contentSize.height+86//headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height+60
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    //MARK:- Button Actions
    
    func nextPressed(){
        print("Next Lecture")
    }
    
    @IBAction func questionPaperPressed(_ sender: UIButton) {
        do {
            let pdfDoc = try Data(contentsOf:URL(string: self.pdfURLString)!)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pdfDoc], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.buttonQuestionPaper
            present(activityViewController, animated: true, completion: nil)
        }
        catch{
            OFAUtils.showToastWithTitle("Unable to download file")
        }
    }

    @IBAction func commentOptionPressed(_ sender: UIButton) {
        let dicComment = self.arrayComments[sender.tag] as! NSDictionary
        let optionAction = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var deleteAction = UIAlertAction()
        var cancelAction = UIAlertAction()
    
        deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let dicParameters = NSDictionary(objects: [self.user_id,"\(dicComment["comment_id"]!)",self.domainKey,self.access_token], forKeys: ["user_id" as NSCopying,"comment_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
            Alamofire.request(userBaseURL+"api/course/delete_descriptive_question_comment", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
                if let dicResponse = responseJSON.result.value as? NSDictionary{
                    self.view.endEditing(true)
                    self.textComment.text = ""
                    OFAUtils.showToastWithTitle("\(dicResponse["message"]!)")
                    self.arrayComments.removeObject(at: sender.tag)
                    self.tableView.reloadData()
                }else{
                    OFAUtils.showAlertViewControllerWithTitle("Some Error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
                }
            }
        })
        
        cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        
        if OFASingletonUser.ofabeeUser.user_id! == "\(dicComment["user_id"]!)"{
            optionAction.addAction(deleteAction)
            optionAction.addAction(cancelAction)
        }
        
        self.present(optionAction, animated: true, completion: nil)
        
        if !OFAUtils.isiPhone(){
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! OFAQuestionDetailsRepliesTableViewCell
            let popOver = optionAction.popoverPresentationController
            popOver?.sourceRect = (cell.buttonOptions.bounds)
            popOver?.sourceView = cell.buttonOptions
        }
    }
    
    @IBAction func sendCommentPressed(_ sender: UIButton) {
        if OFAUtils.isWhiteSpace(self.textComment.text!) {
            OFAUtils.showToastWithTitle("Enter Comment")
            return
        }
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let dicParameters = NSDictionary(objects: [self.textComment.text!,user_id,self.lecture_id,domainKey,accessToken], forKeys: ["comment" as NSCopying,"user_id" as NSCopying,"lecture_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/save_descriptive_question_comment", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                if "\(dicResult["message"]!)" == "Course subscription expired" {
                    let sessionAlert = UIAlertController(title: "Course subscription expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        sessionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                let dicBody = dicResult["body"] as! NSDictionary
                let dicComment = dicBody["comment"] as! NSDictionary
                self.arrayComments.add(dicComment)
                self.textComment.text = ""
                self.tableView.reloadData()
            }else{
                OFAUtils.showAlertViewControllerWithTitle(nil, message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    //MARK:- Download helper
    
    func savePdf(){
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(self.comment_id)"
        let pdfDoc = NSData(contentsOf:URL(string: self.pdfURLString)!)
        fileManager.createFile(atPath: paths, contents: pdfDoc as Data?, attributes: nil)
    }
    
    func loadPDFAndShare(){
        
        let fileManager = FileManager.default
        let documentoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(self.comment_id)"//(self.getDirectoryPath() as NSString).appendingPathComponent("documento.pdf")
        
        if fileManager.fileExists(atPath: documentoPath){
            let documento = NSData(contentsOfFile: documentoPath)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.buttonQuestionPaper
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("document was not found")
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayComments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptiveCommentsCell", for: indexPath) as! OFADescriptiveTableViewCell

        let dicComments = self.arrayComments[indexPath.row] as! NSDictionary
        cell.customizeCellWithDetails(imageURLString: self.imageBaseURL+"\(dicComments["us_image"]!)", fullName: "\(dicComments["us_name"]!)", comment: "\(dicComments["comment"]!)")
        
        
        let stringVar = String()
        let fontVar = UIFont(fa_fontSize: 15)
        let faType = stringVar.fa.fontAwesome(.fa_ellipsis_v)
        cell.buttonOption.titleLabel?.font = fontVar
        cell.buttonOption.setTitle(faType, for: .normal)
        
        cell.buttonOption.tag = indexPath.row
        
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.viewFooter
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 106
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.estimatedRowHeight = 118
        self.tableView.rowHeight = UITableView.automaticDimension
        return self.tableView.rowHeight
    }
    
    //MARK:- Save lecture percentage
    
    func saveLectureProgress(){
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.lecture_id,"100",user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"percentage" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        Alamofire.request(userBaseURL+"api/course/save_lecture_percentage", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let result = responseJSON.result.value{
                OFAUtils.removeLoadingView(nil)
                let dicResult = result as! NSDictionary
                if "\(dicResult["message"]!)" == "Login failed" {
                    let sessionAlert = UIAlertController(title: "Session Expired", message: nil, preferredStyle: .alert)
                    sessionAlert.addAction(UIAlertAction(title: "Login Again", style: .default, handler: { (action) in
                        self.sessionExpired()
                    }))
                    self.present(sessionAlert, animated: true, completion: nil)
                    return
                }
                print(dicResult)
            }else{
                OFAUtils.removeLoadingView(nil)
                OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: responseJSON.result.error?.localizedDescription, cancelButtonTitle: "OK")
            }
        }
    }
    
    //MARK:- WebView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.viewDidLayoutSubviews()
        self.tableView.scrollsToTop = true
        self.viewHeader.layoutIfNeeded()
    }
    
    //MARK:- Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
