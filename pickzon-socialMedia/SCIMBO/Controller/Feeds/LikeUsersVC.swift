//
//  LikeUsersVC.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 9/13/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import Kingfisher


enum LikeControllerType{
    
    case feedLikeList
    case commentLikeList
    case storyView
}

class LikeUsersVC: UIViewController {

    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblTitle:UILabel!
    var postId = ""
    var pageNo = 1
    var isDataLoading = false
    var listArray:Array<Users> = Array<Users>()
    var emptyView:EmptyList?
    var controllerType:LikeControllerType?
    var isMoreDataAvailable = true
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        lblTitle.text = "Likes"
        
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        self.tblView.separatorStyle = .none
        
        
        emptyView?.lblMsg?.text = "No Likes"
        emptyView?.imageView?.image = PZImages.noData
        
        if controllerType == .feedLikeList{
            getLikedUserListApi(pageNo: pageNo)
        }else if controllerType == .storyView{
            lblTitle.text = "Views"
            getStoryViewUserListApi(pageNo: pageNo)
            emptyView?.lblMsg?.text =  "No Views"
        }else if controllerType == .commentLikeList{
            pageNo = 0
            getCommentLikedListApi(pageNo: pageNo)
        }
        
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
    }
    

    //MARK:UIButton Action Methods
        
    @IBAction func backButtonAction(sender:UIButton){

        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: Observer methos
    @objc func feedFollwedNotification(notification: Notification) {

        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            
            if (controllerType == .feedLikeList  || controllerType == .commentLikeList){
                
                for index in 0..<listArray.count {
                    
                    if listArray[index].id == userId {
                        
                        listArray[index].isFollow = isFollowed
                    }
                    
                }
                
                self.tblView.reloadData()
            }
        }
    }
    
    //MARK: - Api Methods

    func getCommentLikedListApi(pageNo:Int)  {
        
        if pageNo == 1{
            Themes.sharedInstance.activityView(View: self.view)
        }
        let params = NSMutableDictionary()
        params.setValue(postId, forKey: "commentId")
        params.setValue(pageNo, forKey: "pageNumber")

        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.getCommentLikes, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
           
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                self.isDataLoading = false
               
                if status == 1{
                    
                    if self.pageNo == 1{
                        self.listArray.removeAll()
                        self.tblView.reloadData()
                    }
                    
                    guard let data = result.value(forKey: "payload") as? NSArray else{
                        return
                    }
                       for obj in data {
                           self.listArray.append(Users(dict: obj as! NSDictionary))
                       }
                   
                        
                    
                    if data.count == 0{
                        self.isMoreDataAvailable = false
                    }
                        
                    self.pageNo = self.pageNo + 1

                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                    
                }else
                {
                    self.isMoreDataAvailable = false
                    self.tblView.reloadData()

                    self.emptyView?.lblMsg?.text = message
                }
                
                
                DispatchQueue.main.async {
                    self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                }
            }
        })
    }
    
    
    func getLikedUserListApi(pageNo:Int)  {
       
        if pageNo == 1{
            Themes.sharedInstance.activityView(View: self.view)
        }
        let url = Constant.sharedinstance.postLikeList + "?feedId=\(postId)&pageNumber=\(pageNo)"
      
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
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
                self.isDataLoading = false
                
                if status == 1{
                    if self.pageNo == 1{
                        self.listArray.removeAll()
                        self.tblView.reloadData()
                    }
                    
                    
                    guard let data = result["payload"] as? NSArray else{return }
                        for obj in data {
                            self.listArray.append(Users(dict: obj as! NSDictionary))
                        }
                    
                    
                    if data.count == 0{
                        self.isMoreDataAvailable = false
                    }
                    
                    self.pageNo = self.pageNo + 1
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                    
                }else
                {
                    self.emptyView?.lblMsg?.text = message
                    self.isMoreDataAvailable = false
                    self.tblView.reloadData()
                  //  self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
                
                DispatchQueue.main.async {
                    self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                   // self.tblView.separatorStyle = (self.listArray.count == 0) ? .none : .singleLine
                }
            }
        })
    }
    
    
    func getStoryViewUserListApi(pageNo:Int)  {
        
        if pageNo == 1{
            Themes.sharedInstance.activityView(View: self.view)
        }
        let params = NSMutableDictionary()
        params.setValue(postId, forKey: "statusId")
        params.setValue(pageNo, forKey: "pageNumber")

        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.storyStatusView, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                self.isDataLoading = false

                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    if self.pageNo == 1{
                        self.listArray.removeAll()
                    }
                    
                    guard let data = result.value(forKey: "payload") as? NSArray else{ return}
                        for obj in data {
                            self.listArray.append(Users(dict: obj as! NSDictionary))
                        }
                    if data.count == 0{
                        self.isMoreDataAvailable = false
                    }
                    self.pageNo = self.pageNo + 1
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }else
                {
                    self.emptyView?.lblMsg?.text = message
                    self.isMoreDataAvailable = false
                    self.tblView.reloadData()
                }
                
                DispatchQueue.main.async {
                    self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                }
            }
        })
    }
    
    func followBtn(index:Int){
        
        var status = 0
        
        
        if listArray[index].isFollow == 2
        {
            cancelFriendRequestApi(index: index)
        }else{
            
            if listArray[index].isFollow == 0 || listArray[index].isFollow == 3
            {
                status = 1
            }
            else
            {
                status = 0
            }
                        
            let param:NSDictionary = ["followedUserId":listArray[index].id,"status":status]
            
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
                    
                    if status == 1{
                        
                        self.listArray[index].isFollow = payloadDict["isFollow"] as? Int ?? 0
                        
                        DispatchQueue.main.async {
                            self.tblView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
      
      
    func cancelFriendRequestApi(index:Int){
          
         Themes.sharedInstance.activityView(View: self.view)
      
        
        let param:NSDictionary = ["followedUserId":listArray[index].id]

          
          URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.cancelRequest as String, param: param, completionHandler: {(responseObject, error) ->  () in
              Themes.sharedInstance.RemoveactivityView(View: self.view)
              if(error != nil)
              {
                  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
              }
              else{
                  let result = responseObject! as NSDictionary
                  let status = result["status"] as? Int ?? 0
                  let message = result["message"] as? String ?? ""
                  let payloadDict = result["payload"] as? NSDictionary ?? [:]
                  let isFollow = payloadDict["isFollow"] as? Int ?? 0

                  if status == 1{
                      self.listArray[index].isFollow = isFollow
                      DispatchQueue.main.async {
                          self.tblView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                      }

                      self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)

                  }
                  else
                  {
                      self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                  }
              }
          })
      }
}


extension LikeUsersVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.listArray.count > 15 && isMoreDataAvailable == true{
           return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if section == 1{
            return 1
        }
        return listArray.count
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeTblCellId") as? LikeTblCell
        cell?.btnFollow.isHidden = true
        if listArray[indexPath.row].isStoryLike == 1 {
            cell?.lblName.text = listArray[indexPath.row].name.capitalized  // + " ❤️"
            cell?.lblName.isHidden = (listArray[indexPath.row].name.count > 0) ? false : true
            cell?.btnFollow.isHidden = false
            cell?.btnFollow.backgroundColor = .clear
            cell?.btnFollow.isUserInteractionEnabled =  false
            cell?.btnFollow.setTitle("❤️", for: .normal)
        }else{
            cell?.lblName.text = listArray[indexPath.row].name.capitalized
            cell?.lblName.isHidden = (listArray[indexPath.row].name.count > 0) ? false : true
        }
        
        cell?.profilePicView.setImgView(profilePic: listArray[indexPath.row].profilePic, frameImg: listArray[indexPath.row].avatar,changeValue: 6)
        
        cell?.profilePicView.imgVwProfile?.tag = indexPath.row
        cell?.profilePicView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))

        switch listArray[indexPath.row].celebrity{
            
        case 1:
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.greenVerification
        case 4:
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.goldVerification
        case 5:
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.blueVerification
        default:
            cell?.imgVwCelebrity.isHidden = true
        }
         
        cell?.lblPickzonId.text = listArray[indexPath.row].pickzonId
        
        if (controllerType == .feedLikeList  || controllerType == .commentLikeList){

            cell?.btnFollow.isHidden = false
            cell?.btnFollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: listArray[indexPath.row].isFollow), for: .normal)
            cell?.btnFollow.tag = indexPath.row
            cell?.btnFollow.addTarget(self, action: #selector(followUnfollowBtnAction(_ : )), for: .touchUpInside)
            
            if Themes.sharedInstance.Getuser_id() == listArray[indexPath.row].id {
                cell?.btnFollow.isHidden = true
            }
        }
        
        if listArray[indexPath.row].isStoryLike == 1 {
            cell?.btnFollow.isHidden = false
        }

        return cell!
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  listArray[indexPath.row].id
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Call API befor the end of all records
        if indexPath.row == listArray.count-3 || indexPath.row == listArray.count-1  && listArray.count > 15{
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else if !isDataLoading && isMoreDataAvailable == true {
                
                isDataLoading = true
                
                    
                    if controllerType == .feedLikeList{
                        self.getLikedUserListApi(pageNo: pageNo)
                    }else if controllerType == .storyView{
                        self.getStoryViewUserListApi(pageNo: pageNo)
                        
                    }else if controllerType == .commentLikeList{
                        
                        self.getCommentLikedListApi(pageNo: pageNo)
                    }

            }
        }
 }
    
   
    //MARK: SElector methods
    
    @objc func openfrofileOfUser(_ sender:UILabel){
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  listArray[sender.tag].id
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    @objc func followUnfollowBtnAction(_ sender:UIButton){
        followBtn(index: sender.tag)
    }
    
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
            
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  listArray[sender?.view?.tag ?? 0].id
            self.navigationController?.pushViewController(profileVC, animated: true)
    }
}


class LikeTblCell: UITableViewCell {
    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!

    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var btnProfile:UIButton!
    @IBOutlet weak var lblSeperator:UILabel!
    @IBOutlet weak var btnFollow:UIButton!
    @IBOutlet weak var lblPickzonId:UILabel!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        btnFollow.layer.cornerRadius = 5.0
        btnFollow.clipsToBounds = true
        profilePicView.initializeView()
    }

}
