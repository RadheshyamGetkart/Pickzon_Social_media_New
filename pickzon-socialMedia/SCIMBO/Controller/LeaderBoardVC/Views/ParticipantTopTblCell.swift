//
//  ParticipantTopTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/5/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import FittedSheets

class ParticipantTopTblCell: UITableViewHeaderFooterView {

    @IBOutlet weak var cllctionView:UICollectionView!
    var leaderboardArray = [LeaderboardModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctionView.register(UINib(nibName: "LeaderBoardTopCollectionCell", bundle: nil), forCellWithReuseIdentifier: "LeaderBoardTopCollectionCell")
        cllctionView.delegate = self
        cllctionView.dataSource = self
        cllctionView.layer.cornerRadius = 10.0
        cllctionView.clipsToBounds = true
        if Themes.sharedInstance.leaderboardKeyPoints.count == 0{
            getPremiumBenefitsApi()
        }
    }
    
 private   func getPremiumBenefitsApi(){

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.premiumBenefits, param: [:]) {(responseObject, error) ->  () in
           

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                _ = result["message"]

                if status == 1 {
                    if let payloadDict = result["payload"] as? NSDictionary {
                        Themes.sharedInstance.leaderboardKeyPoints = payloadDict["leaderboardKeyPoints"] as? Array<String> ?? []
//                        self.premiumKeyPoints = payloadDict["premiumKeyPoints"] as? Array<String> ?? []
//                        self.monetizingKeyPoints = payloadDict["monetizingKeyPoints"] as? Array<String> ?? []
//                        self.tblView.reloadData()
                    }
                        
                }
            }
        }
    }
}


//MARK: - UICollectionview delegate and datasource

extension ParticipantTopTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let firstTopper = leaderboardArray.first{
            
            if (firstTopper.gifterPickzonId.count == 0) {
                return CGSizeMake(self.frame.size.width, 210)
            }
        }
        
        return CGSizeMake(self.frame.size.width, 240)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderBoardTopCollectionCell", for: indexPath) as! LeaderBoardTopCollectionCell
        
        cell.bgVwGiverFirstPerson.isHidden = true
        cell.bgVwGiverSecondPerson.isHidden = true
        cell.bgVwGiverThirdPerson.isHidden = true
        cell.cnstrntBottomCenterGifter.constant = 0
        
        if let firstTopper = leaderboardArray.first{
        
            cell.imgProfileFirstPosition.setImgView(profilePic: firstTopper.profilePic, remoteSVGAUrl:  firstTopper.avatarSVGA,changeValue: 12)
            cell.lblFirstPerson.text = "@\(firstTopper.pickzonId)"
            cell.lblGiverFirstPerson.text = "@\(firstTopper.gifterPickzonId)"
            cell.btnGiftCoinFirst.setTitle(firstTopper.totalViews, for: .normal)
            cell.btnGiftCoinFirst.setImage(PZImages.viewIcon, for: .normal)
            cell.btnGiftCoinFirst.setImageTintColor(.white)
            cell.imgVwGiverFirstPerson.kf.setImage(with: URL(string: firstTopper.gifterImage), placeholder: PZImages.avatar, options: nil, progressBlock: nil, completionHandler: { (resp) in
            })
            cell.bgVwGiverFirstPerson.isHidden =  (leaderboardArray[0].gifterPickzonId.count > 0) ? false : true
            cell.cnstrntBottomCenterGifter.constant = (leaderboardArray[0].gifterPickzonId.count > 0) ? 20 : 0
        }

        cell.bgImgView.addShadowToView(corner: 10.0, shadowColor: .lightGray, shadowRadius: 1, shadowOpacity: 0.5)

        
        if  leaderboardArray.count > 1 {
          
            cell.imgProfileSecondPosition.setImgView(profilePic: leaderboardArray[1].profilePic, remoteSVGAUrl:  leaderboardArray[1].avatarSVGA,changeValue: 12)
            cell.lblSecondPerson.text = "@\(leaderboardArray[1].pickzonId)"
            cell.lblGiverSecondPerson.text = "@\(leaderboardArray[1].gifterPickzonId)"
            cell.btnGiftCoinSecond.setTitle(leaderboardArray[1].totalViews, for: .normal)
            cell.btnGiftCoinSecond.setImage(PZImages.viewIcon, for: .normal)
            cell.btnGiftCoinSecond.setImageTintColor(.white)
            cell.imgVwGiverSecondPerson.kf.setImage(with: URL(string: leaderboardArray[1].gifterImage), placeholder: PZImages.avatar, options: nil, progressBlock: nil, completionHandler: { (resp) in
            })
            cell.btnProfileSecondPosition.isHidden = false
            cell.imgProfileSecondPosition.isHidden = false
            cell.lblSecondPerson.isHidden = false
            cell.imgVwGiverSecondPerson.isHidden = false
            cell.lblGiverSecondPerson.isHidden = false
            cell.bgVwGiverSecondPerson.isHidden =  (leaderboardArray[1].gifterPickzonId.count > 0) ? false : true
       
        }else{
            
            cell.btnProfileSecondPosition.isHidden = true
            cell.imgProfileSecondPosition.isHidden = true
            cell.lblSecondPerson.isHidden = true
            cell.imgVwGiverSecondPerson.isHidden = true
            cell.lblGiverSecondPerson.isHidden = true
            cell.btnGiftCoinSecond.setTitle("", for: .normal)
        }
        
        if  leaderboardArray.count > 2 {
            
            cell.imgProfileThirdPosition.setImgView(profilePic: leaderboardArray[2].profilePic, remoteSVGAUrl:  leaderboardArray[2].avatarSVGA,changeValue: 12)
            cell.lblThirdPerson.text = "@\(leaderboardArray[2].pickzonId)"
            cell.btnGiftCoinThird.setTitle(leaderboardArray[2].totalViews, for: .normal)
            cell.btnGiftCoinThird.setImage(PZImages.viewIcon, for: .normal)
            cell.btnGiftCoinThird.setImageTintColor(.white)
            cell.lblGiverThirdPerson.text = "@\(leaderboardArray[2].gifterPickzonId)"
            cell.imgVwGiverThirdPerson.kf.setImage(with: URL(string: leaderboardArray[2].gifterImage), placeholder: PZImages.avatar, options: nil, progressBlock: nil, completionHandler: { (resp) in
            })
            cell.btnProfileThirdPosition.isHidden = false
            cell.imgProfileThirdPosition.isHidden = false
            cell.lblThirdPerson.isHidden = false
            cell.lblGiverThirdPerson.isHidden = false
            cell.imgVwGiverThirdPerson.isHidden = false
            cell.bgVwGiverThirdPerson.isHidden =  (leaderboardArray[2].gifterPickzonId.count > 0) ? false : true

        }else{
            cell.btnProfileThirdPosition.isHidden = true
            cell.imgProfileThirdPosition.isHidden = true
            cell.lblThirdPerson.isHidden = true
            cell.lblGiverThirdPerson.isHidden = true
            cell.imgVwGiverThirdPerson.isHidden = true
            cell.btnGiftCoinThird.setTitle("", for: .normal)
        }
        
        cell.btnProfileFirstPosition.addTarget(self, action: #selector(firstImageBtnAction), for: .touchUpInside)
        cell.btnProfileSecondPosition.addTarget(self, action: #selector(secondImageBtnAction), for: .touchUpInside)
        cell.btnProfileThirdPosition.addTarget(self, action: #selector(thirdImageBtnAction), for: .touchUpInside)
        cell.btnGiverFirstPerson.addTarget(self, action: #selector(firstGiverBtnAction), for: .touchUpInside)
        cell.btnGiverSecondPerson.addTarget(self, action: #selector(secondGiverBtnAction), for: .touchUpInside)
        cell.btnGiverThirdPerson.addTarget(self, action: #selector(thirdGierBtnAction), for: .touchUpInside)
        cell.btnInfo.addTarget(self, action: #selector(infoBtnAction), for: .touchUpInside)
        cell.btnTopOuterClick.isHidden = true
        
        return cell
    }
    
    //Mark: Selector Methods
    @objc func firstImageBtnAction(){
        if leaderboardArray.count > 0{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[0].userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    @objc func secondImageBtnAction(){
        if leaderboardArray.count > 1{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[1].userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @objc func thirdImageBtnAction(){
        
        if leaderboardArray.count > 2{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[2].userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @objc func firstGiverBtnAction(){
        if leaderboardArray.count > 0{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[0].gifterUserId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
        
    }
    
    @objc func secondGiverBtnAction(){
        if leaderboardArray.count > 1{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[1].gifterUserId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @objc func thirdGierBtnAction(){
        if leaderboardArray.count > 2{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[2].gifterUserId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @objc func infoBtnAction(){
        
        if #available(iOS 13.0, *) {
            let controller = StoryBoard.premium.instantiateViewController(identifier: "DescriptionPointsVC")
            as! DescriptionPointsVC
            controller.leaderboardType = .leaderboard
            let useInlineMode = view != nil
            controller.title = ""
            let nav = UINavigationController(rootViewController: controller)
            //            var fixedSize = 500
            //            if UIDevice().hasNotch{
            //                fixedSize = 480
            //            }
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.75),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            // addSheetEventLogging(to: sheet)
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20
            
            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
            
        } else {
            // Fallback on earlier versions
        }
    }

}
