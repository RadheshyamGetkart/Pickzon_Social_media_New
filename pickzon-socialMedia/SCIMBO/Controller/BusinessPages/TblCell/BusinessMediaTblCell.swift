//
//  BusinessMediaTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 12/12/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher


enum MediaCellType{
    
    case all
    case clips
    
}

protocol BusinessMediaDelegate: AnyObject{
    
    func clickedMediaWith(index:Int, parentIndex:Int)
    func clickedAllMedia(parentIndex:Int)
    func deleteMediaWith(index:Int, parentIndex:Int)
    func editMediaWith(index:Int, parentIndex:Int)
}


extension BusinessMediaDelegate{
    func clickedAllMedia(parentIndex:Int){
        
    }
   func deleteMediaWith(index:Int, parentIndex:Int){
        
    }
  
    func editMediaWith(index:Int, parentIndex:Int){
        
    }
}



class BusinessMediaTblCell: UITableViewCell {

    @IBOutlet weak var cllctnVw:UICollectionView!
    weak var delegate:BusinessMediaDelegate? = nil
    var isClipsVideo = false
    var isToHideOption = false
    var wallPostArray = [WallPostModel]()
    var selectedTab = 0
    weak var tabDelegate:TabDelegate? = nil
    var tabArray = ["Posts"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctnVw.register(UINib(nibName: "ProfileMediaCell", bundle: nil),
                              forCellWithReuseIdentifier: "ProfileMediaCellId")
        cllctnVw.delegate = self
        cllctnVw.dataSource = self
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwiped))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwiped))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
        
        self.setCollectionLayout()
        
    }
    
    func setCollectionLayout(){
       
       /* if isClipsVideo{
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: UIScreen.ft_width()/3, height: UIScreen.ft_width()/3 + 70)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            self.cllctnVw.collectionViewLayout = layout
            
        }else{
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: UIScreen.ft_width()/3.05, height: UIScreen.ft_width()/3.05)
            layout.minimumInteritemSpacing = 2.5
            layout.minimumLineSpacing = 2.5
            self.cllctnVw.collectionViewLayout = layout
        }*/
    }
    
    deinit{
        print("BusinessMediaTblCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc  func rightSwiped()
    {

        if selectedTab > 0{
            selectedTab = selectedTab - 1
            tabDelegate?.selectedTabIndex(title: tabArray[selectedTab], index:selectedTab)
        }
        print("right swiped ")

    }

    @objc func leftSwiped()
    {

        print("left swiped ")
        if selectedTab < tabArray.count - 1{
            selectedTab = selectedTab + 1
            tabDelegate?.selectedTabIndex(title: tabArray[selectedTab], index:selectedTab)
        }

    }
}

//MARK: - UICollectionview delegate and datasource

extension BusinessMediaTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isClipsVideo == true {
            return CGSize(width: self.cllctnVw.frame.width/3.02, height: (self.cllctnVw.frame.width / 3.0) + 70)
        }

        
        return CGSize(width: self.cllctnVw.frame.width/3.02, height: (self.cllctnVw.frame.width / 3.02) + 10 )
         
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   
        return wallPostArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cllctnVw.dequeueReusableCell(withReuseIdentifier: "ProfileMediaCellId", for: indexPath) as! ProfileMediaCell
        
        cell.imgVideoThumb.contentMode = .scaleAspectFill
        cell.imgVideoThumb.backgroundColor = UIColor.black
        cell.lblDesc.isHidden = true
        cell.lblDesc.backgroundColor = UIColor.systemBlue
        cell.imgVwVideoIcon.isHidden = true
        cell.eye.isHidden = true
        cell.lblViewCount.isHidden = true
        cell.btnEditVideo.isHidden = true
        cell.btnDeleteVideo.isHidden = true
        
        cell.btnDeleteVideo.tag = indexPath.item
        cell.btnEditVideo.tag = indexPath.item
        
        guard let objWallPost = wallPostArray[indexPath.item]  as? WallPostModel else{
            return UICollectionViewCell()
        }
        
        if isClipsVideo == true {
            
            /*
             cell.btnDeleteVideo.setImage(PZImages.threedot, for: .normal)
             cell.imgVideoThumb.layer.cornerRadius = 0
             cell.eye.image = PZImages.playBlank
             cell.eye.isHidden = false
             cell.lblViewCount.isHidden = false
             cell.lblViewCount.text =  clipArray[indexPath.item].viewCount.asFormatted_k_String
             cell.imgVideoThumb.kf.setImage(with: URL(string: clipArray[indexPath.item].thumbUrl), placeholder: PZImages.dummyCover, options: [.cacheMemoryOnly], progressBlock: nil) { response in }
             cell.imgVwVideoIcon.isHidden = true
             
             if (clipArray[indexPath.item].userInfo?.userId ?? "") == Themes.sharedInstance.Getuser_id() && isToHideOption == false{
             // cell.btnEditVideo.isHidden = false
             cell.btnDeleteVideo.isHidden = false
             cell.btnDeleteVideo.addTarget(self, action: #selector(deleteClipVideo(_ : )), for: .touchUpInside)
             // cell.btnEditVideo.addTarget(self, action: #selector(editClipVideo(_ : )), for: .touchUpInside)
             }else{
             // cell.btnEditVideo.isHidden = true
             cell.btnDeleteVideo.isHidden = true
             }
             */
            
            cell.imgVideoThumb.layer.cornerRadius = 0
            cell.eye.image = PZImages.playBlank
            cell.eye.isHidden = false
            cell.lblViewCount.isHidden = false
            cell.lblViewCount.text =  wallPostArray[indexPath.item].viewCount.asFormatted_k_String
            cell.btnDeleteVideo.setImage(PZImages.threedot, for: .normal)

            cell.btnDeleteVideo.isHidden = true
            cell.imgVwVideoIcon.isHidden = true
            if objWallPost.sharedWallData == nil {
                
                if let urlStr = objWallPost.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
                    }
                    
                }
            }else{
                if let urlStr = objWallPost.sharedWallData?.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder:PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
                        
                    }
                }
            }
            
            if (objWallPost.userInfo?.id ?? "") == Themes.sharedInstance.Getuser_id() && isToHideOption == false{
                cell.btnDeleteVideo.isHidden = false
                cell.btnDeleteVideo.setImageTintColor(.white)
                cell.btnDeleteVideo.addTarget(self, action: #selector(deleteClipVideo(_ : )), for: .touchUpInside)
            }else{
                cell.btnDeleteVideo.isHidden = true
            }
            
        }else{
            cell.eye.image = PZImages.eye
            cell.eye.isHidden = false
            cell.lblViewCount.isHidden = false
            cell.lblViewCount.text = wallPostArray[indexPath.item].viewCount.asFormatted_k_String
            
            if objWallPost.sharedWallData == nil {
                if let urlStr = objWallPost.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
                        
                        if objWallPost.urlArray.count > 0 {
                            cell.setVideoIcon(urlStr: objWallPost.urlArray.first ?? "")
                        }
                    }
                    
                }else if  objWallPost.thumbUrlArray.count == 0 {
                    cell.lblDesc.text = objWallPost.payload
                    cell.lblDesc.isHidden = false
                }
            }else{
                if let urlStr = objWallPost.sharedWallData?.thumbUrlArray.first {
                    
                    cell.imgVideoThumb.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder:PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVideoThumb.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
                        if objWallPost.sharedWallData?.urlArray.count ?? 0 > 0 {
                            cell.setVideoIcon(urlStr: objWallPost.sharedWallData?.urlArray.first ?? "")
                        }
                    }
                }else if  objWallPost.sharedWallData.thumbUrlArray.count == 0 {
                    cell.lblDesc.text = objWallPost.sharedWallData.payload
                    cell.lblDesc.isHidden = false
                }
            }
        }
        return cell
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.clickedMediaWith(index:indexPath.item, parentIndex: 0)
    }
    
    //MARK: - Follow Btn Action
    
    @objc func deleteClipVideo(_ sender : UIButton){
        
        delegate?.deleteMediaWith(index: sender.tag, parentIndex: 0)
        
    }
   
    
    @objc func editClipVideo(_ sender : UIButton){
        delegate?.editMediaWith(index: sender.tag, parentIndex: 0)
    }
    
    
}
