//
//  FeedsApi.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 10/6/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import Foundation

extension FeedsViewController{
    
    func emailVarifyAlert() {
        
        let alertController = UIAlertController(title: "", message: "Your account email is not yet verified. Please verify your email.", preferredStyle: .alert)
        
        let proceedAction = UIAlertAction(title: "Continue", style: .default, handler: { alert -> Void in
            
            let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
            viewController.isEmail = true
            
            self.navigationController?.pushView(viewController, animated: true)
        })
        alertController.addAction(proceedAction)
        self.present(alertController, animated: true, completion: nil)
        
        
        UserDefaults.standard.setValue(false, forKey: "showVerifyEmailPopup")
        UserDefaults.standard.synchronize()
    }
    

    
    
    func emitLiveUSersList(){
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken()
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_live_users  , param)
    }
    
    
    
    
    
    
    
    func setLogoWithDynamic(logoUrl:String){
        if logoUrl.count > 0 {
            imgVwLogo.setGifFromURL(URL(string: logoUrl), manager: .defaultManager, loopCount: -1, showLoader: true)
            
        }else{
            imgVwLogo.image = UIImage(named: "applogo2")
        }
        
        imgVwLogo.setImageViewTintColor(color: UIColor.label)

    }
    
    func openViolationPreview(){
       
        if let warningDict = Settings.sharedInstance.warningDict{
            
            let warningMsgDict = warningDict["warningMessage"] as? NSDictionary ?? [:]
       
            if (warningDict["warningPopUp"] as? Int ?? 0) == 1 {
                
                if let addNewView = Bundle.main.loadNibNamed("ViolatingPopupView", owner: self, options: nil)?.first as? ViolatingPopupView {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                        addNewView.initializeMethods(frame:appDelegate.window?.frame ?? .zero,title:warningMsgDict["title"] as? String ?? "" ,message:warningMsgDict["description"] as? String ?? "")
                        appDelegate.window?.addSubview(addNewView)
                    }
                }
            }

        }
    }
    
    func getClipSettingApi(){
        
        URLhandler.sharedinstance.makeGetAPICall(url: Constant.sharedinstance.getClipSetting, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    if let payload = result["payload"] as? NSDictionary{
                        
                        Settings.sharedInstance.initWithDict(payload: payload)
                        self.openViolationPreview()
                        self.setLogoWithDynamic(logoUrl: Settings.sharedInstance.appLogo)
                        
                       
                       /*
                        //To display the welcome popup
                        let popUpUrl = payload["popup"] as? String ?? ""
                        if popUpUrl.length > 0 {
                            UserDefaults.standard.set(popUpUrl, forKey: "popUpUrl")
                            UserDefaults.standard.set(true, forKey: "isDisplayWelcomePointAlert")
                            self.isDisplayWelcomePointAlert = true
                            self.showPromoAlert()
                            UserDefaults.standard.set(false, forKey: "isDisplayWelcomePointAlert")
                        }else {
                            UserDefaults.standard.set(false, forKey: "isDisplayWelcomePointAlert")
                        }
                        UserDefaults.standard.synchronize()
                        */
                        
                        let dictPopUp = payload["popUp"] as? Dictionary<String,Any> ?? [:]
                        if dictPopUp.count > 0 {
                            let url = dictPopUp["url"] as? String ?? ""
                            if url.length > 0 {
                                self.popupType = dictPopUp["type"] as? Int ?? 0
                                self.popUpID = dictPopUp["id"] as? String ?? ""
                                self.showpopUp(url: url)
                            }
                        }
                        
                       let showVerifyEmailPopup =  UserDefaults.standard.value(forKey: "showVerifyEmailPopup") as? Bool ?? true
                        
                        if Settings.sharedInstance.isEmailVerified == 0 && showVerifyEmailPopup == true {
                            self.emailVarifyAlert()
                        }
                    }
                }else{
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    func callPopupSeenAPI(){
        
        let params = ["type":"\(self.popupType)","id": "\(self.popUpID)"]
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.getPopupSeen, param: params as NSDictionary, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                   
                    
                } else {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    //MARK: APi methods
    
    func followFeedsUser(index:Int,isShared:Bool,isSharingUser:Bool = false) {
        
        guard let objwallPost = arrwallPost[index] as? WallPostModel else {
            return
        }
        
        let  userId:String = (isShared) ? (objwallPost.sharedWallData.userInfo?.id ?? "") : (objwallPost.userInfo?.id ?? "")
        let param:NSDictionary = ["followedUserId":userId,"status":"1"]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                                    
                    
                    var i = 0
                    for obj in self.arrwallPost{
                        autoreleasepool {
                            if  var postObj = obj as? WallPostModel {
                                
                                if postObj.sharedWallData == nil{
                                    
                                    if (postObj.userInfo?.id ?? "") == userId{
                                        postObj.isFollowed = 1
                                        if let cell  = self.tblFeeds.cellForRow(at: IndexPath(row: i, section: self.feedSectionNo)) as? FeedsTableViewCell {
                                            cell.btnFolow.isHidden = true
                                        }
                                    }
                                }else{
                                    
                                    if let cell = self.tblFeeds.cellForRow(at: IndexPath(row: i, section: self.feedSectionNo)) as? FeedsSharedTableViewCell {
                                        
                                        if (postObj.sharedWallData.userInfo?.id ?? "") == userId{
                                            postObj.sharedWallData.isFollowed = 1
                                            cell.btnFolow.isHidden = true
                                        }
                                        if (postObj.userInfo?.id ?? "") == userId{
                                            postObj.isFollowed = 1
                                            cell.btnSharedFollow.isHidden = true
                                        }
                                    }
                                }
                                self.arrwallPost[i] = postObj
                            }
                        }
                        i = i + 1
                    }
                    
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message as! String, duration: 1, position: HRToastActivityPositionDefault)
                        
                    }
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
        func getUserIdFromPickzonId(pickzonId:String){

        
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        let url:String = Constant.sharedinstance.getmsisdn + "?pickzonId=\(pickzonId)"
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }
            else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    DispatchQueue.main.async {
                        let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        viewController.otherMsIsdn = payload["userId"] as? String ?? ""
                        self.navigationController?.pushView(viewController, animated: true)
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    func getAllStatusListApi(isToShowLoader:Bool){
                
        if self.wallStatusArray.count == 0{
            DispatchQueue.main.async {
                let data = self.fetchStoryDataFromDB()
                for obj in data {
                    autoreleasepool {
                        self.wallStatusArray.append(WallStatus(responseDict: obj as! NSDictionary))
                    }
                }
                self.tblFeeds.reloadData()
            }
        }

        if isToShowLoader {
            DispatchQueue.main.async {
                Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)
            }
        }
        
        
        let params = NSMutableDictionary()
        params["gcm_id"] = UserDefaults.standard.string(forKey: "fcm_token") ?? ""
        params["appVersion"] = Themes.sharedInstance.getAppVersion()
        params["OS"] =  "OS"
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.getAllFeedsStatus, param: params, methodType: .post) { responseObject, error in
           
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
                //let message = result["message"] as? String ?? ""
                
                if status == 1 {
                   
                    let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    self.availableStatus = payload["availableStatus"] as? Int ?? 0
                    self.wallStatusArray.removeAll()
                    self.removeStoryDataFromDB()

                    if let data = payload["wallstatus"] as? NSArray {
                        for obj in data {
                            autoreleasepool {
                                self.wallStatusArray.append(WallStatus(responseDict: obj as! NSDictionary))
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.feedSectionNo = 1
                        UIView.performWithoutAnimation {
                            let loc = self.tblFeeds.contentOffset
                            self.tblFeeds.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                            self.tblFeeds.contentOffset = loc
                        }
                        self.saveStoryDataInDB(objDataDict: payload)
                        self.playFirstVideo()
                    }
                }
                
            }
        }
    

     /*   DispatchQueue.global(qos: .background).async {
            let params = NSMutableDictionary()
            params.setValue(UserDefaults.standard.string(forKey: "fcm_token") ?? "", forKey: "gcm_id")
            params.setValue(Themes.sharedInstance.getAppVersion(), forKey: "appVersion")
            params.setValue("ios", forKey: "OS")
            
            var request = URLRequest(url: URL(string: Constant.sharedinstance.getAllFeedsStatus)!)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(Themes.sharedInstance.getAuthToken(), forHTTPHeaderField: "authToken")
            request.setValue(Themes.sharedInstance.getAppVersion(), forHTTPHeaderField: "appVersion")
            request.setValue("ios", forHTTPHeaderField: "OS")
         
            if  Themes.sharedInstance.getBasicAuthorizationUserName().length > 0 {
                let loginString = "\(Themes.sharedInstance.getBasicAuthorizationUserName()):\(Themes.sharedInstance.getBasicAuthorizationPassword())"
                guard let loginData = loginString.data(using: String.Encoding.utf8) else {
                    return
                }
                let base64LoginString = loginData.base64EncodedString()
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            }
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 60
            
            if ISDEBUG == true {
                print("getAllStatusListApi====\(Constant.sharedinstance.getAllFeedsStatus) \n Request \(params)")
            }
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
                if let data = data {
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                        let result = responseObject as? NSDictionary ?? NSDictionary()
                        let status = result["status"] as? Int64 ?? 0
    
                        if ISDEBUG {
                            print("getAllStatusListApi====\(responseObject)")
                        }
                        if status == 1{
                            let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                            self.availableStatus = payload["availableStatus"] as? Int ?? 0
                            self.wallStatusArray.removeAll()
                            self.removeStoryDataFromDB()
                           

                            if let data = payload["wallstatus"] as? NSArray {
                                for obj in data {
                                    autoreleasepool {
                                        self.wallStatusArray.append(WallStatus(responseDict: obj as! NSDictionary))
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.feedSectionNo = 1
                                UIView.performWithoutAnimation {
                                    let loc = self.tblFeeds.contentOffset
                                    self.tblFeeds.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                                    self.tblFeeds.contentOffset = loc
                                }
                                self.saveStoryDataInDB(objDataDict: payload)
                            }
                        }
                        
                    } catch {
                        print(error)
                    }
                }

                
            }.resume()
            
        }
    */
    }
    
    func playFirstVideo(){
        //pageNo already incremented thats why we are comparing pageNo with 2
        if self.pageNo == 2 && self.arrwallPost.count > 0{
            if let vc = AppDelegate.sharedInstance.navigationController?.topViewController as? HomeBaseViewController {
                if vc.controller.selectedIndex == 0 {
                    if  self.arrwallPost[0] is WallPostModel {
                        self.isAutopPlayFirstIndex = true
                        self.playVideoAtIndexPath(selIndexPath: IndexPath(row: 0, section: self.feedSectionNo))
                    }else {
                        if self.arrwallPost.count > 1 {
                            self.isAutopPlayFirstIndex = true
                            self.playVideoAtIndexPath(selIndexPath: IndexPath(row: 1, section: self.feedSectionNo))
                            
                        }
                    }
                }
            }
        }
    }
    
    func preBufferNextRandomVideos() {
        
        var urlArray:Array<URL> = Array()
        for index in 0..<Themes.sharedInstance.arrFeedsVideo.count {
                if index < Themes.sharedInstance.arrFeedsVideo.count{
                    autoreleasepool {
                        if let objWallPost = Themes.sharedInstance.arrFeedsVideo[index] as? WallPostModel {
                            var strURL = ""
                            if objWallPost.sharedWallData == nil {
                                if objWallPost.urlArray.count > 0{
                                    strURL = objWallPost.urlArray[0]
                                }
                            }else {
                                if objWallPost.sharedWallData.urlArray.count > 0{
                                    strURL = objWallPost.sharedWallData.urlArray[0]
                                }
                            }
                            if strURL.length > 0 {
                                if checkMediaTypes(strUrl:strURL ) == 3  {
                                    urlArray.append(URL(string: strURL)!)
                                }
                            }
                        }
                    }
                }else {
                    break
                }
            
        }
        if urlArray.count > 0 {
            VideoPreloadManager.shared.set(waiting: urlArray)
        }
    }
    
    
    func getFeedsVideosAPI(){
        
        let url = "\(Constant.sharedinstance.getSuggestedRandomVideosURL as String)?pageNumber=\(1)&pageLimit=5"
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
            
            
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

                    Themes.sharedInstance.arrFeedsVideo.removeAll()
                    
                    if  let data = result["payload"] as? NSArray {
                        for obj in data {
                            autoreleasepool {
                                Themes.sharedInstance.arrFeedsVideo.append( WallPostModel(dict: obj as! NSDictionary))
                            }
                        }
                    }
                    
                    if self.indexClipSuggestion != -1 {
                        self.arrwallPost[self.indexClipSuggestion] = ClipSuggestionModel(arrWallPostModel: Themes.sharedInstance.arrFeedsVideo)
                        self.tblFeeds.reloadRows(at: [IndexPath(row: self.indexClipSuggestion, section: self.feedSectionNo)], with: .none)
                        self.indexClipSuggestion = -1
                        self.preBufferNextRandomVideos()
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
    
   
    func getUserSuggestionListAPI(isToShowLoader:Bool){
        
        if isToShowLoader == true {
            DispatchQueue.main.async {
                Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            }
        }
        URLhandler.sharedinstance.makeGetAPICall(url:Constant.sharedinstance.getUserSuggestionListURL, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
            
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
                    
                    let data = result["payload"] as? Array<Dictionary<String, Any>> ?? []
                    
                    DispatchQueue.main.async {
                        if self.indexFriendSuggestion != -1 {
                            self.arrwallPost[self.indexFriendSuggestion] = FriendSuggestionModal(arrFriendsSuggestion: data)
                            self.tblFeeds.reloadRows(at: [IndexPath(row: self.indexFriendSuggestion, section: self.feedSectionNo)], with: .none)
                            self.indexFriendSuggestion = -1
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
    
    
    
    func getAllWallPostAPIImplementation(pageNo:Int, isShowLoader:Bool = true){
        if pageNo == 1 {
            self.pauseAllVisiblePlayers()
        }
        
        self.isDataLoading = true
       
        if self.arrwallPost.count == 0 {
            let data = self.fetchFeedsDataFromDB()
            self.states = [Bool](repeating: true, count: data.count)
            
            for obj in data {
                autoreleasepool {
                    if (obj as! NSDictionary)["viewType"] as? Int ?? 0 == 0 {
                        
                        self.arrwallPost.append(WallPostModel(dict: obj as! NSDictionary))
                        
                    }else if (obj as! NSDictionary)["viewType"] as? Int ?? 0 == 2 {
                        
                        self.arrwallPost.append(FriendSuggestionModal(respDict: (obj as! NSDictionary)))
                    }
                }
            }
            DispatchQueue.main.async {
                self.tblFeeds.reloadData()
                if pageNo == 1 && self.arrwallPost.count > 0{
                    self.tblFeeds.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
      
        if isShowLoader == true && pageNo == 1{
            
            DispatchQueue.main.async {
                Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            }
        }
         
            URLhandler.sharedinstance.makeGetAPICall(url:"\(Constant.sharedinstance.getAllWallPostURL)?pageNumber=\(pageNo)", param: NSMutableDictionary(), completionHandler: {  (responseObject, error) ->  () in
                
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
                
                
                if(error != nil)
                {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }else{
                    
                    let result = responseObject! as NSDictionary
                    let message = result["message"] as? String ?? ""
                    
                    if  result["status"] as? Int ?? 0 == 1 {
                        
                        let data = result["payload"] as? Array<Dictionary<String, Any>> ?? []
                        
                        if pageNo == 1 {
                            self.arrwallPost.removeAll()
                            self.states.removeAll()
                            self.tblFeeds.reloadData()
                            self.removeFeedsDataFromDB()
                            self.indexFriendSuggestion = -1
                            self.goLiveSuggestionIndex = -1
                        }
                        
                        //count records before API call
                        let objCount = (self.arrwallPost.count > 0) ? (self.arrwallPost.count - 1) : (self.arrwallPost.count)
                       
                        for obj in data {
                           
                                if (obj as NSDictionary)["viewType"] as? Int ?? 0 == 0 {
                                    self.arrwallPost.append(WallPostModel(dict: obj as NSDictionary))
                                }else if (obj as NSDictionary)["viewType"] as? Int ?? 0 == 2 {
                                    self.arrwallPost.append(FriendSuggestionModal(respDict: (obj as NSDictionary)))
                                    self.indexFriendSuggestion = self.arrwallPost.count - 1
                                    if self.indexFriendSuggestion == -1 {
                                        self.indexFriendSuggestion =  0
                                    }
                                }else if (obj as NSDictionary)["viewType"] as? Int ?? 0 == 1 {
                                    self.arrwallPost.append(ClipSuggestionModel(arrWallPostModel: Array<WallPostModel>()))
                                    self.indexClipSuggestion = self.arrwallPost.count - 1
                                    if self.indexClipSuggestion == -1 {
                                        self.indexClipSuggestion =  0
                                    }
                                    
                                }else if (obj as NSDictionary)["viewType"] as? Int ?? 0 == 5 {
                                    //Banners
                                    self.arrwallPost.append(FeedBannerModel(respDict: [:]))
                                    self.bannerIndex =  self.arrwallPost.count - 1
                                    if self.bannerIndex == -1 {
                                        self.bannerIndex =  0
                                    }
                                    self.fetchGetBannerAPI()
                                }else if (obj as NSDictionary)["viewType"] as? Int ?? 0 == 4 {
                                    //Goliveusers
                                   /* self.arrwallPost.append(GoLiveUser(respArr: Array()))
                                    self.goLiveSuggestionIndex = self.arrwallPost.count - 1
                                    self.emitLiveUSersList()*/
                                }
                                                        
                            self.states.append(true)
                            self.tblFeeds.beginUpdates()
                            self.tblFeeds.insertRows(at: [IndexPath(row: self.arrwallPost.count - 1, section: self.feedSectionNo)], with: .none)
                            self.tblFeeds.endUpdates()
                        }
                        
                           
                        DispatchQueue.main.async {
                            if pageNo == 1 && self.arrwallPost.count > 0{
                                self.tblFeeds.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                            }
                        }
                        
                        if pageNo == 1 {
                          
                            self.getAllStatusListApi(isToShowLoader: false)

                            do{
                                try VideoCacheManager.cleanAllCache()
                            }catch {
                            }
                        }
                        
                        //Call Fetch Friend Suggestion data
                        if self.indexFriendSuggestion != -1 {
                            self.getUserSuggestionListAPI(isToShowLoader: false)
                        }
                        if self.indexClipSuggestion != -1 {
                            self.getFeedsVideosAPI()
                        }
                        self.pageNo = self.pageNo + 1
                        self.preBufferNextFeedVideos(currentIndex: objCount)
                        if data.count > 0{
                            self.saveFeedsDataInDB(objDataArray: data)
                        }
                        
                    } else  {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // your code here
                    self.isDataLoading = false
                }
            })
    }
    
    
    func fetchGetBannerAPI(){
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            
            URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getBannerURL + "?type=1", param: NSDictionary(), completionHandler: {(responseObject, error) ->  () in
                if(error != nil)
                {
                    print(error ?? "defaultValue")
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    if status == 1{
                        
                    if  result.value(forKey: "payload") is Array<Dictionary<String,Any>> {
                            if self.bannerIndex != -1 {
                                self.arrwallPost[self.bannerIndex] = FeedBannerModel(respDict: result as! Dictionary<String, Any>)
                                self.tblFeeds.reloadRows(at: [IndexPath(row: self.bannerIndex, section: self.feedSectionNo)], with: .none)
                                self.bannerIndex = -1
                            }
                        }
                    }
                }
            })
            
        }else {
            let msg = "No Network Connection"
            self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
   

    func followUnfollowApi(index:Int,isFromSuggestion:Bool = true,section:Int){
        
        let obj = (self.arrwallPost[section] as! FriendSuggestionModal).payload[index]
        var status = 0
        
        if obj.isFollow == 2
        {
            cancelFriendRequestApi(index: index,section:section)
        }else{
            
            if obj.isFollow == 0
            {
                status = 1
            }
            else
            {
                status = 0
            }
            
            let param:NSDictionary = ["followedUserId":obj.id,"status":status]
            
            Themes.sharedInstance.activityView(View: self.view)
            
            URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    let payloadDict = result["payload"] as? NSDictionary ?? [:]
                    // let isFollow = payloadDict["isFollow"] as? Int ?? 0
                    
                    if status == 1{
                        
                        if isFromSuggestion == true {
                            
                            DispatchQueue.main.async {
                                self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                                
                                if var obj = (self.arrwallPost[section] as? FriendSuggestionModal) {
                                    obj.payload.remove(at: index)
                                    self.arrwallPost[section] = obj
                                }
                                
                                if  (self.arrwallPost[section] as! FriendSuggestionModal).payload.count > 0 {
                                    self.tblFeeds.reloadData()
                                    
                                }else {
                                    self.arrwallPost.remove(at: section)
                                    self.tblFeeds.reloadData()
                                }
                            }
                        }
                    }
                    else
                    {
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
            
        }
    }
    
    
    func cancelFriendRequestApi(index:Int,section:Int){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let obj = (self.arrwallPost[section] as! FriendSuggestionModal).payload[index]

        let param:NSDictionary = ["followedUserId":obj.id]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.cancelRequest as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
          
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                    if var obj = self.arrwallPost[section] as? FriendSuggestionModal{
                        obj.payload[index].isFollow = isFollow
                        self.arrwallPost[section] = obj
                    }
                    
                    DispatchQueue.main.async {
                        self.tblFeeds.reloadData()
                    }
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func removeSuggestionApi(index:Int,section:Int){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let obj = self.arrwallPost[section] as! FriendSuggestionModal
        let param:NSDictionary = ["suggestedUserId":obj.payload[index].id]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.removeSuggestedFriend as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    DispatchQueue.main.async {
                        
                        if var obj = (self.arrwallPost[section] as? FriendSuggestionModal) {
                            self.removeFeedsFriendSuggestionWithId(id: obj.payload[index].id)
                            obj.payload.remove(at: index)
                            self.arrwallPost[section] = obj
                        }
                        if  (self.arrwallPost[section] as! FriendSuggestionModal).payload.count > 0 {
                            self.tblFeeds.reloadData()
                            
                        }else {
                            self.arrwallPost.remove(at: section)
                            self.tblFeeds.reloadData()
                        }
                    }
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }

}
