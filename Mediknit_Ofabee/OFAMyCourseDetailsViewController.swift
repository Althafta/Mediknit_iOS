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
        case DiscussionTab = 1
    }
    
    @IBOutlet weak var viewPromo: UIView!
    @IBOutlet weak var imageViewPromo: UIImageView!
    @IBOutlet weak var buttonPromoPlay: UIButton!
    
    @IBOutlet var segmentControlMyCourse: TabySegmentedControl!
    @IBOutlet var contentView: UIView!
    var courseTitle = ""
    var promoImageURLString = ""
    
    var currentViewController: UIViewController?
    lazy var curriculumVC: UIViewController? = {
        let curriculumVC = self.storyboard?.instantiateViewController(withIdentifier: "CurriculumContainerView") as! OFAMyCourseCurriculumListContainerViewController
        return curriculumVC
    }()
    lazy var DiscussionTabTVC : UIViewController? = {
        let DiscussionTabTVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCourseQandATVC") as! OFAMyCourseDetailsQandATableViewController
        
        return DiscussionTabTVC
    }()
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageViewPromo.sd_setImage(with: URL(string: self.promoImageURLString)!, placeholderImage: UIImage(named: "AppLogo_horizontal"), options: .progressiveDownload)
        self.buttonPromoPlay.isHidden = true
        self.contentView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        segmentControlMyCourse.initUI()
        segmentControlMyCourse.selectedSegmentIndex = TabIndex.curriculumTab.rawValue
        displayCurrentTab(TabIndex.curriculumTab.rawValue)
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
    
    //MARK:- Button Actions
    
    @IBAction func promoPlayPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func segmentControlSelected(_ sender: TabySegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParent()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    //MARK:- Content view helpers
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.curriculumTab.rawValue :
            vc = curriculumVC
        case TabIndex.DiscussionTab.rawValue :
            vc = DiscussionTabTVC
        
        default:
            return nil
        }
        return vc
    }

}
