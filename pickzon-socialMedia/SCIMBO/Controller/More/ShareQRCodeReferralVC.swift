//
//  ShareQRCodeReferralVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/10/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ShareQRCodeReferralVC: UIViewController {
    
    @IBOutlet weak var bgSubViewQrCode:UIViewX!
    @IBOutlet weak var bgViewQrCode:UIViewX!
    @IBOutlet weak var imgVwQrCode:UIImageViewX!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblNavTitle:UILabel!
    @IBOutlet weak var bgViewReferlCode: UIView!
    @IBOutlet weak var btnCopyReferral: UIButton!
    @IBOutlet weak var lblReferralCode:UILabel!

    var referralCode = ""
    var userId = ""

    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        bgViewReferlCode.addDashBorder(color: UIColor.black)
        self.lblReferralCode.text = referralCode
        getQrCodeApi()
        addBorderColor()
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
    
    
    //MARK: UIBUtton Action Methods
 
    @IBAction func backButtonAction(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    

    
    @IBAction func shareLinkButtonAction(sender:UIButton){
        
        // let appStoreLink = "Use this code during signup (Referal Code: \(strReferralCode)) to claim your bonus instantly.\nDownload PickZon app & stay entertained! \nhttps://www.pickzon.com/apps"
        
        if let img = self.imgVwQrCode.image {

        let activityVC = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        activityVC.setValue("PickZon App", forKey: "subject")
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if success == true {
                print("Success")
            }else {
                print("fail")
            }
        }
        //New Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }
    }
    
    
    @IBAction func downloadButtonAction(sender:UIButton){
      
        if let img = self.imgVwQrCode.image {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: img)
        }
    }
    
    
    @IBAction func copyReferalCodebTnAction(_ sender: UIButton) {
        UIPasteboard.general.string = referralCode
        self.view.makeToast(message: "Referal Code: \(referralCode) has been copied to clipboard.", duration: 3, position: HRToastActivityPositionDefault)
    }
    
    //MARK: Api methods
    
    func getQrCodeApi(){
        
        let params = NSMutableDictionary()
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let url = Constant.sharedinstance.get_user_referral_qr_image + "?referralCode=\(referralCode)"
        URLhandler.sharedinstance.makeGetCall(url:url, param: params, completionHandler: {(responseObject, error) ->  () in
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




class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            AppDelegate.sharedInstance.navigationController?.view.makeToast(message: "Download successfully!" , duration: 3, position: HRToastActivityPositionDefault)

        }
    }
}
