//
//  AllLiveUserListVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/9/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyGif
import Kingfisher

class AllLiveUserListVC: UIViewController {
    
    @IBOutlet weak var bgVwSearch: UIView!
    @IBOutlet weak var txtFdSearch: UITextField!
    @IBOutlet weak var btnCloseSearch: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgVwGif: UIImageView!
    @IBOutlet weak var followersCollectionVw: UICollectionView!
    @IBOutlet weak var cnstrntHtStatusLiveBgVw: NSLayoutConstraint!
    @IBOutlet weak var cnstrntHtNavigationVw: NSLayoutConstraint!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var collectionVw: UICollectionView!
    var pageNumber = 1
    var otherLiveListArray = [JoinedUser]()
    var followersLiveArray = [JoinedUser]()
    var topThreeLiveArray = [LiveUser]()
    var isSearching = false
    var emptyView:EmptyList?
    var isDataLoading = false
    var isDataMoreAvailable = true
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.label
        return refreshControl
    }()
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cnstrntHtStatusLiveBgVw.constant = 0
        self.collectionVw.refreshControl = self.topRefreshControl
        self.cnstrntHtNavigationVw.constant = self.getNavBarHt
        btnBack.isHidden = true
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width:  self.collectionVw.frame.size.width, height:  self.collectionVw.frame.size.height + 120))
            self.collectionVw.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = ""
            self.emptyView?.imageView?.image = PZImages.noLive
        }
        registerCell()
        addObservers()
        self.bgVwSearch.isHidden = true
        self.imgVwGif.setGifImage(UIImage(gifName: "liveIcon.gif"), loopCount: -1)
        self.imgVwGif.startAnimating()
        getLivelistApi()
        emit_sio_get_followers_live_list()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_get_live_status(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_status ), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_status), object: nil)
    }
    
    
    func registerCell(){
        
        collectionVw.register(UINib(nibName: "LoadingCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCell")

        collectionVw.register(UINib(nibName: "WeeklyLeaderboardHeaderCell", bundle: nil), forCellWithReuseIdentifier: "WeeklyLeaderboardHeaderCell")
        collectionVw.register(UINib(nibName: "LiveUsersCell", bundle: nil), forCellWithReuseIdentifier: "LiveUsersCell")
        collectionVw.register(UINib(nibName: "TopThreeLiveCell", bundle: nil), forCellWithReuseIdentifier: "TopThreeLiveCell")
        followersCollectionVw.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        
        collectionVw.register(UINib(nibName: "TopGainerLiveCell", bundle: nil), forCellWithReuseIdentifier: "TopGainerLiveCell")
        
    }
    
    
    //MARK: Other helpful methods
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        
        if isDataLoading == true {
            
        }else{
            self.pageNumber = 1
            self.txtFdSearch.text = ""
            self.txtFdSearch.resignFirstResponder()
            self.bgVwSearch.isHidden = true
            self.isDataLoading = true
            self.emit_sio_get_followers_live_list()
            self.getLivelistApi()
        }
        
        refreshControl.endRefreshing()
    }
    
    func addObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_get_golive_endlive_user_info(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_golive_endlive_user_info), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_get_followers_live_list(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_followers_live_list), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
    }
    
    
    //MARK: Observers methods
    
    @objc func sio_get_live_status(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
           // if (responseDict["status"] as? Int ?? 0) == 1{
                
                if let payload = responseDict["payload"] as? Dictionary<String, Any>{
                    
                    let isLive = payload["isLive"] as? Int ?? 0
                    let isLivePK = payload["isLivePK"] as? Int ?? 0
                   // let livePKId = payload["livePKId"] as? String ?? ""
                   // let pkRoomId = payload["PKRoomId"] as? String ?? ""
                    let userId =  payload["hostId"] as? String ?? ""
                    
                    
                    guard let controller = AppDelegate.sharedInstance.navigationController?.viewControllers.last as?  HomeBaseViewController  else { return }
                                        
                       
                        if isLive == 0 && isLivePK == 0{
                            
                            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                            profileVC.otherMsIsdn =  userId
                            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
                        }else{
                            let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                            destVc.leftRoomId =  userId
                            self.navigationController?.pushView(destVc, animated: true)
                        }
                    }
         
        }
    }
    
    
    
    @objc func sio_get_golive_endlive_user_info(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if (responseDict["status"] as? Int ?? 0) == 1{
                
                if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                    let obj = JoinedUser(respDict: payload)
                    let type  = payload["type"] as? Int ?? 1
                    
                    if type == 0{
                        if let objIndex = followersLiveArray.firstIndex(where:{($0 as JoinedUser).userId == obj.userId}) {
                            self.followersLiveArray.remove(at: objIndex)
                        }
                    }else{
                        if let objIndex = followersLiveArray.firstIndex(where:{($0 as JoinedUser).userId == obj.userId}) {
                            self.followersLiveArray.remove(at: objIndex)
                            self.followersLiveArray.insert(obj, at: 0)
                            
                        }else{
                            self.followersLiveArray.append(obj)
                        }
                    }
                    self.cnstrntHtStatusLiveBgVw.constant = (self.followersLiveArray.count > 0) ? 105 : 0
                   
                    if (self.otherLiveListArray.count == 0 && self.topThreeLiveArray.count == 0 && followersLiveArray.count == 0) {
                        self.emptyView?.isHidden = false
                        
                    }else{
                        self.emptyView?.isHidden = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        self.followersCollectionVw.reloadData()
                    }
                    
                }
            }
        }
    }
    
    
    @objc func sio_get_followers_live_list(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if (responseDict["status"] as? Int ?? 0) == 1{
                
                if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
                    
                    self.followersLiveArray.removeAll()
                    for dict in payloadArr {
                        self.followersLiveArray.append(JoinedUser(respDict: dict))
                    }
                    self.cnstrntHtStatusLiveBgVw.constant = (self.followersLiveArray.count > 0) ? 105 : 0
                    
                    if (self.otherLiveListArray.count == 0 && self.topThreeLiveArray.count == 0 && followersLiveArray.count == 0) {
                        self.emptyView?.isHidden = false
                        
                    }else{
                        self.emptyView?.isHidden = true
                    }
                    
                    self.followersCollectionVw.reloadData()
                    self.collectionVw.reloadData()
                }
            }
        }
    }
    
    
    @objc func socketConnected(notification: Notification) {
        
    }
    
    
    @objc func socketError(notification: Notification){
        
    }
    
    
    //MARK: Api Methods
    func checkLiveStatus(roomId:String) {
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": roomId,
            "livePKId":""
        ]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_live_status, param)
    }
    
    func emit_sio_get_followers_live_list(){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken() ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_followers_live_list, param)
    }
    
    
    func getLivelistApi(){
        
        self.isDataLoading = true
        
        
        if pageNumber == 1{
            isDataMoreAvailable = true
        }
       // Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        let urlStr = (Constant.sharedinstance.get_live_users + "?pageNumber=\(pageNumber)&search=\(txtFdSearch.text ?? "")").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  ?? ""
        
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
        
        URLhandler.sharedinstance.makeGetCall(url: urlStr, param: [:]) { (responseObject, error) ->  () in
            
           // Themes.sharedInstance.RemoveactivityView(View: self.view)
           
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""
                
                
                if status == 1 {
                    
                    if let payloadDict = result["payload"] as? Dictionary<String, Any>{
                        
                        if self.pageNumber == 1{
                            self.otherLiveListArray.removeAll()
                            self.topThreeLiveArray.removeAll()
                            self.collectionVw.reloadData {
                                
                            }
                            
                            if let  toppersArray = payloadDict["topGifter"] as? Array<Dictionary<String, Any>>{
                                
                                for topperDict in toppersArray{
                                    self.topThreeLiveArray.append(LiveUser(respDict: topperDict))
                                }
                            }
                        }
                        
                        if let  liveUsersArr = payloadDict["liveUserList"] as? Array<Dictionary<String, Any>>{
                            
                            
                            for dict in liveUsersArr{
                                
                                self.otherLiveListArray.append(JoinedUser(respDict: dict))
                            }
                            
                            if liveUsersArr.count > 0 {
                                self.pageNumber = self.pageNumber + 1
                            }
                            
                            self.isDataMoreAvailable = ( liveUsersArr.count > 0) ? true : false
                        }
                        
                    }
                    
                    self.emptyView?.lblMsg?.text = result["message"] as? String ?? ""
                    if (self.otherLiveListArray.count == 0 && self.topThreeLiveArray.count == 0 && self.followersLiveArray.count == 0){
                       
                        self.emptyView?.isHidden = false
                        
                    }else{
                        self.emptyView?.isHidden = true
                    }
                    self.collectionVw.reloadData{
                        self.isDataLoading = false
                    }
                    self.followersCollectionVw.reloadData()

                    
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                }
            }
        }
    }
    
    
    //MARK: UIButton Action Methods
        
    @IBAction func refreshBtnAction(_ sender : UIButton){
        if isDataLoading == true {
            
        }else{
            self.pageNumber = 1
            self.txtFdSearch.text = ""
            self.txtFdSearch.resignFirstResponder()
            self.bgVwSearch.isHidden = true
            self.isDataLoading = true
            self.emit_sio_get_followers_live_list()
            self.getLivelistApi()
        }
        
    }
    
    @IBAction func closeSearchBtnAction(_ sender : UIButton){
        self.txtFdSearch.endEditing(true)
        self.bgVwSearch.isHidden = true
        isSearching = false
        txtFdSearch.text = ""
        pageNumber = 1
        getLivelistApi()
    }
    
    @IBAction func backBtnAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchBtnAction(_ sender : UIButton){
        
        isSearching = true
        self.bgVwSearch.isHidden = false
        self.txtFdSearch.becomeFirstResponder()
    }
    
}


extension AllLiveUserListVC:UITextFieldDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //MARK: - UItextfield Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text?.count ?? 0 > 0{
            pageNumber = 1
            self.txtFdSearch.resignFirstResponder()
            self.getLivelistApi()
        }
        return true
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == followersCollectionVw{
            if followersLiveArray.count > 0{
                return 1
            }else {
                return 0
            }
        }else{
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == followersCollectionVw{
            return  followersLiveArray.count
        }else if collectionView == collectionVw{
            if section == 0 {
                return (topThreeLiveArray.count > 0) ? 1 : 0
            }else  if section == 1 {
                return   otherLiveListArray.count
            }else  if section == 2{
                return  (isDataMoreAvailable && otherLiveListArray.count > 10) ? 1 : 0
            }else {
                return 0
            }
        }else {
            return 0
        }
    }
    
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if section == 0 && collectionView == collectionVw{
//            return UIEdgeInsets(top: 8, left: 0  , bottom: 0, right: 0)
//        }else if section == 1 && collectionView == collectionVw{
//            return UIEdgeInsets(top: 2, left: 0.5, bottom: 0, right: 0.5)
//        }
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//    
    
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == followersCollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! StoryCollectionViewCell
            cell.layoutIfNeeded()
            cell.btnUserImage.isUserInteractionEnabled = false
            cell.btnUserImage.contentHorizontalAlignment = .fill
            cell.btnUserImage.contentVerticalAlignment = .fill
            cell.btnUserImage.imageView?.contentMode = .scaleAspectFill
            cell.btnAdd.isHidden = true
            cell.viewBack.defaultStatusColour =  .systemRed
            cell.viewBack.viewedStatusColour =  .systemRed
            cell.viewBack.numberOfStatus = 1
            cell.btnUserImage.kf.setImage(with: URL(string: self.followersLiveArray[indexPath.row].profilePic), for: .normal , placeholder: PZImages.avatar, options: [.processor(DownsamplingImageProcessor(size:  cell.btnUserImage.frame.size)),                                                                                       .scaleFactor(UIScreen.main.scale)])
            cell.btnUserName.setTitle(self.followersLiveArray[indexPath.row].pickzonId, for: .normal)
            
            if  self.followersLiveArray[indexPath.row].isLivePK == 1{
                cell.btnLiveStatus.setImage(UIImage(named: "pk"), for: .normal)
                cell.btnLiveStatus.setTitle("", for: .normal)
                
            }else if  self.followersLiveArray[indexPath.row].isLive == 1{
                cell.btnLiveStatus.setImage(nil, for: .normal)
                cell.btnLiveStatus.setTitle("Live", for: .normal)
            }
            return cell
            
        }else if collectionView == collectionVw {
            
            switch indexPath.section{
                
            case 0:
                do{
                    
                    let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeklyLeaderboardHeaderCell", for: indexPath) as! WeeklyLeaderboardHeaderCell
                    
                    cell1.profilePicFirstView.isHidden = true
                    cell1.profilePicSecondView.isHidden = true
                    cell1.profilePicThirdView.isHidden = true
                    
                    cell1.profilePicFirstGifterView.isHidden = true
                    cell1.profilePicSecondGifterView.isHidden = true
                    cell1.profilePicThirdGifterView.isHidden = true
                                        
                    cell1.lblNameFirst.text = ""
                    cell1.lblNameSecond.text = ""
                    cell1.lblNameThird.text = ""
                    
                    cell1.lblNameFirstGifter.text = ""
                    cell1.lblNameSecondGifter.text = ""
                    cell1.lblNameThirdGifter.text = ""
                    
                    
                    cell1.bgVwCoin1st.isHidden = true
                    cell1.bgVwCoin2nd.isHidden = true
                    cell1.bgVwCoin3rd.isHidden = true

                    if let firstTopper = topThreeLiveArray.first{
                        
                        cell1.profilePicFirstView.isHidden = false
                        cell1.profilePicFirstGifterView.isHidden = false
                        cell1.profilePicFirstView.setImgView(profilePic: firstTopper.profilePic, remoteSVGAUrl: firstTopper.avatarSVGA)
                        cell1.profilePicFirstGifterView.setImgView(profilePic: firstTopper.topGifterObj.profilePic, remoteSVGAUrl: firstTopper.topGifterObj.avatarSVGA,changeValue: 8)
                        cell1.lblNameFirst.attributedText = getTextfromVerifiedAndString(name: "\(firstTopper.pickzonId)", celebrity: firstTopper.celebrity)
                        cell1.lblNameFirstGifter.attributedText = getTextfromVerifiedAndString(name: "\(firstTopper.topGifterObj.pickzonId)", celebrity: firstTopper.topGifterObj.celebrity, color : .white, fontSize: 8)

                        cell1.bgVwCoin1st.isHidden = false
                        cell1.lblCoin1st.text = "\(firstTopper.coins)"
                    }
                    
                    
                    if  topThreeLiveArray.count > 1 {
                        
                        cell1.profilePicSecondView.setImgView(profilePic: topThreeLiveArray[1].profilePic, remoteSVGAUrl: topThreeLiveArray[1].avatarSVGA)
                        cell1.profilePicSecondGifterView.setImgView(profilePic: topThreeLiveArray[1].topGifterObj.profilePic, remoteSVGAUrl: topThreeLiveArray[1].topGifterObj.avatarSVGA,changeValue:8)
                        cell1.lblNameSecond.attributedText =  getTextfromVerifiedAndString(name: "\(topThreeLiveArray[1].pickzonId)", celebrity: topThreeLiveArray[1].celebrity)
                        cell1.lblNameSecondGifter.attributedText = getTextfromVerifiedAndString(name: "\(topThreeLiveArray[1].topGifterObj.pickzonId)", celebrity: topThreeLiveArray[1].topGifterObj.celebrity, color : .white, fontSize: 8)

                        cell1.profilePicSecondView.isHidden = false
                        cell1.profilePicSecondGifterView.isHidden = false
                        cell1.bgVwCoin2nd.isHidden = false
                        cell1.lblCoin2nd.text = "\(topThreeLiveArray[1].coins)"

                    }
                    
                    if  topThreeLiveArray.count > 2 {
                        
                        cell1.profilePicThirdView.setImgView(profilePic: topThreeLiveArray[2].profilePic, remoteSVGAUrl: topThreeLiveArray[2].avatarSVGA)
                        cell1.profilePicThirdGifterView.setImgView(profilePic: topThreeLiveArray[2].topGifterObj.profilePic, remoteSVGAUrl: topThreeLiveArray[2].topGifterObj.avatarSVGA,changeValue:8)
                        cell1.lblNameThird.attributedText = getTextfromVerifiedAndString(name: "\(topThreeLiveArray[2].pickzonId)", celebrity: topThreeLiveArray[2].celebrity)
                        cell1.lblNameThirdGifter.attributedText = getTextfromVerifiedAndString(name: "\(topThreeLiveArray[2].topGifterObj.pickzonId)", celebrity: topThreeLiveArray[2].topGifterObj.celebrity,color : .white, fontSize: 8)
                        cell1.profilePicThirdView.isHidden = false
                        cell1.profilePicThirdGifterView.isHidden = false
                        cell1.bgVwCoin3rd.isHidden = false
                        cell1.lblCoin3rd.text = "\(topThreeLiveArray[2].coins)"

                    }
                    

                    cell1.btnSeeAll.addTarget(self, action: #selector(seAllWeeklyLeaderboard), for: .touchUpInside)

                    cell1.profilePicFirstView.remoteSVGAPlayer?.addGestureRecognizer(  UITapGestureRecognizer(target: self, action: #selector(self.handleProfileFirstTap(_:))))
                    
                    cell1.profilePicSecondView.remoteSVGAPlayer?.addGestureRecognizer(  UITapGestureRecognizer(target: self, action: #selector(self.handleProfileSecondTap(_:))))
                    
                    cell1.profilePicThirdView.remoteSVGAPlayer?.addGestureRecognizer(  UITapGestureRecognizer(target: self, action: #selector(self.handleProfileThirdTap(_:))))
                    
                    cell1.profilePicFirstGifterView.remoteSVGAPlayer?.addGestureRecognizer(  UITapGestureRecognizer(target: self, action: #selector(self.handleProfileFirstGifterTap(_:))))
                    
                    cell1.profilePicSecondGifterView.remoteSVGAPlayer?.addGestureRecognizer(  UITapGestureRecognizer(target: self, action: #selector(self.handleProfileSecondGifterTap(_:))))
                    
                    cell1.profilePicThirdGifterView.remoteSVGAPlayer?.addGestureRecognizer(  UITapGestureRecognizer(target: self, action: #selector(self.handleProfileThirdGifterTap(_:))))
                    
                    return cell1
                    
                }
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                return cell
                
                
            default:
                do{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveUsersCell", for: indexPath) as! LiveUsersCell
                    cell.bgVwJoinCount.isHidden = true
                    
                    cell.lblName.text = otherLiveListArray[indexPath.row].name.count>0 ? otherLiveListArray[indexPath.row].name : otherLiveListArray[indexPath.row].pickzonId
                    cell.imgVwUser.kf.setImage(with: URL(string: self.otherLiveListArray[indexPath.row].profilePic), placeholder: PZImages.dummyCover , options: nil, progressBlock: nil, completionHandler: { response in  })
                    cell.lblCoinCount.text =  "\(self.otherLiveListArray[indexPath.row].coins)"
                    
                    //  "isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
                    if otherLiveListArray[indexPath.row].isLivePK == 1{
                        cell.imgVwPk.isHidden = false
                        cell.cnstntWidthPkIcon.constant = 25
                    }else{
                        cell.imgVwPk.isHidden = true
                        cell.cnstntWidthPkIcon.constant = 0
                    }
                    
                    cell.lblViewCount.text = otherLiveListArray[indexPath.row].joinUserCount
                    
                    switch otherLiveListArray[indexPath.row].celebrity{
                    case 1:
                        cell.imgVwCelebrity.isHidden = false
                        cell.imgVwCelebrity.image = PZImages.greenVerification
                        
                    case 4:
                        cell.imgVwCelebrity.isHidden = false
                        cell.imgVwCelebrity.image = PZImages.goldVerification
                    case 5:
                        cell.imgVwCelebrity.isHidden = false
                        cell.imgVwCelebrity.image = PZImages.blueVerification
                        
                    default:
                        cell.imgVwCelebrity.isHidden = true
                    }
                    
                    
                    return cell
                }
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    func getTextfromVerifiedAndString(name:String, celebrity:Int, color:UIColor = .black, fontSize:CGFloat = 9) -> NSMutableAttributedString {
        
        var verifiedImage:UIImage? = nil
        switch celebrity{
        case 1:
            verifiedImage = PZImages.greenVerification
            
        case 4:
            verifiedImage = PZImages.goldVerification
            
        case 5:
            verifiedImage = PZImages.blueVerification
            
        default:
            verifiedImage = nil
        }
        
        let nameAttr = NSMutableAttributedString(string: name, attributes:[
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont(name:"Roboto-Regular", size: fontSize)!])
        
        if verifiedImage == nil{
            
        }else{
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.bounds = CGRect(x: 0, y: -1.0, width: 9, height: 9)
            nameAttr.append(NSMutableAttributedString(string: " "))
            attachment.image = verifiedImage
            let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
            nameAttr.append(attachmentString)
        }
        
        return nameAttr
        
    }
    
  /*  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
       
        if (section == 1 && collectionView == collectionVw) &&  otherLiveListArray.count > 4 && isDataMoreAvailable == true{
            
            return CGSize(width:collectionView.frame.size.width, height:65.0)
        }else{
            return .zero
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

//        if indexPath.section != 1 && collectionView == followersCollectionVw{
//            return
//        }
        switch kind {
            
        case UICollectionView.elementKindSectionFooter:

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadingCell", for: indexPath)

            return headerView

        default:

            fatalError("Unexpected element kind")
        }
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == followersCollectionVw{
            return CGSize(width: 80, height: 100)
            
        }else if collectionView == collectionVw{
           
            if indexPath.section == 0{
                return  CGSize(width:((self.collectionVw.frame.size.width)), height: (self.collectionVw.frame.size.width * 0.87))
                
            }else if indexPath.section == 1{
                return CGSize(width:((self.collectionVw.frame.size.width/2.0)-1.0), height: self.collectionVw.frame.size.width/2.0 + 70)
            }else {
                return  CGSize(width:((self.collectionVw.frame.size.width)), height: 65)
            }
        }else {
            return  CGSize(width:((self.collectionVw.frame.size.width)), height: 65)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
        
        if collectionView == followersCollectionVw  {
            destVc.leftRoomId = followersLiveArray[indexPath.row].userId
            self.navigationController?.pushView(destVc, animated: true)

        }else{
            // destVc.leftRoomId = (indexPath.section == 0) ? topThreeLiveArray[indexPath.row].userId : otherLiveListArray[indexPath.row].userId
            if indexPath.section == 1{
                destVc.leftRoomId =  otherLiveListArray[indexPath.row].userId
                self.navigationController?.pushView(destVc, animated: true)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (indexPath.section == 2 && collectionView == collectionVw) &&  otherLiveListArray.count > 10 && isDataMoreAvailable == true  { //}&& (otherLiveListArray.count == indexPath.item + 1) {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            
            if self.isDataLoading == false {
                isDataLoading = true
                self.getLivelistApi()
            }
        }
    }


   
    
    //Mark: Selector Methods
    @objc func handleProfileFirstTap(_ sender: UITapGestureRecognizer? = nil) {
        
        checkLiveStatus(roomId: topThreeLiveArray[0].userId)
        
    }

    

    
    @objc func handleProfileSecondTap(_ sender: UITapGestureRecognizer? = nil) {
        checkLiveStatus(roomId: topThreeLiveArray[1].userId)

        
    }
    
    
    @objc func handleProfileThirdTap(_ sender: UITapGestureRecognizer? = nil) {
        checkLiveStatus(roomId: topThreeLiveArray[2].userId)
    
    }
  
    
    
    @objc func handleProfileFirstGifterTap(_ sender: UITapGestureRecognizer? = nil) {
        if topThreeLiveArray.count > 0{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  topThreeLiveArray[0].topGifterObj.userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
  
    
    @objc func handleProfileSecondGifterTap(_ sender: UITapGestureRecognizer? = nil) {
        if topThreeLiveArray.count > 1{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  topThreeLiveArray[1].topGifterObj.userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
  
    @objc func handleProfileThirdGifterTap(_ sender: UITapGestureRecognizer? = nil) {
        if topThreeLiveArray.count > 2{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  topThreeLiveArray[2].topGifterObj.userId
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
 
    @objc func seAllWeeklyLeaderboard(){
        
        if let destVC:WeeklyLeaderboardVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "WeeklyLeaderboardVC") as? WeeklyLeaderboardVC{
            self.navigationController?.pushViewController(destVC, animated: true)
        }        
    }
}

