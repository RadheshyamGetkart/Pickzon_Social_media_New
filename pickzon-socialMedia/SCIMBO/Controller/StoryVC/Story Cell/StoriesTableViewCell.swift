//
//  StoriesTableViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/9/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import PhotosUI
import MobileCoreServices
import AVKit
import Kingfisher

enum OptionFeedType{
    
    case postFeed
    case reels
    case saved
    case createPage
    case creategroup
    case golive
    case postFeedWithCamera
    case postAds
}

protocol StoriesDelegate{
    
    func addNewStoryInFeeds(count:Int)
    func getSelectedStoriesIndex(index:Int)
    func selectedHeaderOptionsInFeeds(selectionType:OptionFeedType)

}

extension StoriesDelegate{
    
    func addNewStoryInFeeds(count:Int){}
    func getSelectedStoriesIndex(index:Int){}
    func selectedHeaderOptionsInFeeds(selectionType:OptionFeedType){}

}

class StoriesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    var optionArray = ["Post","Clip","Pages","Groups","Saved"] //"Go Live" ,"Camera"
    var optionImgArray = ["addPost","reels-1","CreatePage","CreateGroup","feedsSavePostRed"] //,"Camera"

    var statusArray:Array<WallStatus> = Array<WallStatus>()
    var delegate:StoriesDelegate?
    
    @IBOutlet weak var cvOption:UICollectionView!
    @IBOutlet weak var cvStories:UICollectionView!
    @IBOutlet weak var btnGoLive:UIButton!
    @IBOutlet weak var btnPhotos:UIButton!
    @IBOutlet weak var btnSave:UIButton!
    @IBOutlet weak var btnVideo:UIButton!
    var isAvailable = 0
    var urlSelectedItemsArray = Array<URL>()
    var fileName = ""
    var isUserStatusExist = false
   
    
   //MARK: - View Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Configure the view for the selected state
        cvStories.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        
        cvOption.register(UINib(nibName: "OptionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "OptionCollectionCell")

//        cvOption.delegate = self
//        cvOption.dataSource = self
//        cvOption.layoutSubviews()
        
        cvStories.delegate = self
        cvStories.dataSource = self
        cvStories.layoutSubviews()
       /*
        btnGoLive.layer.cornerRadius = btnGoLive.frame.height / 2.0
        btnGoLive.backgroundColor = UIColor(red: 216.0/255.0, green: 214.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
        btnPhotos.layer.cornerRadius = btnPhotos.frame.height / 2.0
        btnPhotos.backgroundColor = UIColor(red: 214.0/255.0, green: 235.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        
        btnSave.layer.cornerRadius = btnSave.frame.height / 2.0
        btnSave.backgroundColor = UIColor(red: 241.0/255.0, green: 214.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        
        btnVideo.layer.cornerRadius = btnVideo.frame.height / 2.0
        btnVideo.backgroundColor = UIColor(red: 196.0/255.0, green: 215.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        */
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK: - UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == cvOption{
          //  return optionArray.count
        }
        
        
        if statusArray.count == 0 && isAvailable == 0{
            return 1
        }
        if statusArray.count > 0 && isAvailable == 0{
            return (statusArray.count + 1)
        }
        
        return statusArray.count
        
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
     /*   if collectionView == cvOption{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCollectionCell", for: indexPath) as! OptionCollectionCell
            
            cell.btnTitle.tag = indexPath.item
            cell.btnTitle.addTarget(self, action: #selector(optionBtnAction(_ : )), for: .touchUpInside)
            cell.btnImage.layer.cornerRadius = cell.btnImage.frame.size.height / 2.0
            cell.btnTitle.clipsToBounds = true
            cell.btnImage.setImage(UIImage(named: optionImgArray[indexPath.item]), for: .normal)
            cell.lblTitle.text = optionArray[indexPath.item]
            
            return cell
        }
*/
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! StoryCollectionViewCell
        cell.layoutIfNeeded()
        cell.btnUserImage.isUserInteractionEnabled = false
        cell.btnUserImage.contentHorizontalAlignment = .fill
        cell.btnUserImage.contentVerticalAlignment = .fill
        cell.btnUserImage.imageView?.contentMode = .scaleAspectFill
        
        cell.btnUserImage.setImage(nil, for: .normal)
        cell.btnAdd.isHidden = true
        cell.btnAdd.addTarget(self, action: #selector(plusBtnAction), for: .touchUpInside)
       
        if indexPath.item == 0 {
            
            cell.btnUserImage.setBackgroundImage(nil, for: .normal)
            cell.btnAdd.isHidden = false
            cell.viewBack.numberOfStatus = CGFloat(0)
            cell.btnUserName.setTitle("Your story", for: .normal)
            
            let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
            cell.btnUserImage.kf.setImage(with: URL(string: profilePic) , for: .normal ,placeholder:UIImage(named: "avatar"),options: nil)
            
            if isAvailable == 1 {
                let obj = statusArray[indexPath.item]
                let status = obj.statusArray.first
                let strUrl = (status?.thumbnail.length ?? 0 > 0) ?  status?.thumbnail ?? ""  : status?.media ?? ""
                            
                if checkMediaTypes(strUrl: strUrl) == 1{
                    
                    cell.btnUserImage.kf.setImage(with: URL(string: strUrl), for: .normal , options: nil)
                }else{
                    
                    URLhandler.sharedinstance.getThumbnailImageFromVideoUrlToButton(videoUrlString: strUrl, btn: cell.btnUserImage, placeholderImage: UIImage(named: "avatar") ?? UIImage())
                }
                cell.viewBack.viewedStatusColour = .lightGray
                cell.viewBack.defaultStatusColour =  .systemBlue
                cell.viewBack.numberOfStatus = CGFloat((obj.statusArray.count))
                cell.viewBack.viewedStatusCount = CGFloat(self.countOfStatus(statusObj: obj))
            }
            
        }else {
    
            let obj = (isAvailable == 1) ? statusArray[indexPath.item] :  statusArray[indexPath.item-1]
            if  let status = obj.statusArray.first {
                
                let strUrl = (status.thumbnail.length > 0) ? status.thumbnail  : status.media
                cell.btnUserImage.setImage(nil, for: .normal)
                cell.viewBack.viewedStatusColour =  .lightGray
                cell.viewBack.defaultStatusColour =  .systemBlue//CustomColor.sharedInstance.themeColor
                cell.btnUserName.setTitle(obj.userInfo?.tiktokname ?? "", for: .normal)
                cell.viewBack.numberOfStatus = CGFloat((obj.statusArray.count))
                if checkMediaTypes(strUrl: strUrl) == 1{
                    cell.btnUserImage.kf.setImage(with: URL(string: strUrl), for: .normal , placeholder: UIImage(named: "avatar"), options: nil)
                }else{
                    URLhandler.sharedinstance.getThumbnailImageFromVideoUrlToButton(videoUrlString: strUrl, btn: cell.btnUserImage, placeholderImage: UIImage(named: "avatar") ?? UIImage())
                }
                cell.viewBack.viewedStatusCount = CGFloat(self.countOfStatus(statusObj: obj))
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
    /*    if collectionView == cvOption{
           
//            return CGSize(width: 80, height: 70)
            
            return CGSize(width: self.view.frame.size.width/4.0-5, height: 70)
        }
*/
        return CGSize(width: 80, height: 100)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
       /* if collectionView == cvOption{

            cvOption.deselectItem(at: indexPath, animated: true)
            
        }else{*/
        if isAvailable == 0 && indexPath.item == 0 {
            self.delegate?.addNewStoryInFeeds(count: 0)
        }else{
            self.delegate?.getSelectedStoriesIndex(index: indexPath.item)
        }
       // }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      /*
        if collectionView == cvOption{

        
        }*/
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
        
     func countOfStatus(statusObj:WallStatus) ->Int {
         
         var count = 0
         statusObj.statusArray.forEach({ messageFrame in
             
             let messageFrame : WallStatus.StoryStaus = messageFrame
             
             if(messageFrame.isSeen == 1)
             {
                 count = count + 1
             }
         })
         
         return count
     }
    
    //MARK: - Selector Methods
    @objc func optionBtnAction(_ sender : UIButton){
        
        if optionArray[sender.tag] == "Post"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .postFeed)

        }else if optionArray[sender.tag] == "Clip"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .reels)
       
        }else if optionArray[sender.tag] == "Saved"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .saved)
       
        }else if optionArray[sender.tag] == "Pages"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .createPage)
        
        }else if optionArray[sender.tag] == "Groups"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .creategroup)
        }else if optionArray[sender.tag] == "Go Live"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .golive)
        }else if optionArray[sender.tag] == "Camera"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .postFeedWithCamera)
        }else if optionArray[sender.tag] == "Post Ads"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .postAds)
        }

    }
    
    @objc func plusBtnAction(){
        if isAvailable == 1 {
            
            let obj = statusArray[0]
            
            if obj.statusArray.count < 5{
                self.delegate?.addNewStoryInFeeds(count: obj.statusArray.count)
                
            }else {
                
                self.view.makeToast(message: "You have reached to maximium limit.", duration: 1, position: HRToastActivityPositionDefault)
            }
        }else{
            self.delegate?.addNewStoryInFeeds(count: 0)
        }
        
    }
    
}
    
   
    
   




