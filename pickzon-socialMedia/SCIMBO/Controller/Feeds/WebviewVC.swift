//
//  WebviewVC.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/18/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import WebKit

class WebviewVC: UIViewController,WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView:WKWebView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    var urlString:String = String()
    var strTitle:String = String()
    var isFromAvtar = false
    var isHtmlString = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.lblTitle.text = strTitle
        print("urlString == \(urlString)")
        if isFromAvtar == true {
            btnBack.setImage(UIImage(named: "back"), for: .normal)
            btnBack.setImageTintColor(.white)
        }
        
        if isHtmlString {
            self.activityIndicator.startAnimating()
            getGuidelinesApi(strUrl: urlString)
        }else{
            guard let url =  URL(string: urlString.trimmingLeadingAndTrailingSpaces().trim()) else { return }
            webView.load(URLRequest(url: url))
            webView.uiDelegate = self
            webView.navigationDelegate = self;
            webView.contentMode = .scaleAspectFill
            // add activity
            self.webView.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
        }

    
       
    }
    

    @IBAction func backBtnAction(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //MARK: Api Methods
    private   func getGuidelinesApi(strUrl:String){
                
        URLhandler.sharedinstance.makeGetCall(url: strUrl, param: [:]) {(responseObject, error) ->  () in
            
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                _ = result["message"]
                
                if status == 1 {
                    if let payload = result["payload"] as? String {
                        
                        var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
                        headerString.append(payload)
                        
                        self.webView.loadHTMLString("\(headerString)", baseURL: nil)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true

                                        
                    }
                }
            }
        }
    }
    
    //MARK : WEBVIEW DElegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
         activityIndicator.isHidden = false
         activityIndicator.stopAnimating()
     }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            self.webView.load(navigationAction.request)
        }
        return nil
    }
    
    
    func webView(_ webView: WKWebView,
                   decidePolicyFor navigationAction: WKNavigationAction,
                   decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    
        decisionHandler(.allow)
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust  else {
            completionHandler(.useCredential, nil)
            return
        }
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        
    }

   /* func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //  activityIndicator.stopAnimating()
        
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url,
               let host = newURL.host , !host.hasPrefix("www.google.com") &&
                UIApplication.shared.canOpenURL(newURL) &&
                UIApplication.shared.openURL(newURL) {
                print(newURL)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        }
    }

    
    func webView(_ webView: WKWebView,createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?{
            //if <a> tag does not contain attribute or has _blank then navigationAction.targetFrame will return nil
            if let trgFrm = navigationAction.targetFrame {

                if(!trgFrm.isMainFrame){
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self.webView.load(navigationAction.request)
                }
            }



        return nil
    }
    */
    
}
