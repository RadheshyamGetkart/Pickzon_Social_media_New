//
//  SponserTblCell.swift
//  SCIMBO
//
//  Created by Getkart on 23/07/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit

class SponserTblCell: FeedsCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
        cvFeedsPost.layoutSubviews()
        
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        self.pageControl.hidesForSinglePage = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureSponsorCell(objWallPost:WallPostModel,indexPath:IndexPath){
        
        var txtFeeling = ""
        
        if objWallPost.feeling.count > 0 {
            txtFeeling = (objWallPost.feeling["image"] as? String ?? "") + " " +  (objWallPost.feeling["name"]  as? String ?? "")
        }else if objWallPost.activities.count > 0 {
            txtFeeling = (objWallPost.activities["image"] as? String ?? "") + " " +  (objWallPost.activities["name"] as? String ?? "")
        }
        
        var cvSize:CGFloat = (objWallPost.urlArray.count > 0) ? self.view.frame.width :  0
        
        self.btnUserName.setTitle(objWallPost.userInfo?.name, for: .normal)
        self.lblLocation.text = objWallPost.place
        self.lblDescription.text = NSAttributedString(html: objWallPost.payload + txtFeeling)?.string
        //self.lblTagPeople.text = objWallPost.taggedPeople
        self.urlArray = objWallPost.urlArray
        self.lblLocation.text = "Sponsored"
        //self.btnBuyNow.setTitle(objWallPost.adLabel, for: .normal)
        self.cnstrnt_CllctnHeight.constant = 0
        if objWallPost.urlArray.count > 0 {
            cvSize = self.view.frame.width
            self.cnstrnt_CllctnHeight.constant = self.view.frame.width
        }
       
    }
    
    //MARK: - UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return urlArray.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedsCollectionViewCell", for: indexPath) as! FeedsCollectionViewCell
        cell.urlArray = urlArray

        cell.imgImageView.image = nil
        if checkMediaTypes(strUrl: urlArray[indexPath.row]) == 1{
        URLhandler.sharedinstance.getImageFromUrl(imageUrl:urlArray[indexPath.row] , imageView: cell.imgImageView!, placeholderImage:PZImages.dummyCover!)
          
        }else {
            
            URLhandler.sharedinstance.getThumbnailImageFromVideoUrl(videoUrlString: urlArray[indexPath.row], imageView: cell.imgImageView!, placeholderImage:PZImages.dummyCover!)
        }
        
        cell.layoutIfNeeded()
        cell.url = urlArray[indexPath.row]
        cell.btnPreview.tag = indexPath.item
        cell.btnPreview.addTarget(self, action: #selector(previewBtnAction(sender:)), for: .touchUpInside)
        cell.btnPreview.isHidden = true
      
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: self.view.frame.size.width, height: self.cvFeedsPost.frame.height)

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.numberOfPages = urlArray.count

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    

    
    @objc func previewBtnAction(sender:UIButton) {
        
    }
}
