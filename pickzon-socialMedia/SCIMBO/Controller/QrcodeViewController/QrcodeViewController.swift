//
//  QrcodeViewController.swift
//
//
//  Created by Casp iOS on 06/03/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView

class QrcodeViewController: UIViewController {
    var scanner:QRCode!
    @IBOutlet weak var ScannerView: UIView!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice().hasNotch {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        if !Platform.isSimulator {
            scanner=QRCode()
            scanner.prepareScan(ScannerView) { (SiteCode) in

                if(SocketIOManager.sharedInstance.socket.status == .connected)
                {
                    self.scanApi(qrString: SiteCode)
                 
                }else{
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
        // Do any additional setup after loading the view.
        detailLbl.text="Go to \(webUrl) on your computer and scan the QR code"
    }
    
    func isConnectedToNetwork() -> Bool {
        
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Platform.isSimulator {
            self.scanner.startScan()
        }
    }
    
    @IBAction func DidClickBack(_ sender: Any) {
        self.pop(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.qrResponse), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            let success : Bool = ((notify.object as! [String : Any])["success"] as! NSString).boolValue
            if(success)
            {
                weak.pop(animated: true)
            }
            else
            {
                _ = JSSAlertView().show(weak,title: Themes.sharedInstance.GetAppname(),text: "We could not sign you in to \(Themes.sharedInstance.GetAppname()) Web/Desktop.\n Please try again later." ,buttonText: "OK",color: CustomColor.sharedInstance.themeColor)
                weak.pop(animated: true)
            }
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }
    
    
    func scanApi(qrString:String) {
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        params.setValue("\(Themes.sharedInstance.Getuser_id())", forKey: "userId")
        params.setValue(qrString, forKey: "QRString")
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.authMatchQRImage, param: params, completionHandler: {(responseObject, error) ->  () in
            
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as? String ?? ""
                let message = result["message"] as? String ?? ""
                if errNo == "99"{
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }else{
                    let status = result["status"] as? Int ?? 0
                    if status == 1 {
                        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString , buttonTitles: ["Ok"], onController: self) { (title, index) in
                            
                            if index == 0 {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }else {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
}
