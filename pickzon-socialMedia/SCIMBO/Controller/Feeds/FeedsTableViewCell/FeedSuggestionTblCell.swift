//
//  FeedSuggestionTblCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 12/15/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import Kingfisher

protocol SuggestionDelegate: AnyObject{
    
    func clickedUserIndex(index:Int,section:Int)
    func clickedFollowUser(index:Int,section:Int)
    func seeAllList()
    func cancelSuggestionUser(index:Int,section:Int)

}


class FeedSuggestionTblCell: UITableViewCell {
    
    var delegate:SuggestionDelegate? = nil
    @IBOutlet weak var cllctnView:UICollectionView!
    @IBOutlet weak var viewBack:UIView!
    
    var friendSugesstionArray:Array<FriendUser> = Array<FriendUser>()
    var sectionIndex = 0
    
    @IBOutlet weak var btnSeeAll:UIButton!
    @IBOutlet weak var lblTitle:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnSeeAll.setImageTintColor(UIColor.systemBlue)
        cllctnView.register(UINib(nibName: "SuggestionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SuggestionCollectionCell")
        cllctnView.delegate = self
        cllctnView.dataSource = self
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    //MARK: - UIButton Action Methods
    @IBAction func seeAllBtnAction(_ sender : UIButton){
        self.delegate?.seeAllList()
        
    }
}

//MARK: - UICollectionview delegate and datasource

extension FeedSuggestionTblCell:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendSugesstionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCollectionCell", for: indexPath) as! SuggestionCollectionCell
        cell.lblName.text = friendSugesstionArray[indexPath.item].pickzonId
        cell.profileImgView.setImgView(profilePic: friendSugesstionArray[indexPath.item].profilePic, frameImg: friendSugesstionArray[indexPath.item].avatar,changeValue: 6)
        
        if  friendSugesstionArray[indexPath.item].jobProfile.count > 0 {
            cell.lblUserName.text =   friendSugesstionArray[indexPath.item].jobProfile
        }else if friendSugesstionArray[indexPath.item].livesIn.count > 0 {
            cell.lblUserName.text =  friendSugesstionArray[indexPath.item].livesIn
        }else if friendSugesstionArray[indexPath.item].name.count > 0 {
            cell.lblUserName.text =  "\(friendSugesstionArray[indexPath.item].name)"
        }else{
            cell.lblUserName.text =  ""
        }
        
        cell.btnFollow.tag = indexPath.item
        cell.btnFollow.addTarget(self, action: #selector(followBtnAction(_ : )), for: .touchUpInside)
       
        cell.btnFollow.setTitle("Follow", for: .normal)

        if friendSugesstionArray[indexPath.item].celebrity == 1 {
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.greenVerification
        }else if friendSugesstionArray[indexPath.item].celebrity == 4 {
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.goldVerification
        }else if friendSugesstionArray[indexPath.item].celebrity == 5 {
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.blueVerification
        }else{
            cell.imgVwCelebrity.isHidden = true
        }
        
        cell.btnClose.tag = indexPath.item
        cell.btnClose.addTarget(self, action: #selector(closeBtnAction(_ : )), for: .touchUpInside)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width, height: self.cllctnView.frame.height )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.clickedUserIndex(index: indexPath.row, section: sectionIndex)
    }
    
    //MARK: - Follow Btn Action
    
    @objc func followBtnAction(_ sender : UIButton){
        delegate?.clickedFollowUser(index: sender.tag, section: sectionIndex)
        
    }
    
    @objc func closeBtnAction(_ sender : UIButton){
        delegate?.cancelSuggestionUser(index: sender.tag, section: sectionIndex)
    }
    
    
    
}
