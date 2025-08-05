//
//  FeedsTableViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/26/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import ActiveLabel
import SCIMBOEx
import FittedSheets
import Alamofire




class FeedsTableViewCell: FeedsCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profilePicView.initializeView()
        self.lblMediaCount.isHidden = true
        self.cvFeedsPost.layer.cornerRadius = 0.0
        self.cvFeedsPost.clipsToBounds = true
        self.lblMediaCount.layer.cornerRadius = lblMediaCount.frame.size.height/2.0
        self.lblMediaCount.clipsToBounds = true
        btnFolow.layer.cornerRadius = 5.0
        btnPromote.layer.cornerRadius = 5.0
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
                
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
        self.pageControl.isHidden = false
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = CustomColor.sharedInstance.newThemeColor
        self.pageControl.hidesForSinglePage = true
        btnSavePost.layer.cornerRadius = btnSavePost.frame.height / 2.0
        btnSavePost.backgroundColor = UIColor.white
        lblDescription.numberOfLines = 3
        lblDescription.collapsed = true
        
        lblDescription.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
        
        
        self.btnBoost.layer.cornerRadius = 5.0
        self.btnBoost.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        lblDescription.collapsed = true
        lblDescription.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK: - UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if urlArray.count > 0 {
            pageControl.numberOfPages = urlArray.count
            return urlArray.count
        }else {
            pageControl.numberOfPages = 0
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedsCollectionViewCell", for: indexPath) as! FeedsCollectionViewCell
        
        cell.url = urlArray[indexPath.row]
        cell.thumbURL = thumbArray.count > indexPath.row ? thumbArray[indexPath.row] : ""
        cell.mediaId = mediaArr.count > indexPath.row ? mediaArr[indexPath.row] : ""
        self.isVideoActive = false
        cell.urlArray = urlArray
        cell.objWallPost = self.objWallPost
        cell.imgImageView.image = nil
        cell.hashTag = self.hashTag
        cell.controllerType = self.controllerType
        
        if checkMediaTypes(strUrl: urlArray[indexPath.row]) == 1{
            
            cell.imgImageView.contentMode = .scaleAspectFill
            cell.imgImageView.kf.setImage(with: URL(string: urlArray[indexPath.item]), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgImageView.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil) { response in}
            cell.configureCell(isToHidePlayer: true, indexPath: indexPath)
            cell.btnPreview.isHidden = true
            
            let tap = UITapGestureRecognizer(target: cell, action: #selector(cell.handleTap(_:)))
            tap.numberOfTapsRequired = 1
            cell.imgImageView.addGestureRecognizer(tap)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            doubleTap.numberOfTapsRequired = 2
            cell.imgImageView.addGestureRecognizer(doubleTap)
            tap.require(toFail: doubleTap)
        }else{
            cell.isVideo = true
            cell.imgImageView.contentMode = .scaleAspectFit
            
            if thumbArray.count > indexPath.item{
                cell.controlView.thumbImageView.kf.setImage(with: URL(string: thumbArray[indexPath.item]), placeholder:nil, options: [.processor(DownsamplingImageProcessor(size: cell.controlView.thumbImageView.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil) { response in}
            }else{
                
                URLhandler.sharedinstance.getThumbnailImageFromVideoUrl(videoUrlString: urlArray[indexPath.item], imageView: cell.controlView.thumbImageView, placeholderImage:PZImages.dummyCover!)
            }
            
            cell.controlView.play_Button.tag = tableIndexPath?.row ?? 0
            cell.btnPreview.isHidden = true
            cell.configureCell(isToHidePlayer: false, indexPath: indexPath)
            
            cell.backgroundColor = UIColor.black
            cell.videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
            cell.videoView.tag = self.btnUserName.tag
            self.isVideoActive = true
            
            let tap = UITapGestureRecognizer(target: cell, action: #selector(cell.handleTap(_:)))
            tap.numberOfTapsRequired = 1
            cell.controlView.addGestureRecognizer(tap)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            doubleTap.numberOfTapsRequired = 2
            cell.controlView.addGestureRecognizer(doubleTap)
            tap.require(toFail: doubleTap)
        }
        
       
        cell.pauseVideo()
        if urlArray.count > 1{
            self.lblMediaCount.isHidden = false
        }else {
            self.lblMediaCount.isHidden = true
        }
        cell.btnPreview.isHidden = true
        cell.isRandomVideos = self.isRandomVideos
        
        cell.viewBorderBottom.isHidden = true
        cell.cnstrnt_BorderHeight.constant = 0
        
       
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
            return CGSize(width: self.view.frame.size.width , height: self.cvFeedsPost.frame.height )
        
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
        self.isVideoActive = false
        
        if  cell is FeedsCollectionViewCell{
            
            if checkMediaTypes(strUrl: urlArray[indexPath.row]) == 1{
                
            }else{
                
                if shoulAutoplayVideo() == true {
                    self.isVideoActive = true
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
  
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if  let playerCell = cell as? FeedsCollectionViewCell{
            playerCell.pauseVideo()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        if self.urlArray.count > 1 {
            self.lblMediaCount.text = "\(Int(pageNumber) + 1)/\(self.urlArray.count)"
            if checkMediaTypes(strUrl: urlArray[Int(pageNumber)]) == 1{
                self.isVideoActive = false
            }else{
                if shoulAutoplayVideo() == true {
                    self.isVideoActive = true
                    if  let playerCell = self.cvFeedsPost.cellForItem(at: IndexPath(row: Int(pageNumber), section: 0)) as? FeedsCollectionViewCell{
                        playerCell.playVideo()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
   

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at: indexPath) as? FeedsCollectionViewCell
        cell?.pauseVideo()
    }
    
    
}





