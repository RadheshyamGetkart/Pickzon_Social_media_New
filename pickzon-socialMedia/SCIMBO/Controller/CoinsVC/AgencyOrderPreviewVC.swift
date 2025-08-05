//
//  AgencyOrderPreviewVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class AgencyOrderPreviewVC: UIViewController {

    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnWhatsApp:UIButton!
    @IBOutlet weak var btnMessage:UIButton!
    @IBOutlet weak var imgVwLogo:UIImageViewX!
    @IBOutlet weak var lblAgencyName:UILabel!
    let titleArray = ["Agency","Coin","Recharge Amount","Agency's Phone Number","Agency's Pickzon Id"]
    var objCoinDetail = CoinDetail(respDict: [:])

    //MARK: UIButton Action Method
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMessage.layer.cornerRadius = 5.0
        btnMessage.clipsToBounds = true
        
        btnWhatsApp.layer.cornerRadius = 5.0
        btnWhatsApp.clipsToBounds = true
        
        
        cnstrntHtNavbar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "TitleDetailTblCell", bundle: nil), forCellReuseIdentifier: "TitleDetailTblCell")
        
        self.lblAgencyName.text =  objCoinDetail.agencyName
        self.imgVwLogo.kf.setImage(with: URL(string: objCoinDetail.profilePic), placeholder: PZImages.avatar, options:  nil, progressBlock: nil) { response in }
    }
    
    //MARK: UIButton Action Method name
    
    @IBAction func backButtonAcion(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func whatsAppButtonAcion(){
            self.openWhatsapp()
    }
    
    
    @IBAction func messageButtonAcion(){
        
        let strMsg = "Hi Agency, I want to purchase pickzon cheer coins. \nPrice: \(objCoinDetail.currencySymbol)\(objCoinDetail.amount) \nCheer Coins (\(objCoinDetail.coin)) \nMy Pickzon Id:- \(Themes.sharedInstance.getPickzonId())"
        let settingsVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
        settingsVC.toChat = objCoinDetail.agencyId
        settingsVC.fromName = objCoinDetail.agencyName
        settingsVC.fullUrl = objCoinDetail.profilePic
        settingsVC.pickzonId = objCoinDetail.pickzonId
        settingsVC.strMsg = strMsg
        self.navigationController?.pushViewController(settingsVC, animated: true)
        
    }
    
    func openWhatsapp() {
        let strMsg = "Hi Agency, I want to purchase pickzon cheer coins. \nPrice: \(objCoinDetail.currencySymbol)\(objCoinDetail.amount) \nCheer Coins (\(objCoinDetail.coin)) \nMy Pickzon Id:- \(Themes.sharedInstance.getPickzonId())"

        
        let appURLString = "https://api.whatsapp.com/send?phone=\(objCoinDetail.businessPhone)&text=\(strMsg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let webURLString = "https://wa.me/\(objCoinDetail.businessPhone)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let appURL = URL(string:appURLString)!
        let webURL = URL(string: webURLString)!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.openURL(appURL)
        } else {
            UIApplication.shared.openURL(webURL)
        }
    }
    

}


extension AgencyOrderPreviewVC: UITableViewDelegate, UITableViewDataSource {
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "TitleDetailTblCell") as! TitleDetailTblCell
        cell.imgVWCoin.isHidden = true
        
        cell.lblTitle.text = titleArray[indexPath.row]
        
        switch indexPath.row{
            
        case 0:
            cell.lblDetail.text = "\(objCoinDetail.agencyName)"
            
            break
        case 1:
            cell.lblDetail.text = "\(objCoinDetail.coin)"
            cell.imgVWCoin.isHidden = false
            break
        case 2:
            cell.lblDetail.text = "\(objCoinDetail.currencySymbol) \(objCoinDetail.amount)"
            break
        case 3:
            cell.lblDetail.text = "\(objCoinDetail.mobileNo)"
            break
        case 4:
            cell.lblDetail.text = "\(objCoinDetail.pickzonId)"
            break
            
        default:
            break
        }
        return cell
    }
}



