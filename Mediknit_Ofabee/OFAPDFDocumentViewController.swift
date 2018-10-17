//
//  OFAPDFDocumentViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 9/19/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import PDFKit
//import QuartzCore
import Alamofire

@available(iOS 11.0, *)
class OFAPDFDocumentViewController: UIViewController {
    
    var pdfTitle = ""
    var pdfURLString = ""
    var percentage = ""
    var lectureID = ""
    var originalPercentage = ""
    
    @IBOutlet var buttonCurriculum: UIButton!
    @IBOutlet var buttonQandA: UIButton!
    
    var pdfDocument: PDFDocument?
    var isValidFile = true
    
    @IBOutlet var viewPDF: UIView!
    var pdfView: PDFView!
    
    var shareBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.originalPercentage = self.percentage
        
        self.buttonCurriculum.layer.cornerRadius = self.buttonCurriculum.frame.height/2
        self.buttonQandA.layer.cornerRadius = self.buttonQandA.frame.height/2
        
        let pdfURL = URL(string: self.pdfURLString)

        pdfView = PDFView(frame: CGRect(x: 20, y: 20, width: self.view.frame.width, height: self.viewPDF.frame.height))
        self.pdfView.center = self.viewPDF.center
//        self.pdfView = self.viewPDF as! PDFView!
        do{
            pdfDocument = try PDFDocument(data: Data(contentsOf: pdfURL!))
            pdfView.document = pdfDocument
            pdfView.displayMode = PDFDisplayMode.singlePageContinuous
            pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            pdfView.autoScales = true
            
            guard let floatPercentage = NumberFormatter().number(from: self.percentage) else { return }
            
            let currentPage:CGFloat = (CGFloat(floatPercentage) / 100) * CGFloat((pdfDocument?.pageCount)!)
            if let pageSelected = pdfDocument?.page(at: Int(currentPage)-1){
                pdfView.go(to: pageSelected)
            }
            self.view.addSubview(pdfView)
            self.isValidFile = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.savePdf))
        }catch{
            print("file not found")
            self.isValidFile = false
            OFAUtils.showToastWithTitle("File not found")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.pdfTitle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isValidFile{
            let totalpageCount:CGFloat = CGFloat((pdfDocument?.pageCount)!)
            let currentPageIndex:CGFloat = CGFloat((pdfDocument?.index(for: pdfView.currentPage!))!)+1
            let value:CGFloat = CGFloat((currentPageIndex/totalpageCount) * 100)
            if value > 90{
                self.percentage = "100"
            }else{
                self.percentage = "\(Int(value))"
            }
            if Int(self.percentage)! > Int(self.originalPercentage)!{
                self.saveLectureProgress()
            }
        }
    }
    
    //MARK:- Save lecture percentage
    
    func saveLectureProgress(){
        let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [self.lectureID,self.percentage,user_id,domainKey,accessToken], forKeys: ["lecture_id" as NSCopying,"percentage" as NSCopying,"user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
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
    
    func sessionExpired() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logout()
    }
    
    @IBAction func QandAPressed(_ sender: UIButton) {
        let QandATabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        QandATabTVC.isPresented = false
        self.navigationController?.pushViewController(QandATabTVC, animated: true)
    }
    
    @IBAction func curriculumPresses(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func nextPressed(){
        
    }
    
    func sharePressed(){
        let pdfDoc = try! Data(contentsOf:URL(string: self.pdfURLString)!)
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pdfDoc as Data], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
        present(activityViewController, animated: true, completion: nil)
//        self.savePdf()
//        self.loadPDFAndShare()
    }
    
    @objc func savePdf(){
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(self.pdfTitle)"
        let pdfDoc = NSData(contentsOf:URL(string: self.pdfURLString)!)
        fileManager.createFile(atPath: paths, contents: pdfDoc as Data?, attributes: nil)
        loadPDFAndShare()
    }
    
    func loadPDFAndShare(){
        
        let fileManager = FileManager.default
        let documentoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(self.pdfTitle)"//(self.getDirectoryPath() as NSString).appendingPathComponent("documento.pdf")
        
        if fileManager.fileExists(atPath: documentoPath){
            let documento = NSData(contentsOfFile: documentoPath)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("document was not found")
        }
    }
}
