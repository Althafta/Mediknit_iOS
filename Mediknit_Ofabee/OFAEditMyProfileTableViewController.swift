//
//  OFAEditMyProfileTableViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class OFAEditMyProfileTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate {
    @IBOutlet var imageViewUser: UIImageView!
    @IBOutlet var textUserName: JJMaterialTextfield!
    @IBOutlet var textViewBioDescription: UITextView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let user_id = UserDefaults.standard.value(forKey: USER_ID) as! String
    
    var imagePicker = UIImagePickerController()
    var actionSheet = UIAlertController()
    var pickedImage = UIImage()
    var imageData : Data?
        
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.saveProfilePressed))
        
        self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.height/2
        self.imageViewUser.layer.borderWidth = 3.0
        self.imageViewUser.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewBioDescription.dropShadow()
        
        //"http://test.onlineprofesor.com/uploads/test.onlineprofesor.com/user/181bc5653e61577c5cddac99fabac2fd.jpg";
        if OFASingletonUser.ofabeeUser.user_imageURL != nil{
            self.imageViewUser.sd_setImage(with: URL(string: OFASingletonUser.ofabeeUser.user_imageURL!), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
            self.textUserName.text = OFASingletonUser.ofabeeUser.user_name!
            self.textViewBioDescription.text = OFASingletonUser.ofabeeUser.user_about!
        }else{
            self.imageViewUser.image = #imageLiteral(resourceName: "Default image")
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        singleTap.numberOfTapsRequired = 1
        self.imageViewUser.addGestureRecognizer(singleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Edit Profile"
    }
    
    @objc func tapAction(){
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
    
    @objc func saveProfilePressed(){
        let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN) as! String
        let domainKey = UserDefaults.standard.value(forKey: DomainKey) as! String
        let dicParameters = NSDictionary(objects: [user_id,self.textUserName.text!,self.textViewBioDescription.text!,domainKey,accessToken], forKeys: ["user_id" as NSCopying,"user_name" as NSCopying,"user_bio" as NSCopying,"domain_key" as NSCopying,"token" as NSCopying])
        OFAUtils.showLoadingViewWithTitle("Loading")
        Alamofire.request(userBaseURL+"api/course/edit_user_profile", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
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
                OFAUtils.showToastWithTitle("Profile updated successfully")
                self.updateCoreDataUser()
                self.updateSingletonUser()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EditProfileDetailsNotification"), object: nil, userInfo: ["name":OFASingletonUser.ofabeeUser.user_name!])
                self.navigationController?.popViewController(animated: true)
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
    
    func updateSingletonUser(){
        let user = OFASingletonUser.ofabeeUser
        user.user_name = self.textUserName.text!
        user.user_about = self.textViewBioDescription.text!
    }
    
    func updateCoreDataUser(){
        let userId = UserDefaults.standard.value(forKey: USER_ID) as! String
        let userArray = self.getDataFromCoreData()
        let filteredArray = userArray.filtered(using: NSPredicate(format: "user_id==%@", userId))
        let user = filteredArray.last as! User
        user.user_name = self.textUserName.text!
        user.user_about = self.textViewBioDescription.text!
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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
    
    func uploadImage(fileURL:URL){
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
            multipartFormData.append(self.imageData!, withName: "file", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
        }, to:userBaseURL+"api/profile/change_profile_image")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
//                    print(progress)
                })
                
                upload.responseJSON { response in
                    if let dicResult = response.result.value as? NSDictionary{
                        OFAUtils.showToastWithTitle("\(dicResult["message"]!)")
                        let userId = UserDefaults.standard.value(forKey: USER_ID) as! String
                        let userArray = self.getDataFromCoreData()
                        let filteredArray = userArray.filtered(using: NSPredicate(format: "user_id==%@", userId))
                        let user = filteredArray.last as! User
                        user.user_image = "\(dicResult["user_image"]!)"
                        let singletonUser = OFASingletonUser.ofabeeUser
                        singletonUser.user_imageURL = "\(dicResult["user_image"]!)"
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

//        pickedImage = (info[UIImagePickerControllerEditedImage] as? UIImage)!
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL = NSURL(fileURLWithPath: documentDirectory)
        let localPath = photoURL.appendingPathComponent("ProfileImage(\(self.user_id)")
        pickedImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage)!
        let resizeImage = OFAUtils.resizeImage(pickedImage, newWidth: 350)
        self.imageData = resizeImage.jpegData(compressionQuality: 1.0)
        do
        {
            try self.imageData?.write(to: localPath!, options: Data.WritingOptions.atomic)
        }
        catch
        {
            // Catch exception here and act accordingly
        }
        self.imageViewUser.image = resizeImage
        self.tableView.reloadData()
        print(localPath!)
        self.uploadImage(fileURL: localPath!)
        dismiss(animated: true, completion: nil)
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
