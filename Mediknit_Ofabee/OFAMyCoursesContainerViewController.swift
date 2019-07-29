//
//  OFAMyCoursesContainerViewController.swift
//  Life_Line
//
//  Created by Administrator on 7/10/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAMyCoursesContainerViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var buttonMoreCourses: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.setNavigationBarItem(isSidemenuEnabled: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Courses"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
//        self.view.layoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    //MARK:- Button Action
    
    @IBAction func moreCoursesPressed(_ sender: UIButton) {
        let browseCourse = self.storyboard?.instantiateViewController(withIdentifier: "BrowseCourseTVC") as!OFABrowseCourseTableViewController
        browseCourse.isPushedView = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(browseCourse, animated: true)
    }
}
