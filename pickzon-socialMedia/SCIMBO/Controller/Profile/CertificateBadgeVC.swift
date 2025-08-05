//
//  CertificateBadgeVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/30/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class CertificateBadgeVC: UIViewController {

    @IBOutlet weak var imgVwQrCode:UIImageViewX!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnDownload:UIButton!

//MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cnstrntHtNavBar.constant = self.getNavBarHt
        getBadgeCertificateApi()
        btnDownload.setImageTintColor(.blue)
    }
    
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonActionMethod(){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadCertificateButtonActionMethod(){
        
        guard let image = imgVwQrCode.image else { return }

           UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
       }
    
    

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your certificate has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    //MARK: Api methods
    
    func getBadgeCertificateApi() {
        Themes.sharedInstance.activityView(View: self.view)

        let param = NSDictionary()
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.get_badge_cert, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    if  let payload = result.value(forKey: "payload") as? Dictionary<String,Any> {
                       
                        if let badgeCert = payload["badgeCert"] as? String{
                            
                            if let data = NSData(base64Encoded: badgeCert.replacingOccurrences(of: "data:image/jpeg;base64,", with: ""), options: .ignoreUnknownCharacters) {
                                
                                if let decodedimage = UIImage(data: data as Data){
                                    DispatchQueue.main.async {
                                        self.imgVwQrCode.image = decodedimage
                                    }
                                }
                            } else {
                                print("error with decodedData")
                            }
                        
                        }
                    }
                }else{
                    self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }

}
