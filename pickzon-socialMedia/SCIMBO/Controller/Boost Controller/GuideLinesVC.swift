//
//  GuideLinesVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/12/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import WebKit


enum GuidelinesType{
    
    case boost
    case professionalDashboard
    case weeklyGuidelines
    
}

class GuideLinesVC: UIViewController {
    
    var guidelinesType:GuidelinesType?
    var isHtmlText = ""
    @IBOutlet weak var webview:WKWebView!

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let navLabel = UILabel()
        
        var strNavTitle = ""
        if isHtmlText.length > 0 {
            
            strNavTitle = "Guidelines"
            var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
            headerString.append(isHtmlText)
            self.webview.loadHTMLString("\(headerString)", baseURL: nil)
            
        }else{
            
            if guidelinesType == .boost{
                strNavTitle = "Choose a boost pack"
                getGuidelinesApi(strUrl: Constant.sharedinstance.guidelines_boost)
                
            }else  if guidelinesType == .professionalDashboard{
                strNavTitle = "Guidelines"
                getGuidelinesApi(strUrl: Constant.sharedinstance.guidelines_professionalDashboard)
            }else  if guidelinesType == .weeklyGuidelines{
                strNavTitle = "Guidelines"
                getGuidelinesApi(strUrl: Constant.sharedinstance.guidelines_weeklyLeaderboard)
            }
        }
        
        
        
        let navTitle = NSMutableAttributedString(string: strNavTitle, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.label
            ,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.medium)])
        navLabel.backgroundColor = .clear
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel

        addBackButton()
        self.webview.isOpaque = false
        self.webview.backgroundColor = UIColor.white
        self.webview.scrollView.backgroundColor = UIColor.white
        
        
    }
    
    
    //MARK: UIBUtton Action Methods
    func addBackButton(){
        let someButton = UIButton(frame: CGRect(x: 0, y: 5, width: 40, height: 40))
        someButton.setImage(UIImage(named: "crossIcon"), for: .normal)
        someButton.setImageTintColor(.label)
        someButton.addTarget(self, action: #selector(backBtnAction1(_ : )), for: .touchUpInside)
        someButton.showsTouchWhenHighlighted = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: someButton)
    }
    
    @IBAction func backBtnAction1(_ sender: UIButton) {
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
                    
                    var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
                    
                    if let payload = result["payload"] as? String {
                     
                        headerString.append(payload)
                        
                    }
                        self.webview.loadHTMLString("\(headerString)", baseURL: nil)
                                        
                    }
                }
            }
        }
}



extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
