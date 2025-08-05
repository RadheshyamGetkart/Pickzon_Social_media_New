//
//  LiveParticipantTopTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/6/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import FittedSheets


class LiveParticipantTopTblCell: UITableViewHeaderFooterView {

    @IBOutlet weak var cllctionView:UICollectionView!
    var leaderboardArray = [LeaderboardModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctionView.register(UINib(nibName: "LiveLeaderBoardTopCollectionCell", bundle: nil), forCellWithReuseIdentifier: "LiveLeaderBoardTopCollectionCell")
        cllctionView.delegate = self
        cllctionView.dataSource = self
        cllctionView.layer.cornerRadius = 10.0
        cllctionView.clipsToBounds = true
        if Themes.sharedInstance.liveLeaderboardKeyPoints.count == 0{
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
                        Themes.sharedInstance.liveLeaderboardKeyPoints = payloadDict["liveLeaderboardKeyPoints"] as? Array<String> ?? []
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

extension LiveParticipantTopTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(self.frame.size.width, 240)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveLeaderBoardTopCollectionCell", for: indexPath) as! LiveLeaderBoardTopCollectionCell
        
        cell.btnGiftCoinFirst.isHidden = true
        cell.btnGiftCoinSecond.isHidden = true
        cell.btnGiftCoinThird.isHidden = true
        
        if let firstTopper = leaderboardArray.first{
       
            cell.viewProfileFirstPosition.setImgView(profilePic: firstTopper.profilePic, remoteSVGAUrl: firstTopper.avatarSVGA,changeValue: 12)
            cell.lblFirstPerson.text = "@\(firstTopper.pickzonId)"
            cell.lblGiverFirstPerson.text = "@\(firstTopper.gifterPickzonId)"
            cell.btnGiftCoinFirst.setTitle("\(firstTopper.totalCoins)", for: .normal)
            cell.imgVwGiverFirstPersonView.setImgView(profilePic: firstTopper.gifterImage, frameImg: firstTopper.gifterAvatar,changeValue:2)
            cell.btnGiftCoinFirst.isHidden = false

        }
        
        cell.bgImgView.layer.cornerRadius = 10.0
        cell.bgImgView.clipsToBounds = true
        cell.btnProfileFirstPosition.contentMode = .scaleAspectFill
        cell.btnProfileSecondPosition.contentMode = .scaleAspectFill
        cell.btnProfileThirdPosition.contentMode = .scaleAspectFill

        if  leaderboardArray.count > 1 {
          
            cell.viewProfileSecondPosition.setImgView(profilePic: leaderboardArray[1].profilePic, remoteSVGAUrl: leaderboardArray[1].avatarSVGA,changeValue: 12)
            cell.lblSecondPerson.text = "@\(leaderboardArray[1].pickzonId)"
            cell.lblGiverSecondPerson.text = "@\(leaderboardArray[1].gifterPickzonId)"
            cell.btnGiftCoinSecond.setTitle("\(leaderboardArray[1].totalCoins)", for: .normal)
            cell.imgVwGiverSecondPersonView.setImgView(profilePic: leaderboardArray[1].gifterImage, frameImg: leaderboardArray[1].gifterAvatar,changeValue:2)
            cell.btnProfileSecondPosition.isHidden = false
            cell.viewProfileSecondPosition.isHidden = false
            cell.lblSecondPerson.isHidden = false
            cell.imgVwGiverSecondPersonView.isHidden = false
            cell.lblGiverSecondPerson.isHidden = false
            cell.btnGiftCoinSecond.isHidden = false
            
        }else{
            
            cell.btnProfileSecondPosition.isHidden = true
            cell.viewProfileSecondPosition.isHidden = true
            cell.lblSecondPerson.isHidden = true
            cell.imgVwGiverSecondPersonView.isHidden = true
            cell.lblGiverSecondPerson.isHidden = true
            cell.btnGiftCoinSecond.setTitle("", for: .normal)
        }
        
        if  leaderboardArray.count > 2 {
            
            cell.viewProfileThirdPosition.setImgView(profilePic: leaderboardArray[2].profilePic, remoteSVGAUrl: leaderboardArray[2].avatarSVGA,changeValue: 12)
            cell.lblThirdPerson.text = "@\(leaderboardArray[2].pickzonId)"
            cell.btnGiftCoinThird.setTitle("\(leaderboardArray[2].totalCoins)", for: .normal)
            cell.lblGiverThirdPerson.text = "@\(leaderboardArray[2].gifterPickzonId)"
            cell.imgVwGiverThirdPersonView.setImgView(profilePic: leaderboardArray[2].gifterImage, frameImg: leaderboardArray[2].gifterAvatar,changeValue:2)
            cell.btnProfileThirdPosition.isHidden = false
            cell.viewProfileThirdPosition.isHidden = false
            cell.lblThirdPerson.isHidden = false
            cell.lblGiverThirdPerson.isHidden = false
            cell.imgVwGiverThirdPersonView.isHidden = false
            cell.btnGiftCoinThird.isHidden = false
            
        }else{
            cell.btnProfileThirdPosition.isHidden = true
            cell.viewProfileThirdPosition.isHidden = true
            cell.lblThirdPerson.isHidden = true
            cell.lblGiverThirdPerson.isHidden = true
            cell.imgVwGiverThirdPersonView.isHidden = true
            cell.btnGiftCoinThird.setTitle("", for: .normal)
        }
        
        cell.btnProfileFirstPosition.addTarget(self, action: #selector(firstImageBtnAction), for: .touchUpInside)
        cell.btnProfileSecondPosition.addTarget(self, action: #selector(secondImageBtnAction), for: .touchUpInside)
        cell.btnProfileThirdPosition.addTarget(self, action: #selector(thirdImageBtnAction), for: .touchUpInside)
        cell.btnGiverFirstPerson.addTarget(self, action: #selector(firstGiverBtnAction), for: .touchUpInside)
        cell.btnGiverSecondPerson.addTarget(self, action: #selector(secondGiverBtnAction), for: .touchUpInside)
        cell.btnGiverThirdPerson.addTarget(self, action: #selector(thirdGierBtnAction), for: .touchUpInside)
        cell.btnInfo.addTarget(self, action: #selector(infoBtnAction), for: .touchUpInside)
        
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
            controller.leaderboardType = .liveLeaderboard
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
