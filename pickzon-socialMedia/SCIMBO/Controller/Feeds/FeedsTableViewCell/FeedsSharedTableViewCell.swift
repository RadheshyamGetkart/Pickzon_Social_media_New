//
//  FeedsSharedTableViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 7/15/21.
//  Copyright © 2021 GETKART. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher

class FeedsSharedTableViewCell: FeedsCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profilePicView.initializeView()
        self.profilePicViewShared.initializeView()

        self.cvFeedsPost.layer.cornerRadius = 0.0
        self.cvFeedsPost.clipsToBounds = true
        
        btnFolow.layer.cornerRadius = 5.0
        btnSharedFollow.layer.cornerRadius = 5.0
        self.lblMediaCount.layer.cornerRadius = lblMediaCount.frame.size.height/2.0
        lblMediaCount.clipsToBounds = true
        
        self.lblMediaCount.isHidden = true
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
        cvFeedsPost.layoutSubviews()
        self.pageControl.isHidden = true
        self.pageControl.hidesForSinglePage = true
        btnSavePost.layer.cornerRadius = btnSavePost.frame.height / 2.0
        btnSavePost.backgroundColor = UIColor.white
        
        lblDescription.numberOfLines = 3
        lblDescription.collapsed = true
        lblDescription.collapsedAttributedLink = NSAttributedString(string: "Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
        lblSharedContents.numberOfLines = 3
        lblSharedContents.collapsed = true
        lblSharedContents.collapsedAttributedLink = NSAttributedString(string: "Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
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
           
        return urlArray.count
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedsCollectionViewCell", for: indexPath) as! FeedsCollectionViewCell
        
        cell.url = urlArray[indexPath.row]
        self.isVideoActive = false
        cell.urlArray = urlArray
        cell.objWallPost = self.objWallPost
        cell.imgImageView.image = nil
        cell.hashTag = self.hashTag
        cell.controllerType = self.controllerType
        if checkMediaTypes(strUrl:urlArray[indexPath.row]) == 1{
            
            cell.imgImageView.kf.setImage(with: URL(string: urlArray[indexPath.item]), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgImageView.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil) { response in
                
            }
            cell.imgImageView.contentMode = .scaleAspectFill
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
            
            if thumbArray.count > indexPath.row{
                cell.controlView.thumbImageView.kf.setImage(with: URL(string: thumbArray[indexPath.item]), placeholder: nil, options: [.processor(DownsamplingImageProcessor(size: cell.controlView.thumbImageView.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil) { response in
                }
            }else{
                URLhandler.sharedinstance.getThumbnailImageFromVideoUrl(videoUrlString: urlArray[indexPath.item], imageView:  cell.controlView.thumbImageView, placeholderImage:PZImages.dummyCover!)
            }
            
            
            cell.imgImageView.contentMode = .scaleAspectFit
            cell.btnPreview.isHidden = true
            cell.configureCell(isToHidePlayer: false, indexPath: indexPath)
            
            cell.videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
            cell.videoView.tag = self.btnUserName.tag
            cell.isVideo = true
            self.isVideoActive = true
            
            let tap = UITapGestureRecognizer(target: cell, action: #selector(cell.handleTap(_:)))
            tap.numberOfTapsRequired = 1
            cell.controlView.addGestureRecognizer(tap)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            doubleTap.numberOfTapsRequired = 2
            cell.controlView.addGestureRecognizer(doubleTap)
            tap.require(toFail: doubleTap)
        }
        
        cell.backgroundColor = UIColor.black
        
        cell.pauseVideo()
        
        if self.urlArray.count > 1 {
            self.lblMediaCount.isHidden = false
        }else {
            self.lblMediaCount.isHidden = true
        }
        cell.isRandomVideos = self.isRandomVideos
  
        cell.viewBorderBottom.isHidden = true
        cell.cnstrnt_BorderHeight.constant = 0

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: self.view.frame.size.width, height: self.cvFeedsPost.frame.height )
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.isVideoActive = false
        
        if  cell is FeedsCollectionViewCell{
            
            if checkMediaTypes(strUrl:urlArray[indexPath.row]) == 1{
                
            }else{
                if shoulAutoplayVideo() == true {
                    self.isVideoActive = true
                }
            }
        }
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if  let playerCell = cell as? FeedsCollectionViewCell{

            playerCell.pauseVideo()

        }
    }
    
  
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        if self.urlArray.count > 1 {
            self.lblMediaCount.text = "\(Int(pageNumber) + 1)/\(self.urlArray.count)"
        }

        self.lblMediaCount.text = "\(Int(pageNumber) + 1)/\(self.urlArray.count)"
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at: indexPath) as? FeedsCollectionViewCell
        
        if urlArray.count > indexPath.row {
            if checkMediaTypes(strUrl:urlArray[indexPath.row]) == 1{
                
            }else{
                if shoulAutoplayVideo() == true {
                    self.isVideoActive = true
                    cell?.playVideo()
                }
            }
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at: indexPath) as? FeedsCollectionViewCell
     
       cell?.pauseVideo()
    }
    
      
    
    func playSingleVideo(pauseAll: Bool = false) {
        
        if let visibleCells = self.cvFeedsPost.visibleCells as? [FeedsCollectionViewCell], !visibleCells.isEmpty {
            if pauseAll {
                visibleCells.forEach {
                    //$0.mmPlayerLayer.player?.pause()
                    $0.pauseVideo()
                }
            } else {
                var maxHeightRequired: Int = 400
                var cellToPlay: FeedsCollectionViewCell?
                
                visibleCells.reversed().forEach { (cell) in
          
                    let cellBounds = self.view.convert(cell.videoView.frame, from: cell.videoView)
                    let visibleCellHeight = Int(self.view.frame.intersection(cellBounds).height)
                    
                    if visibleCellHeight >= maxHeightRequired {
                        maxHeightRequired = visibleCellHeight
                        cellToPlay = cell
                    }
                }
                
                visibleCells.forEach { (cell) in
                    if cell === cellToPlay {
                        cell.playVideo()
                        
                    } else {
                       
                        cell.pauseVideo()
                    }
                }
            }
        }
    }
}

