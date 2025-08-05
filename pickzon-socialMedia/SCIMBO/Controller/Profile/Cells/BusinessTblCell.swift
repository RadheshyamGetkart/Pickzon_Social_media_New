//
//  BusinessTblCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 1/19/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class BusinessTblCell: UITableViewCell {

   
    @IBOutlet weak var cllctnBusinness:UICollectionView!

    var businessArray = [SuggestedUser]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cllctnBusinness.register(UINib(nibName: "BusinessCllctnCell", bundle: nil), forCellWithReuseIdentifier: "BusinessCllctnCell") 
        cllctnBusinness.delegate = self
        cllctnBusinness.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


//MARK: - UICollectionview delegate and datasource

extension BusinessTblCell:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   10 //friendSugesstionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCllctnCell", for: indexPath) as! BusinessCllctnCell
//        cell.lblName.text = friendSugesstionArray[indexPath.item].name.capitalized
//        cell.lblUserName.text = "Suggested for you"
//        cell.imgVw.kf.setImage(with: URL(string: friendSugesstionArray[indexPath.item].profile_pic), placeholder: UIImage(named: "avatar"), options: nil, progressBlock: nil) { response in}
//        cell.btnFollow.tag = indexPath.item
//        cell.btnFollow.addTarget(self, action: #selector(followBtnAction(_ : )), for: .touchUpInside)
//        cell.btnFollow.setTitle(friendSugesstionArray[indexPath.item].statusType.capitalized, for: .normal)
//        cell.imgVwCelebrity.isHidden = (friendSugesstionArray[indexPath.item].celebrity == 1) ? false : true
//
//
//        cell.btnClose.tag = indexPath.item
//        cell.btnClose.addTarget(self, action: #selector(closeBtnAction(_ : )), for: .touchUpInside)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width, height: self.cllctnBusinness.frame.height )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      //  delegate?.clickedUserIndex(index: indexPath.row)
    }
    
   
    
    
}
