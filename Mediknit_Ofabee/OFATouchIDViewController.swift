//
//  OFATouchIDViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 18/03/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import LocalAuthentication

class OFATouchIDViewController: UIViewController {

    @IBOutlet weak var buttonTouchID: UIButton!
    var visualEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showTouchID()
    }
    
    @IBAction func touchIDPressed(_ sender: UIButton) {
        self.showTouchID()
    }
    
    func getBlurBG(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(visualEffectView)
    }
    
    func showTouchID(){
        self.getBlurBG()
        let context = LAContext()
        let myLocalizedReasonString = "Login to Mediknit using Touch ID"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { (success, evaluateError) in
                DispatchQueue.main.async {
                    if let err = evaluateError {
                        self.visualEffectView.removeFromSuperview()
                        switch err._code {
                        case LAError.Code.systemCancel.rawValue:
                            self.notifyUser("Session cancelled", err: err.localizedDescription)
                        case LAError.Code.userCancel.rawValue:
                            self.notifyUser("Please try again", err: err.localizedDescription)
                        case LAError.Code.userFallback.rawValue:
                            self.notifyUser("Authentication", err: "Password option selected")
                            // Custom code to obtain password here
                            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString, reply: { (success, error) in
                                if success{
                                    let userId = UserDefaults.standard.value(forKey: USER_ID) as? String
                                    if userId != nil {
                                        let delegate = UIApplication.shared.delegate as! AppDelegate
                                        delegate.autoLogin(userId: userId!)
                                    }
                                }else{
                                    print(error?.localizedDescription as Any)
                                }
                            })
                        default:
                            self.notifyUser("Authentication failed", err: err.localizedDescription)
                            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString, reply: { (success, error) in
                                if success{
                                    let userId = UserDefaults.standard.value(forKey: USER_ID) as? String
                                    if userId != nil {
                                        let delegate = UIApplication.shared.delegate as! AppDelegate
                                        delegate.autoLogin(userId: userId!)
                                    }
                                }else{
                                    print(error?.localizedDescription as Any)
                                }
                            })
                        }
                    } else {
//                        self.notifyUser("Authentication Successful", err: "You now have full access")
                        let userId = UserDefaults.standard.value(forKey: USER_ID) as? String
                        if userId != nil {
                            let delegate = UIApplication.shared.delegate as! AppDelegate
                            delegate.autoLogin(userId: userId!)
                        }
                    }
                }
            }
        }else{
            // Device cannot use biometric authentication
            self.visualEffectView.removeFromSuperview()
            if let err = error {
                switch err.code{
                case LAError.Code.biometryNotEnrolled.rawValue:
                    notifyUser("User is not enrolled", err: err.localizedDescription)
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser("A passcode has not been set", err: err.localizedDescription)
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser("Biometric authentication not available", err: err.localizedDescription)
                case LAError.Code.biometryLockout.rawValue:
                    notifyUser("Biometric is locked out", err: err.localizedDescription)
                    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString, reply: { (success, error) in
                            DispatchQueue.main.async {
                                if success{
                                    let userId = UserDefaults.standard.value(forKey: USER_ID) as? String
                                    if userId != nil {
                                        let delegate = UIApplication.shared.delegate as! AppDelegate
                                        delegate.autoLogin(userId: userId!)
                                    }
                                }else{
                                    print(error?.localizedDescription as Any)
                                }
                            }
                        })
                    }
                default:
                    notifyUser("Unknown error", err: err.localizedDescription)
                }
            }
        }
    }
    func notifyUser(_ msg: String, err: String?) {
        print(err!)
//        OFAUtils.showToastWithTitle(msg)
//        self.visualEffectView.removeFromSuperview()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
