//
//  TrendingVideoTVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/7/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class TrendingVideoTVCell: UITableViewCell {

    @IBOutlet weak var viewBack:UIView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnViewTitle:UIButton!
    @IBOutlet weak var cllctnVw:UICollectionView!
    
    var wallPostArray = [WallPostModel]()
    var parentIndex = 0
    weak var delegate:BusinessMediaDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        cllctnVw.register(UINib(nibName: "ProfileMediaCell", bundle: nil),
                          forCellWithReuseIdentifier: "ProfileMediaCellId")
        
        viewBack.addShadowToView(corner: 7.0, shadowColor: UIColor.lightGray, shadowRadius: 7.0, shadowOpacity: 0.7)
        
    }

 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
}

extension TrendingVideoTVCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cllctnVw.frame.width/3.05, height: (self.cllctnVw.frame.height))
         
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallPostArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cllctnVw.dequeueReusableCell(withReuseIdentifier: "ProfileMediaCellId", for: indexPath) as! ProfileMediaCell
        cell.lblDesc.backgroundColor = UIColor.systemBlue
        cell.imgVideoThumb.contentMode = .scaleAspectFill
        cell.imgVideoThumb.backgroundColor = UIColor.black
        cell.lblDesc.isHidden = true
        cell.eye.isHidden = true
        cell.lblViewCount.isHidden = true
        cell.imgVwVideoIcon.isHidden = true
        cell.btnDeleteVideo.isHidden = true
        cell.lblDesc.text =  ""
        cell.imgVideoThumb.layer.cornerRadius = 7.0
        cell.imgVideoThumb.layer.masksToBounds = true
        cell.imgVideoThumb.clipsToBounds = true
        
        if let objWallPost = wallPostArray[indexPath.item]  as? WallPostModel {
            if objWallPost.sharedWallData == nil {
                if let urlStr = objWallPost.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in }
                }
            }else{
                if let urlStr = objWallPost.sharedWallData?.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in }
                }
            }
            
            
            return cell
        }else{
            return UICollectionViewCell()
        }       
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.clickedMediaWith(index:indexPath.item, parentIndex: self.parentIndex)
    }
    
    @IBAction func clickedAllMedia(){
        delegate?.clickedAllMedia(parentIndex: self.parentIndex)
    }
    
}


