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
}


class SearchFeedUSerListVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var searchBtnWidth :NSLayoutConstraint!
    @IBOutlet weak var searchTf :UITextField!
    @IBOutlet weak var searchtbl :UITableView!
    @IBOutlet weak var btnAll:UIButton!
    @IBOutlet weak var btnUsers:UIButton!
    @IBOutlet weak var btnHashTag:UIButton!
    @IBOutlet weak var btnMedia:UIButton!
    @IBOutlet weak var lblSeperator:UILabel!
    
    var feedSectionNo = 1
    var searchType:SearchType?
    var arrSearchHistory = [SearchHistory]()
    var arrFriendSuggestionList = [SearchedUser]()
    var arrPeopleList = [SearchedUser]()
    var arrHashTagList = [WallPostModel]()
    var arrMediaList = [WallPostModel]()
    var isDataLoading = false
    var pageNo = 1
    var pageNo_HashTag = 1
    var pageNo_Media = 1
    var isDataMoreAvailable = true
    var searchedString = ""
    var emptyView:EmptyList?
    var hashSearchText = ""
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    var strTxtSearched:String = ""
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController: SearchFeedUSerListVC")
        searchTf.delegate = self
        searchType = .peoples
        self.searchtbl.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        lblSeperator.frame =  CGRect(x: btnUsers.frame.origin.x + 5, y: btnUsers.frame.origin.y+btnUsers.frame.size.height-1, width: btnUsers.frame.size.width, height: 3)
        searchTf.becomeFirstResponder()
        registerCell()
        searchtbl.keyboardDismissMode = .onDrag
        
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: searchtbl.frame.size.width, height: searchtbl.frame.size.height + 64))
        emptyView?.imageView?.image = PZImages.noData
        emptyView?.lblMsg?.text = "No match found"
        self.searchtbl.addSubview(emptyView!)
        emptyView?.isHidden = true
        
        searchtbl.refreshControl = topRefreshControl
        
        addObservers()
        self.pageNo = 1
        
        self.btnUsers.setTitleColor(.label, for: .normal)
        self.btnHashTag.setTitleColor(.lightGray, for: .normal)
        self.btnMedia.setTitleColor(.lightGray, for: .normal)
        
        if hashSearchText.length == 0 {
            searchType = .peoples
            self.searchTf.placeholder = "Search People"
            searchKeywordApi()
            
        }else {
            searchType = .hashTag
            self.searchTf.placeholder = "Search #Tag"
            self.searchTf.text = hashSearchText
            self.btnHashTag.updateConstraints()
            self.commonButtonAction(sender: self.btnHashTag)
        }
        searchtbl.reloadData()
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
    
    
    func registerCell(){
        searchtbl.register(UINib(nibName: "SearchHistoryCell", bundle: nil),
                           forCellReuseIdentifier: "SearchHistoryCell")
        
        searchtbl.register(UINib(nibName: "PeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "PeopleTableViewCell")
        searchtbl.register(UINib(nibName: "BusinessMediaTblCell", bundle: nil),
                           forCellReuseIdentifier: "BusinessMediaTblCell")
        
        searchtbl.register(UINib(nibName: "LoadMoreTblCell", bundle: nil),
                           forCellReuseIdentifier: "LoadMoreTblCell")
    }
    
    func addObservers(){
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedsLikedReceivedNotification(notification:)), name: notif_FeedLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedRemovedNotification(notification:)), name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_TagRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)), name: notif_TagRemoved, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedCommentAddedNotification(notification:)), name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedSavedNotification(notification:)), name: nofit_FeedSaved, object: nil)
    }
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading{
            self.isDataLoading = true
            self.isDataMoreAvailable = false
            
            if  searchType == .peoples{
                pageNo = 1
                self.arrPeopleList.removeAll()
            }else if searchType == .hashTag{
                pageNo_HashTag = 1
                arrHashTagList.removeAll()
            }else if searchType == .media{
                pageNo_Media = 1
                arrMediaList.removeAll()
            }
            self.searchtbl.reloadData()
            self.searchKeywordApi()
        }
        refreshControl.endRefreshing()
    }
    
    
   
    
    //MARK: UITextfield Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        arrSearchHistory.removeAll()
        searchTf.text = searchTf.text?.trimmingLeadingAndTrailingSpaces()
        emptyView?.isHidden = true
        
        if (searchTf.text?.count ?? 0) > 0{
            if  searchType == .all {
                if searchTf.text!.length > 0 {
                    searchKeywordApi()
                }
            }else  if  searchType == .peoples {
                pageNo = 1
                arrPeopleList.removeAll()
                self.searchtbl.reloadData()
                searchKeywordApi()
            }else if  searchType == .media {
                pageNo_Media = 1
                self.arrMediaList.removeAll()
                self.searchtbl.reloadData()
                
                searchKeywordApi()
                
            }else {
                searchKeywordApi()
            }
        }
        return true
    }
    
    
    
    //MARK: UIButton Action Methods
    @IBAction func commonButtonAction(sender:UIButton){
       
        arrSearchHistory.removeAll()
        searchTf.text = searchTf.text?.trimmingLeadingAndTrailingSpaces()
        
        self.btnUsers.setTitleColor(.lightGray, for: .normal)
        self.btnHashTag.setTitleColor(.lightGray, for: .normal)
        self.btnMedia.setTitleColor(.lightGray, for: .normal)
        sender.setTitleColor(.label, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height-2, width: sender.frame.size.width, height: 3)
            self.lblSeperator.updateConstraints()
        })
        
        if sender.tag == 1000{
            
            searchType = .all
            if searchTf.text?.length ?? 0 > 0{
                searchKeywordApi()
            }else {
                searchGlobalListingAPI()
            }
            searchtbl.reloadData()
            
        }else if sender.tag == 1001{
            self.pageNo = 1
            searchType = .peoples
            self.searchTf.placeholder = "Search People"
            searchKeywordApi()
            searchtbl.reloadData()
            
        }else if sender.tag == 1004{
            searchType = .hashTag
            self.pageNo_HashTag = 1
            self.searchTf.placeholder = "Search #Tag"
            searchKeywordApi()
            searchtbl.reloadData()
        }else if sender.tag == 1005{
            searchType = .media
            self.pageNo_Media = 1
            self.searchTf.placeholder = "Search Media"
            searchKeywordApi()
            searchtbl.reloadData()
        }
    }
    
    
    @IBAction func searchEditing(_ sender: Any) {
        
        if searchTf.text!.count > 0
        {
            searchBtnWidth.constant = 60.0
        }else
        {
            searchBtnWidth.constant = 0
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func searchBtn(_ sender: Any) {
        view.endEditing(true)
        arrSearchHistory.removeAll()
        searchTf.text = searchTf.text?.trimmingLeadingAndTrailingSpaces()
        emptyView?.isHidden = true
        
        if  searchType == .all {
            if searchTf.text!.length > 0 {
                searchKeywordApi()
            }
        }else  if  searchType == .peoples {
            pageNo = 1
            arrPeopleList.removeAll()
            self.searchtbl.reloadData()
            searchKeywordApi()
        }else if  searchType == .media {
            pageNo_Media = 1
            self.arrMediaList.removeAll()
            self.searchtbl.reloadData()
            
            searchKeywordApi()
            
        }else if searchType == .hashTag{
            pageNo_HashTag = 1
            searchKeywordApi()
        } else {
            searchKeywordApi()
        }
        
    }
    
    
    //MARK: APi Methods
    func searchGlobalListingAPI(){
        
        self.isDataLoading = true
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.globalSearchListingURL, param: NSDictionary(), completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    
                    let payload = result.value(forKey: "payload") as? NSDictionary ?? [:]
                    
                    let dataHistory = payload.value(forKey: "searchHistory") as? NSArray ?? []
                    for d in dataHistory
                    {
                        self.arrSearchHistory.append(SearchHistory(dict: d as? NSDictionary ?? [:]))
                    }
                    
                    let dataFriendSuggestion  = payload.value(forKey: "friendSuggestedList") as? NSArray ?? []
                    for d in dataFriendSuggestion
                    {
                        //self.arrFriendSuggestionList.append(SearchedUser(dict: d as? NSDictionary ?? [:]))
                        self.arrPeopleList.append(SearchedUser(dict: d as? NSDictionary ?? [:]))
                    }
                    
                    self.searchtbl.reloadAnimately{}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.isDataLoading = false
                    }
                }
                else
                {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                    
                }
            }
        })
        
        
        
    }
    
    func searchSuggestiongAPI()
    {
        self.isDataLoading = true
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        let param:NSDictionary =  ["keyword":searchedString]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.searchSuggestionURL, param: param, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.arrSearchHistory.removeAll()
                    
                    let dataHistory = result.value(forKey: "payload") as? NSArray ?? []
                    for d in dataHistory
                    {
                        self.arrSearchHistory.append(SearchHistory(dict: d as? NSDictionary ?? [:]))
                    }
                    
                    self.emptyView?.isHidden = true
                    self.searchtbl.reloadAnimately{}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.isDataLoading = false
                    }
                }
                else
                {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        
    }
    
    
    
    @objc func clearSearchHistory(sender:UIButton){
        self.isDataLoading = true
        
        Themes.sharedInstance.activityView(View: self.view)
        var param = NSDictionary()
        print ("sender.tag: \(sender.tag)")
        if sender.tag == 100 {
            param  = ["type":"all"]
            
        }else {
            let objSearch = arrSearchHistory[sender.tag]
            param  = ["type":"one","clearId":objSearch.id]
            
        }
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.clearSearchHistory as String, param: param, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                //  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    if sender.tag == 100 {
                        self.arrSearchHistory.removeAll()
                    }else {
                        self.arrSearchHistory.remove(at: sender.tag)
                    }
                    self.searchtbl.reloadData()
                }
                else
                {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                    
                }
            }
        })
        
    }
    
    
    func searchKeywordApi(){
        
        self.isDataLoading = true
        
        if pageNo == 1  && searchType == .peoples{
            self.arrPeopleList.removeAll()
            self.searchtbl.reloadData()
        }else if pageNo_HashTag == 1 && searchType == .hashTag{
            arrHashTagList.removeAll()
            self.searchtbl.reloadData()
        }else if pageNo_Media == 1 && searchType == .media{
            arrMediaList.removeAll()
            self.searchtbl.reloadData()
        }
        
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
        // Themes.sharedInstance.activityView(View: self.view)
        
        var param = NSDictionary()
        var url = Constant.sharedinstance.SearchKeyWord
        
        if searchType == .all{
            param  = ["type":"all","keyword":searchTf.text!]
            
        }else if searchType == .peoples{
            param  = ["type":"users","keyword":searchTf.text!,"pageNumber":pageNo, "pageLimit":21]
            
        }else if searchType == .media{
            param  = ["keyword":searchTf.text!,"pageNumber":pageNo_Media]
            url = Constant.sharedinstance.SearchMediaURL
        }else if searchType == .hashTag{
            param  = ["type":"hashTag","keyword":searchTf.text!,"pageNumber":pageNo_HashTag, "pageLimit":21]
            
        }
        
        
        URLhandler.sharedinstance.makeCall(url:url, param: param, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                // Themes.sharedInstance.RemoveactivityView(View: self.view)
                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }else{
                self.strTxtSearched = self.searchTf.text!
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
               // let message = result["message"] as? String ?? ""
                
                
                if status == 1{

                    if self.searchType == .all{
                        let payload = result.value(forKey: "payload") as? NSDictionary ?? [:]
                        let dataFriendSuggestion  = payload.value(forKey: "usersList") as? NSArray ?? []
                        self.arrFriendSuggestionList.removeAll()
                        for d in dataFriendSuggestion
                        {
                            self.arrFriendSuggestionList.append(SearchedUser(dict: d as? NSDictionary ?? [:]))
                        }
                        
                        self.emptyView?.isHidden = (self.arrFriendSuggestionList.count > 0) ? true : false
                        
                    }else if self.searchType == .peoples{
                        let data = result.value(forKey: "payload") as? NSArray ?? []
                        for d in data
                        {
                            self.arrPeopleList.append(SearchedUser(dict: d as? NSDictionary ?? [:]))
                        }
                        self.emptyView?.isHidden = (self.arrPeopleList.count > 0) ? true : false
                        self.isDataMoreAvailable = (data.count > 5) ? true : false
                        self.pageNo = self.pageNo + 1
                        
                    }else if self.searchType == .hashTag {
                        let data = result.value(forKey: "payload") as? NSArray ?? []
                        for d in data
                        {
                            self.arrHashTagList.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                        }
                        self.emptyView?.isHidden = (self.arrHashTagList.count > 0) ? true : false
                        self.isDataMoreAvailable = (data.count > 5) ? true : false
                        self.pageNo_HashTag = self.pageNo_HashTag + 1
                        
                    }else if self.searchType == .media {
                        let data = result.value(forKey: "payload") as? NSArray ?? []
                        for d in data
                        {
                            self.arrMediaList.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                        }
                        self.emptyView?.isHidden = (self.arrMediaList.count > 0) ? true : false
                        self.isDataMoreAvailable = (data.count > 5) ? true : false
                        self.pageNo_Media = self.pageNo_Media + 1
                        
                    }
                    
                    self.searchtbl.reloadAnimately{}
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
    
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        if searchType == .peoples {
            profileVC.otherMsIsdn = arrPeopleList[sender?.view?.tag ?? 0].id.length > 0 ? arrPeopleList[sender?.view?.tag ?? 0].id : arrPeopleList[sender?.view?.tag ?? 0].id
        }else {
            profileVC.otherMsIsdn = arrFriendSuggestionList[sender?.view?.tag ?? 0].id
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func openProfile(sender:UIButton){
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        if searchType == .peoples {
            profileVC.otherMsIsdn = arrPeopleList[sender.tag].id.length > 0 ? arrPeopleList[sender.tag].id : arrPeopleList[sender.tag].id
        }else {
            profileVC.otherMsIsdn = arrFriendSuggestionList[sender.tag].id
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    @objc func followUser(sender:UIButton) {
        
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.searchtbl)
        let indexPath = self.searchtbl.indexPathForRow(at: buttonPosition)
        
        var userId = ""
        var status:Int = 0
        if searchType == .all {
            userId = arrFriendSuggestionList[sender.tag].id
            status = arrFriendSuggestionList[sender.tag].isFollow == 1 ? 0 : 1
        }else {
            userId = arrPeopleList[sender.tag].id
            status = arrPeopleList[sender.tag].isFollow == 1 ? 0 :1
        }
        
        let param:NSDictionary = ["followedUserId":userId,"status":"\(status)"]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            } else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                    
                    if self.searchType == .all {
                        self.arrFriendSuggestionList[sender.tag].isFollow = isFollow
                       
                        if let cell = self.searchtbl.cellForRow(at: indexPath!) as? PeopleTableViewCell {
                        
                        cell.btnFollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: isFollow), for: .normal)
                        cell.btnFollow.setImage((isFollow == 0 || isFollow == 3) ? PZImages.followPlus :  PZImages.followCheckWhite , for: .normal)
                           
                        }
                        
                    }else {
                        self.arrPeopleList[sender.tag].isFollow = isFollow
                        
                        if let cell = self.searchtbl.cellForRow(at: indexPath!) as? PeopleTableViewCell {
                            
                            cell.btnFollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: isFollow), for: .normal)
                            cell.btnFollow.setImage((isFollow == 0 || isFollow == 3) ? PZImages.followPlus :  PZImages.followCheckWhite , for: .normal)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message, duration: 1, position: HRToastActivityPositionDefault)
                    }
                }
                else
                {
                    self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    @objc func followUnfollowAction(_ sender:UIButton){
        
    }
    
}

extension SearchFeedUSerListVC:UITableViewDelegate,UITableViewDataSource {
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchType == .all {
            return 4
        }else {
            return  3
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == 0{
            return arrSearchHistory.count
        }else if section == 2{
            return (isDataMoreAvailable) ? 1 : 0
            
        }else if searchType == .peoples {
            return self.arrPeopleList.count
        }else if self.searchType == .hashTag {
            //arrHashTagList.count
            return (arrHashTagList.count > 0) ? 1 : 0
        }else if self.searchType == .media {
            return (arrMediaList.count > 0) ? 1 : 0

        }else if searchType == .all {
            
            if section == 1 {
                return arrFriendSuggestionList.count
            }else if section == 2 {
                //Page Suggestions
                return  0

            }else{
                //Group Suggestions
                  return  0
           }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"SearchHistoryCell") as! SearchHistoryCell
            let objSuggestion = arrSearchHistory[indexPath.row]
            cell.lblText.text =  objSuggestion.text
            cell.selectionStyle = .none
            return cell
            
        }else if indexPath.section == 2{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            cell.activityIndicator.startAnimating()
            return cell
        }else if searchType == .peoples {
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"PeopleTableViewCell") as! PeopleTableViewCell
            cell.selectionStyle = .none
            let objSuggestion = arrPeopleList[indexPath.row]
            cell.profilePicView.setImgView(profilePic: objSuggestion.profilePic, frameImg: objSuggestion.avatar,changeValue: (objSuggestion.avatar.count > 0) ? 8 : 5)
                        cell.profilePicView?.imgVwProfile?.tag = indexPath.row
            cell.profilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.handleProfilePicTap(_:))))
           
            cell.btnName.tag = indexPath.row
            cell.btnName.setTitle(objSuggestion.pickzonId, for: .normal)
            cell.btnName.addTarget(self, action: #selector(openProfile(sender:)), for: .touchUpInside)

            if objSuggestion.headline.length > 0 && objSuggestion.jobProfile.length > 0{
                cell.lblDesig.text = objSuggestion.jobProfile + " | " + objSuggestion.headline
            }else if objSuggestion.jobProfile.length > 0 {
                cell.lblDesig.text = objSuggestion.jobProfile
            }else if objSuggestion.headline.length > 0 {
                cell.lblDesig.text = objSuggestion.headline
            }else {
                cell.lblDesig.text = "\(objSuggestion.name)"
            }
            cell.lblLocation.text = objSuggestion.location
            cell.btnFollow.tag = indexPath.row
            
            switch objSuggestion.celebrity{
            case 1:
                cell.imgCelebrity.isHidden = false
                cell.imgCelebrity.image = PZImages.greenVerification
            case 4:
                cell.imgCelebrity.isHidden = false
                cell.imgCelebrity.image = PZImages.goldVerification
            case 5:
                cell.imgCelebrity.isHidden = false
                cell.imgCelebrity.image = PZImages.blueVerification
            default:
                cell.imgCelebrity.isHidden = true
            }
            
          
            if objSuggestion.isFollow > 0 {
                cell.btnFollow.isHidden = true
            }else if objSuggestion.id == Themes.sharedInstance.Getuser_id() {
                cell.btnFollow.isHidden = true
            }else {
                if objSuggestion.isBlock == 0{
                    cell.btnFollow.isHidden = false
                    cell.btnFollow.setImage((objSuggestion.isFollow == 0 || objSuggestion.isFollow == 3) ? PZImages.followPlus : PZImages.followCheckWhite, for: .normal)
                    cell.btnFollow.setTitle((objSuggestion.isFollow == 0 || objSuggestion.isFollow == 3) ? "Follow" : "Unfollow", for: .normal)
                    cell.btnFollow.addTarget(self, action: #selector(followUser(sender:)), for: .touchUpInside)
                }else {
                    cell.btnFollow.isHidden = true
                }
            }
            
            return cell
            
        }else if searchType == .hashTag{
           
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"BusinessMediaTblCell") as! BusinessMediaTblCell
            cell.wallPostArray = self.arrHashTagList
            cell.delegate = self
            cell.isClipsVideo = false
            cell.isToHideOption = false
            cell.cllctnVw.reloadData()
            return cell
            
        }else if searchType == .media{
            
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"BusinessMediaTblCell") as! BusinessMediaTblCell
            cell.wallPostArray = self.arrMediaList
            cell.delegate = self
            cell.isClipsVideo = true
            cell.isToHideOption = true
            cell.cllctnVw.reloadData()
            return cell
       
        }
       
        return UITableViewCell()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            searchTf.text =  arrSearchHistory[indexPath.row].text
            arrSearchHistory.removeAll()
            self.searchKeywordApi()
        }else if searchType == .peoples {
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = arrPeopleList[indexPath.row].id.length > 0 ? arrPeopleList[indexPath.row].id : arrPeopleList[indexPath.row].id
            self.navigationController?.pushViewController(profileVC, animated: true)
        }else if searchType == .all {
            if indexPath.section == 1 {
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn = arrFriendSuggestionList[indexPath.row].id
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }
    
      
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 || indexPath.section == 0{
            return  UITableView.automaticDimension
        }
        
        if searchType == .media {
            
            return  calculateHeightWithArray(withArray: arrMediaList, extraHt: 70)
            
        }else if searchType == .hashTag {
            
            return calculateHeightWithArray(withArray: arrHashTagList, extraHt: 10)
            
        }else {
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0  {
            if arrSearchHistory.count == 0{
                return nil
            }
            var vw = UIView()
            vw = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 50))
            let lbl = UILabel(frame:CGRectMake(10, 10, 200, 30))
            lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            lbl.text = "Search Suggestions"
            vw.addSubview(lbl)
            return vw
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            if arrSearchHistory.count > 0 {
                return 50
            }
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
  
        if (indexPath.section == 2 && indexPath.row == 0)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            if !isDataLoading {
                
                if (searchType == .peoples) {
                    isDataLoading = true
                    self.searchKeywordApi()
                }else if searchType == .hashTag {
                    isDataLoading = true
                    self.searchKeywordApi()
                }else if searchType == .media {
                    isDataLoading = true
                    self.searchKeywordApi()
                }
            }
        }
    }
   
    
    
  
    //MARK: Calculating row height

    func calculateHeightWithArray(withArray:[Any],extraHt:Int) -> CGFloat{
        
        let width = CGFloat(self.view.frame.size.width/3.0) + CGFloat(extraHt)
        let divide =  CGFloat( withArray.count/3) * width
        var remainder =  CGFloat(withArray.count % 3) * width
        if  (withArray.count % 3) > 0 && withArray.count % 3 < 3{
            remainder = width
        }else{
            remainder = 0
        }
        return  CGFloat(divide + remainder)
    }
        
    
    //MARK: Selector Methods
    @objc func seeAllFriendSuggestion(sender:UIButton){
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        let viewController:SuggestionListVC = storyboard.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
        self.navigationController?.pushView(viewController, animated: true)
    }
    
}

extension SearchFeedUSerListVC:BusinessMediaDelegate {
   
    func clickedAllMedia(parentIndex: Int) {
        
    }
    
    func clickedMediaWith(index:Int, parentIndex:Int) {
        if searchType == .media {
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
//            var arr = arrMediaList
//            if index > 0 {
//                arr.removeSubrange(ClosedRange(uncheckedBounds: (lower: 0, upper: index-1)))
//            }
            vc.selRowIndex = index
            vc.arrwallPost = arrMediaList
            vc.controllerType = .isFromRandomMedia
            vc.hashTag = strTxtSearched
            vc.pageNo = pageNo_Media
            vc.title = "Posts"
            //vc.delegate = self
            //vc.followMsIsdn = followMsIsdn
            //vc.totalPageNo = totalPageNo
            //
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else  if searchType == .hashTag {
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            vc.selRowIndex = index
            vc.arrwallPost = arrHashTagList
            vc.controllerType = .hashTagSearched
            vc.hashTag = strTxtSearched
            vc.pageNo = pageNo_HashTag
            //vc.delegate = self
            //vc.followMsIsdn = followMsIsdn
            //vc.totalPageNo = totalPageNo
            //
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}



extension SearchFeedUSerListVC {
    
    @objc func feedCommentAddedNotification(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let commentText = objDict["commentText"] as? String ?? ""
            let isFromShared = objDict["isFromShared"] as? Bool ?? false
            let isFromDelete = objDict["isFromDelete"] as? Bool ?? false
            let commentCount = objDict["commentCount"] as? Int16 ?? 0
            
            
            if searchType == .media{
                
                if let selPostIndex = arrMediaList.firstIndex(where:{$0.id == feedId}) {
                    
                    var objWallPost = arrMediaList[selPostIndex]
                    let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                    objWallPost.totalComment = count
                    arrMediaList[selPostIndex] = objWallPost
                }
            }else{
                
            if let selPostIndex = arrHashTagList.firstIndex(where:{$0.id == feedId}) {
                var objWallPost = arrHashTagList[selPostIndex]
                let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                objWallPost.totalComment = count
                arrHashTagList[selPostIndex] = objWallPost
            }
        }
    }
         
    }
    
    @objc func feedsLikedReceivedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isLike = objDict["isLike"] as? Int16 ?? 0
            let likeCount = objDict["likeCount"] as? UInt ?? 0

            if searchType == .media {
                
                if let objIndex = arrMediaList.firstIndex(where:{$0.id == feedId}) {
                    
                    var objWallPost = arrMediaList[objIndex]
                    objWallPost.isLike = isLike
                    objWallPost.totalLike = likeCount
                    arrMediaList[objIndex] = objWallPost
                }
            }else{
                
                if let objIndex = arrHashTagList.firstIndex(where:{$0.id == feedId}) {
                    var objWallPost = arrHashTagList[objIndex]
                    objWallPost.isLike = isLike
                    objWallPost.totalLike = likeCount
                    arrHashTagList[objIndex] = objWallPost
                    
                }
                
            }
        }
    }
    
    @objc func feedRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
                let feedId = objDict["feedId"] as? String ?? ""
                
            if searchType == .media{
                
                if let objIndex = arrMediaList.firstIndex(where:{$0.id == feedId}) {
                    self.arrMediaList.remove(at: objIndex)
                    self.searchtbl.reloadData()
                }
                }else{
                    if let objIndex = arrHashTagList.firstIndex(where:{$0.id == feedId}) {
                        
                        DispatchQueue.main.async {
                            self.arrHashTagList.remove(at: objIndex)
                            self.searchtbl.reloadData()
                        }
                    }
                }
        }
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if searchType == .media{
                
                if let objIndex = arrMediaList.firstIndex(where:{$0.id == feedId}) {
                    
                    if arrMediaList.count > objIndex{
                        var objWallpost = arrMediaList[objIndex]
                        
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                        self.arrMediaList[objIndex] = objWallpost
                        DispatchQueue.main.async {
                            self.searchtbl.reloadData()
                        }
                    }
                }
                
            }else{
                if let objIndex = arrHashTagList.firstIndex(where:{$0.id == feedId}) {
                    
                    if arrHashTagList.count > objIndex{
                        var objWallpost = arrHashTagList[objIndex]
                        
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                        self.arrHashTagList[objIndex] = objWallpost
                        DispatchQueue.main.async {
                            self.searchtbl.reloadData()
                        }
                    }
                    
                }
            }
        }
    }
    
  
    @objc func feedFollwedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            
            for index in 0..<arrHashTagList.count {
                
                if arrHashTagList.count > index {
                 var  objWallPost = arrHashTagList[index]
                    
                    if objWallPost.sharedWallData == nil {
                        if objWallPost.userInfo?.id == userId{
                            objWallPost.isFollowed = isFollowed
                            arrHashTagList[index] = objWallPost
                        }
                    }else {
                        
                        
                        if objWallPost.userInfo?.id == userId{
                            objWallPost.isFollowed = isFollowed
                            arrHashTagList[index] = objWallPost
                        }
                        if objWallPost.sharedWallData.userInfo?.id == userId{
                            objWallPost.sharedWallData.isFollowed = isFollowed
                            arrHashTagList[index] = objWallPost
                        }
                    }
                    
                }
                
            }
            
            for index in 0..<arrMediaList.count {
                
                var objWallPost = arrMediaList[index]
                if objWallPost.sharedWallData == nil {
                    if objWallPost.userInfo?.id == userId{
                        objWallPost.isFollowed = isFollowed
                        arrMediaList[index] = objWallPost
                    }
                }else {
                    if objWallPost.userInfo?.id == userId{
                        objWallPost.isFollowed = isFollowed
                        arrMediaList[index] = objWallPost
                    }
                    if objWallPost.sharedWallData.userInfo?.id == userId{
                        objWallPost.sharedWallData.isFollowed = isFollowed
                        arrMediaList[index] = objWallPost
                    }
                }
            }
            
            
            if let objIndex = arrPeopleList.firstIndex(where:{$0.id == userId}) {
                
                var objSearchedUser = arrPeopleList[objIndex]
                objSearchedUser.isFollow = isFollowed
                arrPeopleList[objIndex] = objSearchedUser
                searchtbl.reloadData()
            }
                        
            
        }
    }
    
    @objc func feedSavedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            
            let feedId = objDict["feedId"] as? String ?? ""
            let isSave = objDict["isSave"] as? Int16 ?? 0
            
            if searchType == .media{
                
                if let objIndex = arrMediaList.firstIndex(where:{$0.id == feedId}) {
                    
                    var objWallPost = arrMediaList[objIndex]
                    objWallPost.isSave = isSave
                    arrMediaList[objIndex] = objWallPost
                }
            }else{
                
                if let objIndex = arrHashTagList.firstIndex(where:{$0.id == feedId}) {
                    
                    var objWallPost = arrHashTagList[objIndex]
                    objWallPost.isSave = isSave
                    arrHashTagList[objIndex] = objWallPost
                }
                
            }
        }
        
    }
}
