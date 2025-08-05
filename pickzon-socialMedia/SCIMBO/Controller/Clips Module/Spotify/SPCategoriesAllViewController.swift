//
//  SPCategoriesAllViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/1/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit


class SPCategoriesAllViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var clnView:UICollectionView!
    @IBOutlet weak var cnstntHtNavBar:NSLayoutConstraint!

    var arrItems:Array<SpotifyCategory> = Array()
    var offset:Int64 = 0
    var limit:Int64 = 50
    var total:Int64 = -1
    
    var onSongSelection:onSongSelectionDelegate?
    
    let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 20.0,
      bottom: 10.0,
      right: 20.0)
    let itemsPerRow: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstntHtNavBar.constant = self.getNavBarHt
        self.lblTitle.text = "All Categories"
        clnView.register(UINib(nibName: "SpotifyCategoriesCell", bundle: nil), forCellWithReuseIdentifier: "SpotifyCategoriesCell")
        
        // Do any additional setup after loading the view.
        self.fetchSpotifyCategories()
    }
    
    
    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func fetchSpotifyCategories()  {
        if arrItems.count == total {
            return
        }
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
       
       
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
        let languageCode = locale.languageCode
        print(countryCode, " ",languageCode)
        
        let param = "?limit=\(limit)&offset=\(offset)&country=\(countryCode)&locale=\(languageCode)"
        let url = "\(Constant.sharedinstance.spotifyCategoriesURL)\(param)"
        
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
                    let categories = payload["categories"] as? Dictionary<String, Any> ?? [:]
                    self.offset = categories["offset"] as? Int64 ?? 0
                    self.limit = categories["limit"] as? Int64 ?? 0
                    self.total = categories["total"] as? Int64 ?? 0
                    
                    let items = categories["items"] as? Array<Dictionary<String, Any>> ?? []
                    
                    for obj in items {
                        self.arrItems.append(SpotifyCategory.init(dict: obj))
                    }
                    
                    
                    self.clnView.reloadData()
                    
                    
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCategoriesCell", for: indexPath as IndexPath) as! SpotifyCategoriesCell
        
        let objSpotifyCategory = arrItems[indexPath.row]
        cell.lblName.text = objSpotifyCategory.name
        
        let arrIcons = objSpotifyCategory.icons
        if arrIcons.count > 0 {
            let icon = arrIcons.last
            let url = icon?["url"] as? String ?? ""
            cell.imgCategory.kf.setImage(with: URL(string: "\(url)"), placeholder: PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController:SPCategoriesPlayListVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPCategoriesPlayListVC") as! SPCategoriesPlayListVC
        let objSpotifyCategory = arrItems[indexPath.row]
        viewController.category =  objSpotifyCategory.id
        viewController.strTitle = objSpotifyCategory.name
        viewController.onSongSelection = self.onSongSelection
       // self.navigationController?.pushViewController(viewController, animated: true)
        self.pushView(viewController, animated: true)

    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.arrItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 150, height: 150)
    }*/
    
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
