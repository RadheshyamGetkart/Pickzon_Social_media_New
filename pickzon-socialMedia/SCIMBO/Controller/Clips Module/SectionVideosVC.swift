//
//  SectionVideosVC.swift
//  SCIMBO
//
//  Created by Getkart on 28/05/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import Kingfisher

class SectionVideosVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dataCollection: UICollectionView!
//    @IBOutlet weak var txtFdSearch: UITextField!
    @IBOutlet weak var cnstrntHtNavBAr: NSLayoutConstraint!

    var pageNo = 1
    var hashtagKeyword = ""
    var totalPage = 0
    var pageLimit = 24
    var isDataLoading = false
    var clipsArray = [WallPostModel]()
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad(){
        super.viewDidLoad()
        cnstrntHtNavBAr.constant = self.getNavBarHt
        registerCell()
        titleLbl.text = "#" + hashtagKeyword.replacingOccurrences(of: "#", with: "")
        dataCollection.dataSource = self
        registerObjservers()
        getHashtagClipsApi(showLoader: true)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(notif_FeedFollowed.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name:
                                                    NSNotification.Name(PickZon.notif_FeedLiked.rawValue),
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(PickZon.notif_FeedRemoved.rawValue),
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(PickZon.notif_ClipCommentCount.rawValue),
                                                  object: nil)
    }
    
    //MARK: Other helpful methods
    
    func registerCell(){
        dataCollection.register(UINib(nibName: "ProfileMediaCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProfileMediaCellId")
    }
    
    //MARK: UIButton Action Methods
    @IBAction func backBtnAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Other Helpful Methods
    
    func registerObjservers(){
        // Register to receive notification
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedsLikedReceivedNotification(notification:)), name: notif_FeedLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedRemovedNotification(notification:)), name: notif_FeedRemoved,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)), name: notif_TagRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedCommentAddedNotification(notification:)), name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedSavedNotification(notification:)), name: nofit_FeedSaved,
                                               object: nil)
    }
    
    
    //MARK: UITextfield Delegate Methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchUserVideosVC") as! SearchUserVideosVC
        // navigationController?.pushViewController(vc, animated: false)
        return false
    }
    
    
    //MARK: API Methods
    func getHashtagClipsApi(showLoader:Bool) {
        
        self.isDataLoading = true
        
        if showLoader == true {
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        }
        let url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&hashtag=\(hashtagKeyword.replacingOccurrences(of: "#", with: ""))"
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
            self.isDataLoading = false
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            if(error != nil)
            {
                DispatchQueue.main.async {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1 {
                    
                    if let data = result["payload"] as? NSArray {
                        for obj in data {
                            self.clipsArray.append(WallPostModel(dict: obj as! NSDictionary))
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.dataCollection.reloadData()
                    }
                    self.pageNo = self.pageNo + 1
                    self.isDataLoading = false
                    
                } else  {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                    
                }
            }
        })
        
    }
    
}

//MARK: UICollectionView Delegate & Datasource Methods
extension SectionVideosVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.dataCollection.frame.width/3.01, height: (self.dataCollection.frame.width / 3.0) + 70)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return clipsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = dataCollection.dequeueReusableCell(withReuseIdentifier: "ProfileMediaCellId", for: indexPath) as! ProfileMediaCell
        cell.imgVideoThumb.contentMode = .scaleAspectFill
        cell.imgVideoThumb.backgroundColor = UIColor.black
        cell.lblDesc.backgroundColor = UIColor.systemBlue
        cell.imgVwVideoIcon.isHidden = true
        cell.lblDesc.isHidden = true
        cell.btnEditVideo.isHidden = true
        cell.btnDeleteVideo.isHidden = true
        cell.eye.isHidden = false
        cell.lblViewCount.isHidden = false
        cell.imgVideoThumb.layer.cornerRadius = 0
        cell.eye.image = PZImages.playBlank
        cell.lblViewCount.text = clipsArray[indexPath.item].viewCount.asFormatted_k_String
        cell.imgVideoThumb.kf.setImage(with: URL(string: clipsArray[indexPath.item].thumbUrlArray.first ?? ""), placeholder: PZImages.dummyCover, options: [.cacheMemoryOnly], progressBlock: nil) { response in }
        
        return cell
    }
        
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height + 100) >= scrollView.contentSize.height){
            
            if isDataLoading == false {
                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                    return
                }
                if !isDataLoading {
                    self.isDataLoading = true
                    self.getHashtagClipsApi(showLoader: false)
                }
            }
        }
    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
        vc.objWallPost = self.clipsArray[indexPath.item]
        vc.firstVideoIndex = 0
        vc.videoType = .feed
        vc.isHashTagVideos = true
        vc.hashTag = hashtagKeyword
        vc.isRandomVideos = false
        vc.arrFeedsVideo = clipsArray
        vc.isClipVideo = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: NSNotification Observers methods
    
    @objc func feedCommentAddedNotification(notification: Notification) {
        
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let commentText = objDict["commentText"] as? String ?? ""
            let isFromShared = objDict["isFromShared"] as? Bool ?? false
            let isFromDelete = objDict["isFromDelete"] as? Bool ?? false
            let commentCount = objDict["commentCount"] as? UInt ?? 0
            
            if let selPostIndex = clipsArray.firstIndex(where:{$0 .id == feedId}) {
                guard  var objWallPost = clipsArray[selPostIndex] as? WallPostModel else{
                    return
                }
                
                let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                objWallPost.totalComment = count
                objWallPost.totalComment = commentCount
                clipsArray[selPostIndex] = objWallPost
            }
        }
    }
    
    
    @objc func feedsLikedReceivedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isLike = objDict["isLike"] as? Int16 ?? 0
            let likeCount = objDict["likeCount"] as? UInt ?? 0
            
            if let objIndex = clipsArray.firstIndex(where:{$0.id == feedId}) {
                var objWallPost = clipsArray[objIndex] as! WallPostModel
                objWallPost.isLike = isLike
                objWallPost.totalLike = likeCount
                self.clipsArray[objIndex] = objWallPost
            }
        }
    }
    
    
    @objc func feedRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = clipsArray.firstIndex(where:{$0.id == feedId}) {
                
                DispatchQueue.main.async {
                    self.clipsArray.remove(at: objIndex)
                    self.dataCollection.reloadWithoutAnimation()
                    
                }
                
            }
        }
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = clipsArray.firstIndex(where:{$0.id == feedId}) {
                
                if var objWallpost = clipsArray[objIndex] as? WallPostModel {
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                    self.clipsArray[objIndex] = objWallpost
                    DispatchQueue.main.async {
                        self.dataCollection.reloadData()
                    }
                }
                
            }
        }
    }
    
    
    @objc func feedFollwedNotification(notification: Notification) {
        
        print("FeedsVideoViewController : Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            
            for index in 0..<clipsArray.count {
                var  objWallPost = clipsArray[index]
                
                if objWallPost.userInfo?.id == userId {
                    objWallPost.isFollowed = isFollowed
                    clipsArray[index] = objWallPost
                }
                
                if objWallPost.sharedWallData != nil && objWallPost.sharedWallData.userInfo?.id == userId{
                    objWallPost.sharedWallData.isFollowed = isFollowed
                    clipsArray[index] = objWallPost
                }
            }
        }
    }
    
    
    @objc func feedSavedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            
            let feedId = objDict["feedId"] as? String ?? ""
            let isSave = objDict["isSave"] as? Int16 ?? 0
            
            if let objIndex = clipsArray.firstIndex(where:{$0.id == feedId}) {
                
                clipsArray[objIndex].isSave = isSave
            }
        }
    }
}
