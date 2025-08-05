//
//  ShareProfileVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/15/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ShareProfileVC: UIViewController {
    
    var scanner:QRCode!
    @IBOutlet weak var bgViewScanneer: UIView!
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var bgViewQrCode:UIViewX!
    @IBOutlet weak var bgSubViewQrCode:UIViewX!
    @IBOutlet weak var imgVwQrCode:UIImageViewX!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblNavTitle:UILabel!
    @IBOutlet weak var lblPickzonId:UILabel!
    var pickzonId = ""
    var userId = ""

    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bgViewScanneer.isHidden = true
        cnstrntHtNavBar.constant = self.getNavBarHt
        addBorderColor()
        
        self.lblPickzonId.text = "@" + pickzonId
        
        //getQrCodeApi()
        //scanQRCode()
        self.cameraAllowsAccessToApplicationCheck()
        
    }
    
    func cameraAllowsAccessToApplicationCheck(){
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { (granted:Bool) -> Void in
                if granted {
                    print("access granted", terminator: "")
                    DispatchQueue.main.async {
                        self.getQrCodeApi()
                        self.scanQRCode()
                    }
                }else {
                    print("access denied", terminator: "")
                }
            })
        case .authorized:
            print("Access authorized", terminator: "")
            DispatchQueue.main.async {
                self.getQrCodeApi()
                self.scanQRCode()
            }
            
        case .denied, .restricted:
            alertToEncourageCameraAccessWhenApplicationStarts()
            
            break
        default:
            print("DO NOTHING", terminator: "")
        }
    }
    
    
    
    
    
    
    func alertToEncourageCameraAccessWhenApplicationStarts(){
        
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable camera", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
            
            if index == 0{
                return
            }else{
                let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url as URL)
                    }
                    
                }
            }
        }
    }
    func addBorderColor(){
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors =  [Themes.sharedInstance.colorWithHexString(hex: "#307CF6").cgColor, Themes.sharedInstance.colorWithHexString(hex: "#193D9A").cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bgViewQrCode.bounds
        self.bgViewQrCode.layer.insertSublayer(gradientLayer, at:0)
        self.bgViewQrCode.layer.cornerRadius = 25.0
        self.bgViewQrCode.clipsToBounds = true
        self.bgSubViewQrCode.layer.cornerRadius = 25.0
        self.bgSubViewQrCode.clipsToBounds = true
    }
    
    
    func scanQRCode(){
        if !Platform.isSimulator {
            scanner=QRCode()
            scanner.prepareScan(scannerView) { (SiteCode) in
                print("SiteCodeSiteCodeSiteCodeSiteCode=\(SiteCode)")
                
                if let userId = SiteCode.components(separatedBy: "/").last {
                    if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                        viewController.otherMsIsdn = userId
                        self.navigationController?.pushView(viewController, animated: true)
                        self.bgViewScanneer.isHidden = true
                        self.scanner.stopScan()
                    }
                }
            }
        }
    }
    
    
    //MARK: UIBUtton Action Methods
    @IBAction func closeCameraButtonAction(sender:UIButton){
        bgViewScanneer.isHidden = true
        self.scanner.stopScan()
    }
    
    @IBAction func scanButtonAction(sender:UIButton){
        bgViewScanneer.isHidden = false
        if !Platform.isSimulator {
            self.scanner.startScan()
        }
    }
    
    @IBAction func backButtonAction(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func copyLinkButtonAction(sender:UIButton){
        let baseUrl = "https://www.pickzon.com/profile/\(userId)"
        UIPasteboard.general.string = baseUrl
        self.view.makeToast(message: "Copied successfully" , duration: 3, position: HRToastActivityPositionDefault)
    }
    
    @IBAction func shareLinkButtonAction(sender:UIButton){
        ShareMedia.shareMediafrom(type: .profile, mediaId: userId, controller: self)
    }
    
    //MARK: Api methods
    
    func getQrCodeApi(){
        
        let params = NSMutableDictionary()
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.generateUserProfileQrImage, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    if let  payloadDict = result["payload"] as? NSDictionary {
                        
                        if let base64String = payloadDict["qrUrl"] as? String {
                            
                            if let data = NSData(base64Encoded: base64String.replacingOccurrences(of: "data:image/png;base64,", with: ""), options: .ignoreUnknownCharacters) {
                                
                                if let decodedimage = UIImage(data: data as Data){
                                    DispatchQueue.main.async {
                                        self.imgVwQrCode.image = decodedimage
                                    }
                                }
                            } else {
                                print("error with decodedData")
                            }
                        } else {
                            print("error with base64String")
                        }
                        
                    }
                }else{
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
}
