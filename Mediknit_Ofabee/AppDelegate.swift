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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        AnyUIView.appearance().font = UIFont(name: "yourFont", size: yourSize)
        //        UILabel.appearance().font = UIFont(name: "Open-Sans", size: 15.0)
        UserDefaults.standard.set("1", forKey: DomainKey)
        UIApplication.shared.statusBarStyle = .default
        GIDSignIn.sharedInstance().clientID = GoogleClientID
        if UserDefaults.standard.value(forKey: DomainKey) != nil{
            self.initializePreLoginPage()
        }else{
            self.initializeDomainPage()
        }
        let userId = UserDefaults.standard.value(forKey: USER_ID) as? String
        if userId != nil {
            self.autoLogin(userId: userId!)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    
    func autoLogin(userId:String){
        let userArray = self.getDataFromCoreData()
        let filteredArray = userArray.filtered(using: NSPredicate(format: "user_id==%@", userId))
        let user = filteredArray.last as! User
        let dicData = NSDictionary(objects: [user.user_name!,user.user_email!,user.user_phone!,user.user_image!,user.user_about!,user.user_id!], forKeys: ["us_name" as NSCopying,"us_email" as NSCopying,"us_phone" as NSCopying,"us_image" as NSCopying,"us_about" as NSCopying,"user_id" as NSCopying])
        OFASingletonUser.ofabeeUser.updateUserDetailsFromCoreData(dicData: dicData)
        self.initializeBrowserCourse()
    }
    
    func getDataFromCoreData() -> NSArray{
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
        UIApplication.shared.statusBarStyle = .default
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let leftMenuVC: OFALeftSideMenuTableViewController = mainStoryboard.instantiateViewController(withIdentifier: "LeftSideMenu") as! OFALeftSideMenuTableViewController
        let centerVC: OFAMyCoursesContainerViewController = mainStoryboard.instantiateViewController(withIdentifier: "MyCoursesContainerVC") as! OFAMyCoursesContainerViewController
        let centerNavVC = UINavigationController(rootViewController: centerVC)
        
        let rootController = FAPanelController()
        _ = rootController.center(centerNavVC).left(leftMenuVC)
        rootController.leftPanelPosition = .front
        
        self.window?.rootViewController = rootController
        self.window?.makeKeyAndVisible()
    }
    
    func initializeLoginPage(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let domainView = storyBoard.instantiateViewController(withIdentifier: "LoginTVC")
        self.window?.rootViewController = domainView
        self.window?.makeKeyAndVisible()
    }
    
    func logout(){
        UIApplication.shared.statusBarStyle = .default
        UserDefaults.standard.removeObject(forKey: USER_ID)
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

