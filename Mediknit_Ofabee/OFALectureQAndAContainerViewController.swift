//
//  OFALectureQAndAContainerViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 14/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFALectureQAndAContainerViewController: UIViewController {
    
    enum TabIndex : Int {
        case discussionTab = 0
        case myQuestionsTab = 1
    }
    
    @IBOutlet weak var segmentControl: TabySegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var currentViewController: UIViewController?
    
    lazy var discussionTabTVC: UIViewController? = {
        let discussionTabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        return discussionTabTVC
    }()
    
    lazy var myQuestionTabTVC: UIViewController? = {
        let myQuestionTabTVC = self.storyboard?.instantiateViewController(withIdentifier: "QandAMyQuestionsTVC") as! OFAMyQuestionsTableViewController
        return myQuestionTabTVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.segmentControl.backgroundColor = OFAUtils.getColorFromHexString(barTintColor)
//        self.segmentControl.tintColor = .white
        self.containerView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        segmentControl.initUI()
        segmentControl.selectedSegmentIndex = TabIndex.discussionTab.rawValue
        displayCurrentTab(TabIndex.discussionTab.rawValue)
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.containerView.bounds
            self.containerView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.discussionTab.rawValue :
            vc = discussionTabTVC
        case TabIndex.myQuestionsTab.rawValue :
            vc = myQuestionTabTVC
            
        default:
            return nil
        }
        return vc
    }
    
    //MARK:- Button Actions
    
    @IBAction func segmentControlSelected(_ sender: TabySegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParent()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
}
