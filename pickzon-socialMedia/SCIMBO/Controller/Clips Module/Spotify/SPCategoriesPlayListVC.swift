//
//  SPCategoriesPlayListVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/23/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit



class SPCategoriesPlayListVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    @IBOutlet weak var clnView:UICollectionView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    var strTitle = ""
    var category = ""
    var offset:Int64 = 0
    var limit:Int64 = 10
    var total:Int64 = -1
    var arrItems:Array<SPPlayList> = Array()
    
   weak var onSongSelection:onSongSelectionDelegate?
    
    let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 20.0,
      bottom: 10.0,
      right: 20.0)
    let itemsPerRow: CGFloat = 2
    let refreshControl = UIRefreshControl()
    var isFetchingData = false
    
    var isFeatured = false
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.lblTitle.text = strTitle
        clnView.register(UINib(nibName: "SpotifyCategoriesCell", bundle: nil), forCellWithReuseIdentifier: "SpotifyCategoriesCell")
        
        refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        clnView.alwaysBounceVertical = true
        clnView.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
        self.fetchspotifyCategoriesPlaylist()
    }
    
    @IBAction func backButtonAction(){
        
        
       
        self.navigationController?.popViewController(animated: true)

    }
    
    @objc func loadData() {
        self.total = -1
        self.arrItems.removeAll()
        self.clnView.reloadData()
        
        self.clnView.refreshControl?.beginRefreshing()
        self.fetchspotifyCategoriesPlaylist()
        self.clnView.refreshControl?.endRefreshing()
    }
    
    func fetchspotifyCategoriesPlaylist()  {
        
        if self.total != self.arrItems.count {
            isFetchingData = true
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
        
        self.offset =  Int64(arrItems.count)
            
          var param = ""
            var url = ""
            if isFeatured == true {
                 param = "?offset=\(offset)&limit=\(limit)"
                 url = "\(Constant.sharedinstance.featuredPlaylistURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }else {
                param = "?category=\(category)&limit=\(limit)&offset=\(offset)&country=\(countryCode)"
                url = "\(Constant.sharedinstance.spotifyCategoriesPlaylistURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }
            
        
        
        URLhandler.sharedinstance.makeGetAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    
                    let payload = result["payload"] as? Dictionary ?? [:]
                   
                    let playlists = payload["playlists"] as? Dictionary<String, Any> ?? [:]
                    self.offset = playlists["offset"] as? Int64 ?? 0
                    self.limit = playlists["limit"] as? Int64 ?? 0
                    self.total = playlists["total"] as? Int64 ?? 0
                    
                    if  let items = playlists["items"] as? Array<Dictionary<String, Any>> {
                        for obj in items {
                            self.arrItems.append(SPPlayList.init(dict: obj))
                        }
                    }else {
                        self.total = Int64(self.arrItems.count)
                    }
                    self.isFetchingData = false
                    self.clnView.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
                self.isFetchingData = false
            }
        })
        }
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCategoriesCell", for: indexPath as IndexPath) as! SpotifyCategoriesCell
        
        let objSpotifyCategory = arrItems[indexPath.row]
        cell.lblName.text = objSpotifyCategory.name
        let arrIcons = objSpotifyCategory.images
        if arrIcons.count > 0 {
            let icon = arrIcons.last
            let url = icon?["url"] as? String ?? ""
            cell.imgCategory.kf.setImage(with: URL(string: "\(url)"), placeholder:PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController:SPTrackVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPTrackVC") as! SPTrackVC
        let objPlaylist = arrItems[indexPath.row]
        viewController.playlistId =  objPlaylist.id
        viewController.strTitle = objPlaylist.name
        viewController.onSongSelection = self.onSongSelection
        self.navigationController?.pushViewController(viewController, animated: true)
        //self.pushView(viewController, animated: true)

    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.arrItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == arrItems.count - 1 {
            if isFetchingData == false {
            self.fetchspotifyCategoriesPlaylist()
            }
        }
    }
    
    
   /* func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        //return CGSize(width: 160, height: 204)
        return CGSize(width: self.view.frame.width/3 - 80, height: 204)
    }*/
    //UICollectionViewDelegateFlowLayout Delegate
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
        // 2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 180)
      }
      
      // 3
      func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
      ) -> UIEdgeInsets {
        return sectionInsets
      }
      
      // 4
      func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
      ) -> CGFloat {
        return sectionInsets.left
      }
    
    

}

class SPPlayList{
    
    var id:String = ""
    var images:Array<Dictionary<String, Any>>
    var name:String = ""
    var description:String = ""
    init(dict:Dictionary<String, Any>){
        self.images = dict["images"] as? Array<Dictionary<String, Any>> ?? Array()
        self.id = dict["id"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.description = dict["description"] as? String ?? ""
    }
}
