//
//  AgencyListViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/24/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyListViewController: UIViewController {
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    
    var arrAgencyList:Array<AgencyDetailModel> = Array()
    
    var objConiSelected :CoinOfferModel = CoinOfferModel(respDict: [:])
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "packageCell", bundle: nil), forCellReuseIdentifier: "packageCell")
        tblView.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")
        
        
        tblView.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowingTableViewCell")
        tblView.separatorColor = UIColor.clear
        tblView.isHidden = true
        
        self.getAgencyList()
    }
    
    func getAgencyList(){
        Themes.sharedInstance.activityView(View: self.view)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.agencyListURL, param: [:]) {(responseObject, error) ->  () in
           
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 1 {
                    let payload = result["payload"] as? Array<Dictionary<String,Any>> ?? []
                    for dict in payload {
                        self.arrAgencyList.append(AgencyDetailModel(respDict: dict as NSDictionary))
                    }
                    self.tblView.reloadData()
                    self.tblView.isHidden = false
                        
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    @IBAction func backButonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){

 //   @objc func openProfileUser(sender:UIButton){
        let obj = arrAgencyList[(sender?.view?.tag ?? 0)-1]
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  obj.id
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
//    @objc func openProfileUser(sender:UIButton){
//        let obj = arrAgencyList[sender.tag - 1]
//        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//        profileVC.otherMsIsdn =  obj.id
//        self.navigationController?.pushViewController(profileVC, animated: true)
//    }
    @objc func confirmAgencyAction(sender:UIButton){
        
        let obj = arrAgencyList[sender.tag - 1]
        let vc:AgencyOrderViewController = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyOrderViewController") as! AgencyOrderViewController
        vc.objAgencyDetail = obj
        vc.objConiSelected = self.objConiSelected
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension AgencyListViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else {
            return arrAgencyList.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 30
//        }else if indexPath.section == 0 {
//            return 50
//        }
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tblView.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
            var title = "Choose Package"
            if indexPath.section == 0 {
                title = "Choose Package"
            }else {
                title = "Choose Agency"
            }
            cell.btnCheck.isHidden = false
            cell.lblTitle.isHidden =  true
            cell.btnCheck.setImage(nil, for: .normal)
            cell.btnCheck.setTitle(title, for: .normal)
            cell.btnCheck.contentHorizontalAlignment = .left
            
            return cell
        }else  if indexPath.section == 0 {
            
                let cell = tblView.dequeueReusableCell(withIdentifier: "packageCell") as! packageCell
                cell.lblCoinCount.text = "\(objConiSelected.coins)"
                cell.lblPrice.text = "Price \(objConiSelected.currencySymbol)\(objConiSelected.amount)"
                cell.selectionStyle = .none
                return cell
            
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell") as! FollowingTableViewCell
                let obj = arrAgencyList[indexPath.row - 1]
            
            cell.profilePicView.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar)

            
           /* cell.imgUser.kf.setImage(with: URL(string: obj.profilePic), placeholder: PZImages.avatar, options:  nil, progressBlock: nil) { response in }*/
                
                cell.lblName.text =   obj.pickzonId
                cell.lblPhone.text =  "Payment Options: \(obj.paymentOptions) \nCountry:\(obj.country)"
                
                cell.btnUnfollow.isHidden = false
                cell.btnUnfollow.setTitle("Confirm", for: .normal)
                cell.btnUnfollow.tag = indexPath.row
                 cell.btnUnfollow.addTarget(self, action: #selector(confirmAgencyAction(sender:)) , for: .touchUpInside)
            
            cell.profilePicView.imgVwProfile?.tag = indexPath.row
            cell.profilePicView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action:#selector(self.handleProfilePicTap(_:))))
                
//                cell.btnProfile.tag = indexPath.row
//                cell.btnProfile.addTarget(self, action: #selector(openProfileUser(sender:)), for: .touchUpInside)
                
                /*
                 cell.lblName.tag = indexPath.row
                 cell.btnUnfollow.isHidden = false
                 cell.btnUnfollow.setTitle(obj.follow_status_button.capitalized, for: .normal)
                 cell.btnUnfollow.tag = indexPath.row
                 cell.btnUnfollow.addTarget(self, action: #selector(followBtn(sender:)) , for: .touchUpInside)
                 cell.btnProfile.tag = indexPath.row
                 cell.btnProfile.addTarget(self, action: #selector(openProfileUser(sender:)), for: .touchUpInside)
                 
                 cell.imgVwCelebrity.isHidden = true
                 if obj.celebrity == 1{
                 cell.imgVwCelebrity.isHidden = false
                 cell.imgVwCelebrity.image = PZImages.greenVerification
                 }else if obj.celebrity == 4{
                 cell.imgVwCelebrity.isHidden = false
                 cell.imgVwCelebrity.image = PZImages.goldVerification
                 }else if obj.celebrity == 5{
                 cell.imgVwCelebrity.isHidden = false
                 cell.imgVwCelebrity.image = PZImages.blueVerification
                 }
                 
                 if obj.id  as? String ?? "" == Themes.sharedInstance.Getuser_id() || userType == .comonFriends{
                 cell.btnUnfollow.isHidden = true
                 }
                 */
                return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


