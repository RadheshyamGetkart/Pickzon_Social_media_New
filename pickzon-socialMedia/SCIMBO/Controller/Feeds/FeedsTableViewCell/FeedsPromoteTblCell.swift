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



class FeedsPromoteTblCell: FeedsCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var lblWebsiteURL:UILabel!
    @IBOutlet weak var lblMsg:UILabel!
    @IBOutlet weak var btnWebsite:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
       // btnUserName.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 14.0)
        
        btnFolow.layer.cornerRadius = btnFolow.frame.height / 2.0
        btnPromote.layer.cornerRadius = 5.0
        
       /* lblTagPeople.numberOfLines = 0
        lblTagPeople.enabledTypes = [.mention, .hashtag, .url]
        lblTagPeople.textColor =  Themes.sharedInstance.tagAndLinkColor()//.blue
        lblTagPeople.mentionColor = Themes.sharedInstance.tagAndLinkColor()
        lblTagPeople.highlightFontSize = 15
        */
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        
//        btnUserImage.layer.cornerRadius = btnUserImage.frame.width / 2.0
//        btnUserImage.clipsToBounds = true
//        btnUserImage.layer.borderWidth = 1.0
//        btnUserImage.layer.borderColor =  CustomColor.sharedInstance.themeColor.cgColor
        
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
       // cvFeedsPost.layoutSubviews()
        
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.green
        self.pageControl.hidesForSinglePage = true
        
        btnSavePost.layer.cornerRadius = btnSavePost.frame.height / 2.0
        btnSavePost.backgroundColor = UIColor.white
        
        lblDescription.numberOfLines = 3
        lblDescription.collapsed = true
        
        btnWebsite.layer.borderColor = UIColor.white.cgColor
        btnWebsite.layer.borderWidth = 1.0
        btnWebsite.layer.cornerRadius = 5.0
        
     
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
        self.isVideoActive = false
        cell.urlArray = urlArray
        
        if checkMediaTypes(strUrl: urlArray[indexPath.row]) == 1{
            
            cell.imgImageView.contentMode = .scaleAspectFill
            cell.imgImageView.kf.setImage(with: URL(string: urlArray[indexPath.item]), placeholder: PZImages.dummyCover, options: nil, progressBlock: nil) { response in}
            cell.configureCell(isToHidePlayer: true, indexPath: indexPath)
            cell.btnPreview.isHidden = true
        }else{
            cell.isVideo = true
            cell.imgImageView.contentMode = .scaleAspectFit
           
            /*if thumbArray.count > indexPath.row{
                cell.mmPlayerLayer.thumbImageView.kf.setImage(with: URL(string: thumbArray[indexPath.item]), placeholder: UIImage(named: "video_thumbnail"), options: nil, progressBlock: nil) { response in}
            }else{
                
                URLhandler.sharedinstance.getThumbnailImageFromVideoUrl(videoUrlString: urlArray[indexPath.item], imageView: cell.mmPlayerLayer.thumbImageView, placeholderImage:UIImage(named: "video_thumbnail")!)
            }
            cell.mmPlayerLayer.thumbImageView.contentMode = .scaleAspectFit
            */
           // cell.btnPreview.isHidden = false
            cell.configureCell(isToHidePlayer: false, indexPath: indexPath)
           // cell.mmPlayerLayer.showCover(isShow: true)
            //cell.mmPlayerLayer.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
            
            cell.videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
            
            cell.backgroundColor = UIColor.black
           // cell.mmPlayerLayer.backgroundColor = UIColor.clear.cgColor
            self.isVideoActive = true
            
        }
        
        //cell.mmPlayerLayer.coverView?.tag = tableIndexPath?.row ?? 0
        //cell.mmPlayerLayer.playView?.tag = tableIndexPath?.row ?? 0
        
        cell.btnPreview.tag = indexPath.item
        cell.btnPreview.addTarget(self, action: #selector(previewBtnAction(sender:)), for: .touchUpInside)
        cell.pauseVideo()
        
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       // let cvSize = self.view.frame.size.width
       /* if self.urlDimensionArray.count > 0 {
            let objDimenstion = self.urlDimensionArray[indexPath.row]
            let height = objDimenstion["height"] as? Int16 ?? 0
            let width = objDimenstion["width"] as? Int16 ?? 0
            if height > width {
                let div = CGFloat(height) / CGFloat(width)
                cvSize = (self.view.frame.width * div)
            }
        }*/
        
        return CGSize(width: self.view.frame.size.width, height: self.cvFeedsPost.frame.height )
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        pageControl.currentPage = indexPath.row
        self.isVideoActive = false
        
        if  let playerCell = cell as? FeedsCollectionViewCell{
            
            if checkMediaTypes(strUrl:urlArray[indexPath.row]) == 1{
                
            }else{
                
                if shoulAutoplayVideo() == true {
                    //playerCell.playVideo()
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
           // playerCell.mmPlayerLayer.currentPlayStatus = .pause
            //playerCell.pauseVideo()
            playerCell.pauseVideo()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)

     
 }
   
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
     
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)

        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at: indexPath) as? FeedsCollectionViewCell

     
        cell?.pauseVideo()
    }
    
   
    @objc func previewBtnAction(sender:UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = cvFeedsPost.cellForItem(at: indexPath) as? FeedsCollectionViewCell
       // cell?.mmPlayerLayer.currentPlayStatus = .pause
        //cell?.mmPlayerLayer.player?.pause()
        cell?.pauseVideo()
        if checkMediaTypes(strUrl:urlArray[indexPath.row]) == 1{
            
//            let zoomCtrl = VKImageZoom()
//            zoomCtrl.image = cell?.imgImageView.image
//            zoomCtrl.modalPresentationStyle = .fullScreen
//            self.parentContainerViewController?.present(zoomCtrl, animated: true, completion: nil)
            
          

        }else{
            
            PlayerHelper.shared.pause()

            if let videoURL = URL(string: urlArray[indexPath.row]){
                let player = AVPlayer(url: videoURL)
                let playervc = AVPlayerViewController()
                playervc.player = player
                self.parentContainerViewController?.present(playervc, animated: true) {
                    playervc.player!.play()
                }
                
            }
        }
        
    }
    
    
    
}




