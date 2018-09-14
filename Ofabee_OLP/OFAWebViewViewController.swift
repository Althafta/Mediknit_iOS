//
//  OFAWebViewViewController.swift
//  Life_Line
//
//  Created by Administrator on 6/29/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAWebViewViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    var isFromHome = false
    var contentURL = ""
    var pageHeading = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self
        if !isFromHome{
            self.setNavigationBarItem(isSidemenuEnabled: true)
            self.webView.loadRequest(URLRequest(url: URL(string: "http://lifelinemcs.org/store/?v=c86ee0d9d7ed")!))
        }else{
            self.webView.loadRequest(URLRequest(url: URL(string: self.contentURL)!))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = !isFromHome ? "Store" : self.pageHeading
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
