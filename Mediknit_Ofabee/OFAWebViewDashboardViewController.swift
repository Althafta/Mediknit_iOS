//
//  OFAWebViewDashboardViewController.swift
//  Mediknit
//
//  Created by Syam PJ on 04/04/19.
//  Copyright © 2019 Administrator. All rights reserved.
//

import UIKit
import WebKit

class OFAWebViewDashboardViewController: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var webViewCourseDetails: WKWebView!
    var urlString = ""
    var titleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        OFAUtils.showLoadingViewWithTitle("Loading")
        self.webViewCourseDetails.navigationDelegate = self
        self.webViewCourseDetails.load(URLRequest(url: URL(string: self.urlString)!))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.titleString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        OFAUtils.removeLoadingView(nil)
    }
    
}
