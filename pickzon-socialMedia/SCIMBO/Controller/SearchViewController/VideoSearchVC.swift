//
//  VideoSearchVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 26/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class VideoSearchVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var srchTxt:String = ""
    private var isDataLoading = false
    private var mediaArray = [WallPostModel]()
    private var emptyView:EmptyList?
    private var isDataMoreAvailable = true
    private var pageNo = 1
     var delegate:SearchPostSelectedDelegate?

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ProfileMediaCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProfileMediaCellId")
        collectionView.delegate = self
        collectionView.dataSource = self
        getVideoSearhApi()
        NotificationCenter.default.addObserver(self, selector:
                                            #selector(self.videoSelectedTabIndex(notification:)),
                                           name: NSNotification.Name(rawValue: "videoSelectedTabIndex"), object: nil)
        }
        
        
        
        @objc func videoSelectedTabIndex(notification: Notification) {
            
            
            if  let response = notification.userInfo as? Dictionary<String, Any> {
                
                if let newToSearch = response["searchText"] as? String{
                   
                    if srchTxt == newToSearch{
                        
                    }else{
                        srchTxt = newToSearch
                        self.pageNo = 1
                        self.getVideoSearhApi()
                    }
                }
            }
        }
    //MARK: Api Methods
    func getVideoSearhApi(){
        
        self.isDataLoading = true
        
        if pageNo == 1{
            self.mediaArray.removeAll()
            self.collectionView.reloadData()
        }
            
      //let param:NSDictionary  = ["keyword":srchTxt,"pageNumber":pageNo]
        
        let strUtl = Constant.sharedinstance.search_video + "?pageNumber=\(pageNo)&keyword=\(srchTxt)"
        
        URLhandler.sharedinstance.makeCall(url:strUtl, param: nil, methodType: .get, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                // Themes.sharedInstance.RemoveactivityView(View: self.view)
                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
               // let message = result["message"] as? String ?? ""
                
                
                if status == 1{

                        let data = result.value(forKey: "payload") as? NSArray ?? []
                        for d in data
                        {
                            self.mediaArray.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                        }
                        self.emptyView?.isHidden = (self.mediaArray.count > 0) ? true : false
                        self.isDataMoreAvailable = (data.count > 5) ? true : false
                        self.pageNo = self.pageNo + 1
                        
                    
                    
                    self.collectionView.reloadWithoutAnimation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.isDataLoading = false
                    }
                }else{
                    self.isDataLoading = false
                    // Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
            }
        })
    }


}



//MARK: - UICollectionview delegate and datasource

extension VideoSearchVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        return CGSize(width: self.collectionView.frame.width/2.03, height: (self.collectionView.frame.width / 2.02) + 90 )
         
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   
        return mediaArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileMediaCellId", for: indexPath) as! ProfileMediaCell
        
        cell.imgVideoThumb.contentMode = .scaleAspectFill
        cell.imgVideoThumb.backgroundColor = UIColor.black
        cell.lblDesc.isHidden = true
        cell.lblDesc.backgroundColor = CustomColor.sharedInstance.newThemeColor
        cell.imgVwVideoIcon.isHidden = true
        cell.eye.isHidden = true
        cell.lblViewCount.isHidden = true
        cell.btnEditVideo.isHidden = true
        cell.btnDeleteVideo.isHidden = true
        
        cell.btnDeleteVideo.tag = indexPath.item
        cell.btnEditVideo.tag = indexPath.item
        
        guard let objWallPost = mediaArray[indexPath.item]  as? WallPostModel else{
            return UICollectionViewCell()
        }
     
            cell.eye.image = PZImages.eye
            cell.eye.isHidden = false
            cell.lblViewCount.isHidden = false
            cell.lblViewCount.text = mediaArray[indexPath.item].viewCount.asFormatted_k_String
            
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
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.isDataLoading == false && (mediaArray.count - 2) < indexPath.item{
            isDataLoading = true
            self.getVideoSearhApi()
        }
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

       // delegate?.clickedMediaWith(index:indexPath.item, parentIndex: 0)
        
        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        vc.selRowIndex = indexPath.item
        vc.arrwallPost = mediaArray
        vc.controllerType = .isFromRandomMedia
        vc.hashTag = srchTxt
        vc.pageNo = pageNo
        vc.title = "Posts"
        (AppDelegate.sharedInstance.navigationController?.topViewController)?.pushView(vc, animated: true)
    }
   
    
}
