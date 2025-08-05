//
//  ClipSuggestionTVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/8/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//


import UIKit
import Kingfisher

class ClipSuggestionTVCell: UITableViewCell {

    @IBOutlet weak var viewBack:UIView!
    @IBOutlet weak var viewBorder:UIView!
    @IBOutlet weak var cllctnVw:UICollectionView!
    weak var delegate:BusinessMediaDelegate? = nil
    var wallPostArray = [WallPostModel]()
    var parentIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctnVw.register(UINib(nibName: "ClipSuggestionCVCell", bundle: nil),
                              forCellWithReuseIdentifier: "ClipSuggestionCVCell")
        cllctnVw.delegate = self
        cllctnVw.dataSource = self
        
    }
    deinit{
        print("ClipSuggestionTVCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func seeAllAction() {
        delegate?.clickedMediaWith(index:0, parentIndex:parentIndex)
    }
    
}

//MARK: - UICollectionview delegate and datasource

extension ClipSuggestionTVCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cllctnVw.frame.width/2.5 , height: (self.cllctnVw.frame.height))
         
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallPostArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cllctnVw.dequeueReusableCell(withReuseIdentifier: "ClipSuggestionCVCell", for: indexPath) as! ClipSuggestionCVCell
        
        cell.imgVideoThumb.contentMode = .scaleAspectFill
        cell.imgVideoThumb.backgroundColor = UIColor.black
  
            guard let objWallPost = wallPostArray[indexPath.item]  as? WallPostModel else{
                return UICollectionViewCell()
            }
            
            if objWallPost.sharedWallData == nil {
                if let urlStr = objWallPost.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: nil, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),
                                                                                                                                                                 .scaleFactor(UIScreen.main.scale),
                                                                                                                                                                 .cacheOriginalImage], progressBlock: nil) {response in
                                                                                                                                                                 }
                    
                }
            }else{
                if let urlStr = objWallPost.sharedWallData?.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: nil, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),
                                                                                                                                                                 .scaleFactor(UIScreen.main.scale),
                                                                                                                                                                 .cacheOriginalImage], progressBlock: nil) {response in
                                                                                                                                                                 }
                    
                }
            }
        return cell
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.clickedMediaWith(index:indexPath.item, parentIndex:parentIndex)
    }
}

