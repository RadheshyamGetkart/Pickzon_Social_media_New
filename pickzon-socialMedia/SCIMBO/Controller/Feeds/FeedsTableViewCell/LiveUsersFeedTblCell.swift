//
//  LiveUsersFeedTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/18/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher



protocol LiveUsersFeedDelegate{
    func getLiveUserSelectedIndex(index:Int)
}

class LiveUsersFeedTblCell: UITableViewCell {
    
  
    @IBOutlet weak var cllctnView:UICollectionView!
    @IBOutlet weak var viewBack:UIView!
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var titleStackView:UIStackView!
    @IBOutlet weak var cnstrntTopSeperatorHt:NSLayoutConstraint!
    @IBOutlet weak var cnstrntBottomSeperatorHt:NSLayoutConstraint!

    var delegate:LiveUsersFeedDelegate?
    var liveUsersArray:Array<JoinedUser> = Array<JoinedUser>()
    var sectionIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnSeeAll.setImageTintColor(UIColor.systemBlue)
        cllctnView.register(UINib(nibName: "LiveUserCell", bundle: nil), forCellWithReuseIdentifier: "LiveUserCell")
        cllctnView.delegate = self
        cllctnView.dataSource = self
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    //MARK: - UIButton Action Methods
    @IBAction func seeAllBtnAction(_ sender : UIButton){
        
        let destVc:AllLiveUserListVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "AllLiveUserListVC") as! AllLiveUserListVC
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
}


//MARK: - UICollectionview delegate and datasource

extension LiveUsersFeedTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveUsersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveUserCell", for: indexPath) as! LiveUserCell
        
        cell.imgVWProfilePic.kf.setImage(with: URL(string: liveUsersArray[indexPath.row].profilePic), placeholder: PZImages.avatar, progressBlock: nil) { response in }

        cell.imgVwCover.kf.setImage(with: URL(string: liveUsersArray[indexPath.row].coverPic), placeholder: PZImages.defaultCover, progressBlock: nil) { response in }
        
        cell.imgVWProfilePic.layer.borderWidth = 1.5
        cell.imgVWProfilePic.layer.borderColor = UIColor.red.cgColor
        
        //  "isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
        if liveUsersArray[indexPath.row].isLivePK == 1{
            cell.imgVwPk.isHidden = false
        }else{
            cell.imgVwPk.isHidden = true
        }


        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width/3, height: self.cllctnView.frame.size.height-5 )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        self.delegate?.getLiveUserSelectedIndex(index: indexPath.item)
       
        if liveUsersArray[indexPath.row].isLivePK == 1{
            
            let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
            var arr = liveUsersArray[indexPath.row].PKRoomId.components(separatedBy: ",")
            if arr.count > 0 {
                destVc.leftRoomId = liveUsersArray[indexPath.row].userId
                if let index = arr.firstIndex(of: liveUsersArray[indexPath.row].userId){
                    arr.remove(at: index)
                }
                destVc.rightRoomId = arr.last ?? ""
            }
            destVc.livePKId = liveUsersArray[indexPath.row].livePKId
            AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
                
        }else{
            let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
            destVc.leftRoomId = liveUsersArray[indexPath.row].userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
        }

    }
    
}


