//
//  OFADetailedReportViewController.swift
//  Ofabee_OLP
//
//  Created by Administrator on 11/20/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFADetailedReportViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var webViewDetailedReport: UIWebView!
    var webURLString = ""
    var scoreCardTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webViewDetailedReport.loadRequest(URLRequest(url: URL(string: webURLString)!))
        self.webViewDetailedReport.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.scoreCardTitle
    }
    
    //MARK:- UIWebView Delegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
