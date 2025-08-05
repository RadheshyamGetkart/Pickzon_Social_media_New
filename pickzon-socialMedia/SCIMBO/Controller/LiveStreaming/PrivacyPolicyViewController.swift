//
//  PrivacyPolicyViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 5/8/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var webView: WKWebView!
    var strTitle = ""
    var strURl = ""
    @IBOutlet weak var cnstrntHtNavBarVw:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice().hasNotch {
            cnstrntHtNavBarVw.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            cnstrntHtNavBarVw.constant = Constant.sharedinstance.NavigationBarHeight
        }
        lblTitle.text = strTitle
        print(strURl)
        if  let url = URL(string: strURl) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
            // webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
