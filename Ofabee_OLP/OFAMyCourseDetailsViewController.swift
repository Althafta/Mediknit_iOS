//
//  OFAMyCourseDetailsViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/17/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import FontAwesomeKit_Swift

class OFAMyCourseDetailsViewController: UIViewController {

    enum TabIndex : Int {
        case curriculumTab = 0
        case QandATab = 1
        case ResultsTab = 2
    }
    
    @IBOutlet var segmentControlMyCourse: TabySegmentedControl!
    @IBOutlet var contentView: UIView!
    var courseTitle = ""
    
    var currentViewController: UIViewController?
    lazy var curriculumVC: UIViewController? = {
        let curriculumVC = self.storyboard?.instantiateViewController(withIdentifier: "CurriculumContainerView") as! OFAMyCourseCurriculumListContainerViewController
        return curriculumVC
    }()
    lazy var QandATabTVC : UIViewController? = {
        let QandATabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        
        return QandATabTVC
    }()
    lazy var ResultsTabTVC : UIViewController? = {
        let ResultsTabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseResultsTVC") as! OFAMyCourseDetailsResultsTableViewController
        
        return ResultsTabTVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        segmentControlMyCourse.initUI()
        segmentControlMyCourse.selectedSegmentIndex = TabIndex.curriculumTab.rawValue
        displayCurrentTab(TabIndex.curriculumTab.rawValue)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(awesomeType: FontAwesomeType.fa_ellipsis_v, style: .plain, target: self, action: #selector(self.optionPressed))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.courseTitle
    }
    
    @objc func optionPressed(){
        let optionAction = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionAction.addAction(UIAlertAction(title: "Refer", style: .default, handler: { (action) in
            let contactsList = self.storyboard?.instantiateViewController(withIdentifier: "ContactsTVC") as! OFAContactsTableViewController
            contactsList.isAppShare = false
            contactsList.courseID = COURSE_ID
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(contactsList, animated: true)
        }))
        optionAction.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(optionAction, animated: true, completion: nil)
        
        if !OFAUtils.isiPhone(){
            let popOVer = optionAction.popoverPresentationController
            popOVer?.barButtonItem = self.navigationItem.rightBarButtonItem
//            popOVer?.sourceRect = self.imageViewUser.bounds
//            popOVer?.sourceView = self.imageViewUser
        }
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    @IBAction func segmentControlSelected(_ sender: TabySegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.curriculumTab.rawValue :
            vc = curriculumVC
        case TabIndex.QandATab.rawValue :
            vc = QandATabTVC
        case TabIndex.ResultsTab.rawValue :
            vc = ResultsTabTVC
        default:
            return nil
        }
        return vc
    }

}
