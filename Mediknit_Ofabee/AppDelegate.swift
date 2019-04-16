//
//  AppDelegate.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/8/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import CoreData
import SlideMenuControllerSwift
import FAPanels
import GoogleSignIn
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        AnyUIView.appearance().font = UIFont(name: "yourFont", size: yourSize)
        //        UILabel.appearance().font = UIFont(name: "Open-Sans", size: 15.0)
        UserDefaults.standard.set("1", forKey: DomainKey)
        UIApplication.shared.statusBarStyle = .default
        
        if UserDefaults.standard.bool(forKey: isTemporaryLogin){
            UserDefaults.standard.set(false, forKey: isTemporaryLogin)
            UserDefaults.standard.removeObject(forKey: USER_ID)
            OFAUtils.showToastWithTitle("Temporary login expired")
        }
        
        GIDSignIn.sharedInstance().clientID = GoogleClientID
        if UserDefaults.standard.value(forKey: DomainKey) != nil{
            self.initializePreLoginPage()
        }else{
            self.initializeDomainPage()
        }
        let userId = UserDefaults.standard.value(forKey: USER_ID) as? String
        if userId != nil {
//            self.autoLogin(userId: userId!)
            self.showTouchIDViewController()
        }
        self.checkAppVersion()
        return true
    }
    
    func showTouchIDViewController(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let domainView = storyBoard.instantiateViewController(withIdentifier: "TouchIDVC")
        self.window?.rootViewController = domainView
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("Will resign active")
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "WillResignActiveNotification"), object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func checkAppVersion(){
        let dicParameters = NSDictionary(object: "ios", forKey: "os" as NSCopying)
        Alamofire.request(userBaseURL+"api/authenticate/version_check", method: .post, parameters: dicParameters as? Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (responseJSON) in
            if let dicResult = responseJSON.result.value as? NSDictionary{
                let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
                let version = nsObject as! String
                let dicBody = dicResult["body"] as! NSDictionary
                if "\(dicBody["version"]!)" != version{
                    let updateAlert = UIAlertController(title: "Update Available", message: OFAUtils.getHTMLAttributedString(htmlString: "\(dicBody["description"]!)"), preferredStyle: .alert)
                    let updateAction = UIAlertAction(title: "Update Now", style: .default, handler: { (action) in
                        UIApplication.shared.open(URL(string: "\(dicBody["app_url"]!)")!, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                        
                    })
                    updateAlert.addAction(updateAction)
                    if "\(dicBody["is_mandatory"]!)" == "0" {
                        updateAlert.addAction(cancelAction)
                    }else{
                        
                    }
                    self.window?.rootViewController?.present(updateAlert, animated: true, completion: nil)
                }else{
                    print("App is Up-to-Date")
                }
            }else{
                print("API failure")
            }
        }
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
    func autoLogin(userId:String){
        let userArray = self.getAllUsersFromCoreData()
        let filteredArray = userArray.filtered(using: NSPredicate(format: "user_id==%@", userId))
        if filteredArray.count > 0{
            let user = filteredArray.last as! User
            let dicData = NSDictionary(objects: [user.user_name!,user.user_email!,user.user_phone!,user.user_image!,user.user_about!,user.user_id!,user.otp_status!], forKeys: ["us_name" as NSCopying,"us_email" as NSCopying,"us_phone" as NSCopying,"us_image" as NSCopying,"us_about" as NSCopying,"user_id" as NSCopying,"otp_status" as NSCopying])
            OFASingletonUser.ofabeeUser.updateUserDetailsFromCoreData(dicData: dicData)
            if user.otp_status != "1"{
                self.initializePreLoginPage()
            }else{
                self.initializeBrowserCourse()
            }
        }else{
            self.initializePreLoginPage()
        }
    }
    
    func getAllUsersFromCoreData() -> NSArray{
        var arrayResult = NSArray()
        let context = persistentContainer.viewContext
        do{
            arrayResult = try context.fetch(User.fetchRequest()) as NSArray
        }catch{
            print("Error while fetching CoreData")
        }
        return arrayResult
    }
    
    func initializeDomainPage(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let domainView = storyBoard.instantiateViewController(withIdentifier: "DomainPage")
        self.window?.rootViewController = domainView
        self.window?.makeKeyAndVisible()
    }
    
    func initializePreLoginPage(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let domainView = storyBoard.instantiateViewController(withIdentifier: "PreLoginNVC")
        self.window?.rootViewController = domainView
        self.window?.makeKeyAndVisible()
    }
    
    func initializeBrowserCourse(){
//        UIApplication.shared.statusBarStyle = .default
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let leftMenuVC: OFALeftSideMenuTableViewController = mainStoryboard.instantiateViewController(withIdentifier: "LeftSideMenu") as! OFALeftSideMenuTableViewController
//        let centerVC: OFAMyCourseTableViewController = mainStoryboard.instantiateViewController(withIdentifier: "MyCourseTVC") as! OFAMyCourseTableViewController
        let centerVC: OFADashboardTableViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardTVC") as! OFADashboardTableViewController
        let centerNavVC = UINavigationController(rootViewController: centerVC)
        
//        let rootController = FAPanelController()
//        _ = rootController.center(centerNavVC).left(leftMenuVC)
//        rootController.leftPanelPosition = .front
        
        self.window?.rootViewController = centerNavVC// rootController
        self.window?.makeKeyAndVisible()
    }
    
    func initializeLoginPage(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let domainView = storyBoard.instantiateViewController(withIdentifier: "LoginTVC")
        self.window?.rootViewController = domainView
        self.window?.makeKeyAndVisible()
    }
    
    func logout(){
        GIDSignIn.sharedInstance().signOut()
        UIApplication.shared.statusBarStyle = .default
        let userArray = self.getAllUsersFromCoreData()
        let filteredArray = userArray.filtered(using: NSPredicate(format: "user_id==%@", UserDefaults.standard.value(forKey: USER_ID) as! String))
        for item in filteredArray{
            let user = item as! User
            self.persistentContainer.viewContext.delete(user)
        }
        UserDefaults.standard.removeObject(forKey: USER_ID)
        UserDefaults.standard.removeObject(forKey: Subscribed_Courses)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginView = storyBoard.instantiateViewController(withIdentifier: "PreLoginNVC")
        self.window?.rootViewController = loginView
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Mediknit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

