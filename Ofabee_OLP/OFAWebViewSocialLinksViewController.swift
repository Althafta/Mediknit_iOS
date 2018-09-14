//
//  OFAWebViewSocialLinksViewController.swift
//  Life_Line
//
//  Created by Administrator on 7/10/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAWebViewSocialLinksViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    var contentURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.webView.delegate = self
        self.webView.loadRequest(URLRequest(url: URL(string:self.contentURL)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Lifeline"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK:- Webview Delegates
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        OFAUtils.showLoadingViewWithTitle(nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        OFAUtils.removeLoadingView(nil)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        OFAUtils.removeLoadingView(nil)
        OFAUtils.showAlertViewControllerWithTitle(nil, message: error.localizedDescription, cancelButtonTitle: "OK")
    }
}
