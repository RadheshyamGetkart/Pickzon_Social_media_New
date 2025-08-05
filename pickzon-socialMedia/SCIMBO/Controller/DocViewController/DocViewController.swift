//
//  DocViewController.swift
//
//
//  Created by MV Anand Casp iOS on 10/07/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import WebKit
class DocViewController: UIViewController {
    var webkitURL:String = String()
    var webkitTitle:String = String()
    
    @IBOutlet weak var webkit: WKWebView!
    @IBOutlet weak var doc_nameLbl: CustomLblFont!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        doc_nameLbl.text = webkitTitle
        let myURL = URL(string: webkitURL)
        let myRequest = URLRequest(url: myURL!)
        webkit.load(myRequest)
//        let targetURL:URL = URL(fileURLWithPath: webkitURL)
//        let request = NSURLRequest(url: targetURL)
//        webkit.load(request as URLRequest)
        // Do any additional setup after loading the view.
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didclickBackBtn(_ sender: Any) {
        self.pop(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

