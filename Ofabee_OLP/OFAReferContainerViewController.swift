//
//  OFAReferContainerViewController.swift
//  Life_Line
//
//  Created by Administrator on 6/27/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAReferContainerViewController: UIViewController {

    enum ReferTabIndex : Int {
        case ReferTab = 0
        case OffersTab = 1
    }
    
    @IBOutlet var segmentControlReferTab: TabySegmentedControl!
    @IBOutlet var contentView: UIView!
    
    var currentViewController: UIViewController?
    lazy var referTVC: UIViewController? = {
        let referVC = self.storyboard?.instantiateViewController(withIdentifier: "ReferAFriendTVC") as! OFAReferAFriendTableViewController
        return referVC
    }()
    lazy var offersTVC : UIViewController? = {
        let offerVC = self.storyboard?.instantiateViewController(withIdentifier: "OffersListTVC") as! OFAOfferListTableViewController
        return offerVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.contentView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
        segmentControlReferTab.initUI()
        segmentControlReferTab.selectedSegmentIndex = ReferTabIndex.ReferTab.rawValue
        displayCurrentTab(ReferTabIndex.ReferTab.rawValue)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
        self.navigationItem.title = ""
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Refer & Earn"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        case ReferTabIndex.ReferTab.rawValue :
            vc = referTVC
        case ReferTabIndex.OffersTab.rawValue :
            vc = offersTVC
        default:
            return nil
        }
        return vc
    }

}
