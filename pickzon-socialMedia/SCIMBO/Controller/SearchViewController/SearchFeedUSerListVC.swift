//
//  SearchFeedUSerListVC.swift
//  SCIMBO
//
//  Created by Getkart on 16/07/21.
//  Copyright © 2021 GETKART. All rights reserved.
//

import UIKit
import Kingfisher
import IQKeyboardManager
import Alamofire

enum SearchType{
    case all
    case peoples
    case media
    case hashTag
    case users
    case videos
    case top
}


protocol SearchPostSelectedDelegate{
    
    func searchItemSelected(selObj:Any,type:SearchType)
}


extension SearchFeedUSerListVC :SearchPostSelectedDelegate{
   
    func searchItemSelected(selObj:Any,type:SearchType){
        
        if type == .top{
            
        }else if type == .videos{
            
        }else if type == .users{
            
            if let obj = selObj as? SearchedUser{
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn = obj.id
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
            
        }else if type == .hashTag{
            
        }
        
    }

}


extension SearchFeedUSerListVC : CAPSPageMenuDelegate,SearchTextDelegate {

    func searchedTxt(txt:String) {
        searchTf.text = txt
        checkAndUpdate()

    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int){
        print(index)
        selectedTabIndex = index
        checkAndUpdate()

    }

    func didMoveToPage(_ controller: UIViewController, index: Int){
        print(index)
           // pageMenu?.controllerArray[pageMenu?.currentPageIndex ?? 0].srchTxt = searchTf.text ?? ""
    }
    

    func checkAndUpdate(){
      
        var strNotificationName = ""
        if selectedTabIndex == 0{
            strNotificationName = "topSelectedTabIndex"
        }else  if selectedTabIndex == 1{
            strNotificationName = "videoSelectedTabIndex"

        }else  if selectedTabIndex == 2{
            strNotificationName = "accountSelectedTabIndex"
        }else if selectedTabIndex == 3{
            strNotificationName = "hashtagSelectedTabIndex"
        }
        
        let data: [String: Any] = [ "searchText":  searchTf.text ?? ""]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: strNotificationName), object: nil , userInfo: data)
    }

}


class SearchFeedUSerListVC: UIViewController,UITextFieldDelegate {
    
    
    var selectedTabIndex = 0
    
    @IBOutlet weak var cnstrntHtNavBar :NSLayoutConstraint!
    @IBOutlet weak var searchTf :UITextField!
   
    var strTxtSearched:String = ""
    private var pageMenu: CAPSPageMenu?

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController: SearchFeedUSerListVC")
        
        
        var controllerArray : [UIViewController] = []
        
        let topVc = StoryBoard.premium.instantiateViewController(withIdentifier: "TopSearchVC") as! TopSearchVC
        topVc.title = "Top"
        topVc.delegate = self
       // topVc.navController = self.navigationController
        controllerArray.append(topVc)
        
        let videoVC = StoryBoard.premium.instantiateViewController(withIdentifier: "VideoSearchVC") as! VideoSearchVC
        videoVC.title = "Video"
        topVc.delegate = self

       // peopleVC.navController = self.navigationController
        controllerArray.append(videoVC)
        
        
        let accountVC = StoryBoard.premium.instantiateViewController(withIdentifier: "AccountSearchVC") as! AccountSearchVC
        accountVC.title = "Accounts"
       // peopleVC.navController = self.navigationController
        
        topVc.delegate = self

        controllerArray.append(accountVC)
        
        let hashtagVC = StoryBoard.premium.instantiateViewController(withIdentifier: "HashTagSearchVC") as! HashTagSearchVC
        hashtagVC.title = "Hashtags"
       // peopleVC.navController = self.navigationController
        topVc.delegate = self

        controllerArray.append(hashtagVC)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(2.0),
            .menuItemSeparatorPercentageHeight(0.05),
            .menuItemWidth(self.view.frame.size.width/4-10),
            .centerMenuItems(true),
            .bottomMenuHairlineColor(UIColor.clear),
            .selectionIndicatorColor(CustomColor.sharedInstance.newThemeColor),
            .scrollMenuBackgroundColor(UIColor.systemBackground),
            .selectedMenuItemLabelColor(.label),
            .unselectedMenuItemLabelColor(.darkGray),
            .menuHeight(40),
            .selectionIndicatorHeight(2),
            .menuItemFont(UIFont.systemFont(ofSize: 16, weight: .medium)),
            
        ]
        
        cnstrntHtNavBar.constant = self.getNavBarHt
        let ht = cnstrntHtNavBar.constant + 10
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, ht, self.view.frame.width,self.view.frame.height-ht-(self.tabBarController?.tabBar.frame.height ?? 0)), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        pageMenu?.menuScrollView.isScrollEnabled = false
        pageMenu?.controllerScrollView.isScrollEnabled = false
        self.view.addSubview(pageMenu!.view)
      
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if cnstrntHtNavBar.constant != self.getNavBarHt + 10{
            cnstrntHtNavBar.constant = self.getNavBarHt + 10
            let ht = self.getNavBarHt + 10
            pageMenu?.view.frame = CGRectMake(0.0, ht, self.view.frame.width,self.view.frame.height-ht-(self.tabBarController?.tabBar.frame.height ?? 0))
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: notif_FeedLiked, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_FeedSaved, object: nil)
    }
    
    
    //MARK: UITextfield Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTf.text = searchTf.text?.trimmingLeadingAndTrailingSpaces()
        
        return true
    }
        
    //MARK: UIButton Action Methods
    
    @IBAction func txtFdBtnAction(sender:UIButton){
        
        let topVc = StoryBoard.premium.instantiateViewController(withIdentifier: "SearchSuggestionVC") as! SearchSuggestionVC
        topVc.delegate = self
        topVc.srchTxt = searchTf.text ?? ""
        self.navigationController?.pushViewController(topVc, animated: false)
    }
    
    
    
    @IBAction func searchEditing(_ sender: Any) {
        
//        if searchTf.text!.count > 0
//        {
//            searchBtnWidth.constant = 60.0
//        }else
//        {
//            searchBtnWidth.constant = 0
//        }
    }
    

    
}






