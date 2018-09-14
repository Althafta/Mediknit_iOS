//
//  OFAWebViewBlogViewController.swift
//  Life_Line
//
//  Created by Administrator on 7/5/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAWebViewBlogViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem(isSidemenuEnabled: true)
        self.webView.delegate = self
        self.webView.loadRequest(URLRequest(url: URL(string: "http://www.lifelinemcs.org/blog/?v=c86ee0d9d7ed")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Blog"
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
