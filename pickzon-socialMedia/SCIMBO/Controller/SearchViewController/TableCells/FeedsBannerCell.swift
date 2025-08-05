//
//  FeedsBannerCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/6/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class FeedsBannerCell: UITableViewCell {
    
    @IBOutlet weak var cllctnViewBanner: UICollectionView!
    @IBOutlet weak var pagerView: UIPageControl!
    @IBOutlet weak var cnstrntHtCllctnVw: NSLayoutConstraint!
    var bannerArray =  [BannerModel]()
    var begin = false
    var timer:Timer? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctnViewBanner.register(UINib(nibName: "BannerCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionCell")
        self.pagerView.addTarget(self, action: #selector(pageControltapped(_:)), for: .valueChanged)
        pagerView.transform = CGAffineTransformMakeScale(0.7, 0.7);

        // startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = nil
        if bannerArray.count > 1{
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func scrollToNextCell(){
        
        //get cell size
        let cellSize = CGSizeMake(self.view.frame.width, self.view.frame.height);
        
        //get current content Offset of the Collection view
        let contentOffset = cllctnViewBanner.contentOffset;
        //scroll to next cell
        if begin == true{
            pagerView.currentPage = 0
            cllctnViewBanner.scrollRectToVisible(CGRectZero, animated: true)
            begin = false
        }else{
            cllctnViewBanner.scrollRectToVisible(CGRectMake(contentOffset.x + cellSize.width, contentOffset.y, cellSize.width, cellSize.height), animated: true);
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension FeedsBannerCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @objc func pageControltapped(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }
        self.cllctnViewBanner.scrollToItem(at:  IndexPath(row: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    //MARK: UICollection View Delegate & Datasource methods
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pagerView.numberOfPages = bannerArray.count
        return bannerArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cllctnViewBanner.frame.size.width, height: self.cllctnViewBanner.frame.size.height )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*
         Blue V certificate - (type =5)
         Avatar frame - (type =6)
         Entry Effect - (type =7)
         Cheer coins buy - (type =8)
         User post list for boost - (type =9)
         */
        
        if  bannerArray[indexPath.row].isLeaderboard == 1 {
            
            //LeaderboardGift
            let destVC = StoryBoard.premium.instantiateViewController(withIdentifier: "LeaderboardGiftVC") as! LeaderboardGiftVC
            destVC.titleStr = bannerArray[indexPath.row].title
            destVC.bannerType = bannerArray[indexPath.row].type
            (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
            
        }else{
            
            if  bannerArray[indexPath.row].type == 0 {
                
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                vc.urlString = bannerArray[indexPath.row].bannerLink
                vc.strTitle = bannerArray[indexPath.row].title
                AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                
            }else if  bannerArray[indexPath.row].type == 1 {
                
                guard let url = URL(string: bannerArray[indexPath.row].bannerLink) else { return }
                UIApplication.shared.open(url)
                
            }else if  bannerArray[indexPath.row].type == 2 {
                
                let destVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "AgencyPkVC") as! AgencyPkVC
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
                
            }else if  bannerArray[indexPath.row].type == 4 {
                
                let destVC = StoryBoard.premium.instantiateViewController(withIdentifier: "ParticipateEventsVC") as! ParticipateEventsVC
                destVC.strTitle = bannerArray[indexPath.row].title
                destVC.banner = bannerArray[indexPath.row].imageCdn
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
                
            }else if  bannerArray[indexPath.row].type == 5 {
                
                if let certificateBadgeVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "CertificateBadgeVC") as? CertificateBadgeVC{
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(certificateBadgeVC, animated: true)
                }
            }else if  bannerArray[indexPath.row].type == 6 {
                
                
                let destVC =  StoryBoard.feeds.instantiateViewController(withIdentifier: "FrameSelectionVC") as! FrameSelectionVC
                destVC.pickzonUser = getPickzonUserFromDatabase()
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
                
            }else if  bannerArray[indexPath.row].type == 7 {
                
                let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "EntryStyleSelectionVC") as! EntryStyleSelectionVC
                destVC.pickzonUser = getPickzonUserFromDatabase()
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
                
            }else if  bannerArray[indexPath.row].type == 8 {
                
                let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                destVC.isGiftedCoinsTabOpen = false
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
                
            }else if  bannerArray[indexPath.row].type == 9 {
                
                let destVC:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                destVC.controllerType = .isFromPost
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
           
            }else if  bannerArray[indexPath.row].type == 11 {
                //PK Legend
                let destVC:PKLegendVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKLegendVC") as! PKLegendVC
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)

            }else if  bannerArray[indexPath.row].type == 12 {
                //PGT Hashtag
                    let destVC:PickzonGotTalentVC = StoryBoard.promote.instantiateViewController(withIdentifier: "PickzonGotTalentVC") as! PickzonGotTalentVC
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
            }else if  bannerArray[indexPath.row].type == 13 {
                // Hashtag
                let destVC:PGTClipsVC = StoryBoard.promote.instantiateViewController(withIdentifier: "PGTClipsVC") as! PGTClipsVC
                destVC.pgtObj.title =  bannerArray[indexPath.row].title
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
            }
        }
    }
    
    func getPickzonUserFromDatabase()->PickzonUser{
        
        var pickzonUser = PickzonUser(respdict: [:])
        
        guard let realm = DBManager.openRealm() else {
            return pickzonUser
        }
        
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
            
            pickzonUser.name = existingUser.name
            pickzonUser.email = existingUser.emailId
            pickzonUser.pickzonId = existingUser.pickzonId
            pickzonUser.description =  existingUser.desc
            pickzonUser.dob = existingUser.dob
            pickzonUser.headline = existingUser.organization
            pickzonUser.gender = existingUser.gender
            pickzonUser.jobProfile = existingUser.jobProfile
            pickzonUser.livesIn = existingUser.livesIn
            pickzonUser.followerCount = existingUser.totalFans
            pickzonUser.followingCount = existingUser.totalFollowing
            pickzonUser.postCount = existingUser.totalPost
            pickzonUser.mobileNo = existingUser.mobileNo
            pickzonUser.usertype = existingUser.usertype
            pickzonUser.website = existingUser.website
            pickzonUser.coverImage = existingUser.coverImage
            pickzonUser.actualProfileImage = existingUser.actualProfilePic
            pickzonUser.profilePic = existingUser.profilePic
            pickzonUser.avatar = existingUser.avatar
            pickzonUser.allGiftedCoins = existingUser.allGiftedCoins
            pickzonUser.angelsCount = existingUser.angelsCount
            pickzonUser.giftingLevel = existingUser.giftingLevel
        }
        
        return pickzonUser
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pagerView.currentPage = Int(indexPath.row)
    }
    
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionCell", for: indexPath) as? BannerCollectionCell
      
        var profile_pic =  bannerArray[indexPath.row].imageCdn
        
        if profile_pic.length > 0  && !profile_pic.contains("http"){
            if profile_pic.prefix(1) == "." {
                profile_pic = String(profile_pic.dropFirst(1))
            }
            profile_pic = Themes.sharedInstance.getURL() + ((profile_pic.prefix(1)=="/") ? "" : "/") + profile_pic
        }
        
        cell?.imgVwBanner.kf.setImage(with: URL(string: profile_pic), placeholder: PZImages.dummyCover!, options: nil, progressBlock: nil, completionHandler: { (resp) in
        })
        cell?.imgVwBanner.layer.cornerRadius = 5.0
        cell?.imgVwBanner.clipsToBounds = true
        return cell!
        
    }
    
     /*
          func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
              let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
              pagerView.currentPage = Int(pageNumber)
          }
      */
      
    //Mark: Selector Methods
    
    
    
    
    //MARK: Other helpful methods
    
//    func startTimer() {
//        timer =  Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
//        
//    }
    
    
    @objc func scrollAutomatically(_ timer1: Timer) {
      //  print("scrollAutomatically called")
        for cell in cllctnViewBanner.visibleCells {
            let indexPath: IndexPath? = cllctnViewBanner.indexPath(for: cell)
            
            if ((indexPath?.row)! < bannerArray.count - 1){
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                pagerView.currentPage = indexPath1?.row ?? 0
                cllctnViewBanner.scrollToItem(at: indexPath1!, at: .right, animated: true)
            }else{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                pagerView.currentPage = indexPath1?.row ?? 0
                cllctnViewBanner.scrollToItem(at: indexPath1!, at: .left, animated: true)
            }
            
        }
        
    }
    
   @objc func handleTap() {
//        timer.invalidate()
//        self.startTimer()
    }
        
}
