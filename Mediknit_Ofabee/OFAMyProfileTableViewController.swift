//
//  OFAMyProfileTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/11/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire
import Instabug

class OFAMyProfileTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet var imageViewBG: UIImageView!
    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var labelEmail: UILabel!
    @IBOutlet var labelPhone: UILabel!
    @IBOutlet var buttonleftIcon: UIButton!
    
    var imagePicker = UIImagePickerController()
    var actionSheet = UIAlertController()
//    var pickedImage = UIImage()
    var imageData : Data?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem(isSidemenuEnabled: true)
        
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = UIColor.lightGray.cgColor
        self.imageViewUser.contentMode = .scaleAspectFill
//        self.textViewBio.dropShadow()
//        self.textViewBio.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "FeedbackIcon"), style: .plain, target: self, action: #selector(self.feedbackPressed))
        
        self.imageViewUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.editImagePressed)))
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.buttonleftIcon)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Profile"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        if OFASingletonUser.ofabeeUser.user_imageURL != nil{
            self.imageViewUser.sd_setImage(with: URL(string: OFASingletonUser.ofabeeUser.user_imageURL!), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .refreshCached)
            self.labelUserName.text = OFASingletonUser.ofabeeUser.user_name!
            self.labelEmail.text = OFASingletonUser.ofabeeUser.user_email!
            if OFASingletonUser.ofabeeUser.user_phone! == "0" || OFASingletonUser.ofabeeUser.user_phone! == ""{
                self.labelPhone.text = "Not Available"
            }else{
                self.labelPhone.text = OFASingletonUser.ofabeeUser.user_phone!
            }
//            self.textViewBio.text = OFASingletonUser.ofabeeUser.user_about!
        }else{
            self.imageViewUser.image = #imageLiteral(resourceName: "Default image")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func dashboardIconPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func feedbackPressed(){
        BugReporting.shouldCaptureViewHierarchy = true
        Instabug.show()
    }
    
    @objc func editPressed(){
        let editProfile = self.storyboard?.instantiateViewController(withIdentifier: "EditMyProfileTVC") as! OFAEditMyProfileTableViewController
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(editProfile, animated: true)
    }
    
    @objc func editImagePressed(){
        self.imagePicker.delegate = self
        actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { (alert:UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
                let cameraAlert = UIAlertController ( title:  NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Camera Unavailable", comment: ""), preferredStyle: UIAlertController.Style.alert)
                cameraAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(cameraAlert, animated: true, completion: nil)
            }
            else {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default, handler: { (alert:UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
                let cameraAlert = UIAlertController ( title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Gallery Unavailable", comment: ""), preferredStyle: UIAlertController.Style.alert)
                cameraAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(cameraAlert, animated: true, completion: nil)
            }
            else {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (alert:UIAlertAction) -> Void in
            self.view.endEditing(true)
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        if !OFAUtils.isiPhone(){
            let popOVer = actionSheet.popoverPresentationController
            popOVer?.sourceRect = self.imageViewUser.bounds
            popOVer?.sourceView = self.imageViewUser
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    //MARK:- Coredata Helper
    
    func getDataFromCoreData() -> NSArray{
        var arrayResult = NSArray()
        //        let context = persistentContainer.viewContext
        do{
            arrayResult = try self.context.fetch(User.fetchRequest()) as NSArray
        }catch{
            print("Error while fetching CoreData")
        }
        return arrayResult
    }
    
    //MARK:- Image upload Helper
    
    func uploadImage(imageData:Data){
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [user_id,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        var jsonString = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dicParameters)
            if let json = String(data: jsonData, encoding: .utf8) {
                print(json)
                jsonString=json
            }
        } catch {
            print("something went wrong with parsing json")
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "body")
            //            multipartFormData.append(UIImagePNGRepresentation(self.pickedImage)!, withName: "file")
            multipartFormData.append(imageData, withName: "file", fileName: "\(OFAUtils.getTimeStamp()).jpeg", mimeType: "image/jpeg")
        }, to:userBaseURL+"api/profile/change_profile_image")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //                    print(progress)
                    OFAUtils.showLoadingViewWithTitle("uploading")
                })
                
                upload.responseJSON { response in
                    OFAUtils.removeLoadingView(nil)
                    if let dicResult = response.result.value as? NSDictionary{
                        print(dicResult)
//                        OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                        let userId = UserDefaults.standard.value(forKey: USER_ID) as! String
                        let userArray = self.getDataFromCoreData()
                        let filteredArray = userArray.filtered(using: NSPredicate(format: "user_id==%@", userId))
                        let user = filteredArray.last as! User
                        user.user_image = "\(dicResult["user_image"]!)"
                        let singletonUser = OFASingletonUser.ofabeeUser
                        singletonUser.user_imageURL = "\(dicResult["user_image"]!)"
//                        self.imageViewUser.sd_setImage(with: URL(string: "\(dicResult["user_image"]!)"), placeholderImage: UIImage(named: "Default image"), options: .refreshCached)
                        do{
                            self.imageViewUser.image = try UIImage(data: Data(contentsOf: URL(string: "\(dicResult["user_image"]!)")!))
                        }catch{
                            print("image process error")
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EditProfileNotification"), object: nil, userInfo: ["name":singletonUser.user_name!,"image":"\(dicResult["user_image"]!)"])
                        //                        self.delegate?.didProfileDetailsChanged(name: singletonUser.user_name!, imageURLString: "\(dicResult["user_image"]!)")
                        if self.context.hasChanges {
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }else{
                        OFAUtils.removeLoadingView(nil)
                        OFAUtils.showAlertViewControllerWithTitle("Some error Occured", message: response.result.error?.localizedDescription, cancelButtonTitle: "OK")
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError.localizedDescription)
            }
        }
    }
    
    //MARK:- ImagePicker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let pickedImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)!
        let resizedImage = OFAUtils.resizeImage(pickedImage, newWidth: 400)
        if let convertedData = resizedImage.jpeg(.medium){
            self.imageData = convertedData
            self.imageViewUser.image = resizedImage//UIImage(data: self.imageData!)
            self.uploadImage(imageData: self.imageData!)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
