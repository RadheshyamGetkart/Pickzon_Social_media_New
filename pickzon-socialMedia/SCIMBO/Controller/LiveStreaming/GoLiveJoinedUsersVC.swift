//
//  GoLiveJoinedUsersVC.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 9/30/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import Kingfisher
import FittedSheets

class GoLiveJoinedUsersVC: UIViewController {
    
    @IBOutlet weak  var tblView:UITableView!
    var listArray = [JoinedUser]()
    var pageNumber = 1
    var fromId = ""
    var isDataLoading = false
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UINib(nibName: "JoinedUserTblCell", bundle: nil), forCellReuseIdentifier: "JoinedUserTblCell")
        addObservers()
        emitJoinedUserList()
    }
    
    
    //MARK: Other Helpful methods
    func addObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.joinedUserList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_join_user_list), object: nil)
        
        
        /*  NotificationCenter.default.addObserver(self, selector: #selector(self.joinedGOLive(notification:)),
         name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_join_user_room), object: nil)
         
         
         NotificationCenter.default.addObserver(self, selector: #selector(self.leaveGOLive(notification:)),
         name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_leave_user_room), object: nil)
         */
    }
    
    
    func emitJoinedUserList(){
        isDataLoading = true
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": fromId,
            "pageNumber":pageNumber
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_join_user_list, param)
    }
    
    
    //MARK: Observers methods
    
    @objc func leaveGOLive(notification: Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payload = response["payload"] as? Dictionary<String,Any>{
                
                var index = 0
                for obj in listArray{
                    
                    if obj.userId == (payload["userId"] as? String ?? ""){
                        
                        self.listArray.remove(at: index)
                        break
                    }
                    index = index + 1
                }
            }
            self.tblView.reloadData()
        }
    }
    
    
    @objc func joinedGOLive(notification: Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payload = response["payload"] as? Dictionary<String,Any>{
                
                self.listArray.append(JoinedUser(respDict: payload))
            }
            self.tblView.reloadData()
        }
    }
    
    @objc func joinedUserList(notification: Notification){
        isDataLoading = false
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
                
                if self.pageNumber == 1{
                    self.listArray.removeAll()
                }
                for dict in payloadArr{
                    self.listArray.append(JoinedUser(respDict: dict))
                }
                if payloadArr.count > 0 {
                    
                    self.pageNumber = self.pageNumber + 1
                }
            }
            self.tblView.reloadData()
        }
    }
    
    
    
    //MARK: UIButton Action Methods
    
    @IBAction func closeView(_ sender: Any) {
        self.dismissView(animated: true)
    }
    
    
}

extension GoLiveJoinedUsersVC:UITableViewDelegate,UITableViewDataSource,GoliveUserDelegate{
    
    //MARK: Delegate User Info
    func selectedOption(index:Int,title:String){
        
        if title == "profile"{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = self.listArray[index].userId
            self.navigationController?.pushView(profileVC, animated: true)
            
        }else if title == "option"{
            
            /* if comments[index].userId == "652797eed3f9cd9fd638cde0"{
             return
             }
             if comments[index].userId != Themes.sharedInstance.Getuser_id() && isGoLiveUser == true {
             openListOfOptions(index:index)
             }*/
        }
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: false)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    //MARK: Tableview data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedUserTblCell") as? JoinedUserTblCell
        cell?.selectionStyle = .none
        cell?.lblName.text = (listArray[indexPath.row].name.count > 0) ?  listArray[indexPath.row].name : listArray[indexPath.row].pickzonId
        
       // cell?.imgVwProfile.kf.setImage(with: URL(string: self.listArray[indexPath.row].profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in  })
        
        
        cell?.profileImgView.setImgView(profilePic: self.listArray[indexPath.row].profilePic, frameImg: self.listArray[indexPath.row].avatar,changeValue:6)

        cell?.btnTotalCoin.setTitle("\(self.listArray[indexPath.row].coins)", for: .normal)
        
        switch self.listArray[indexPath.row].celebrity{
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
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Themes.sharedInstance.Getuser_id() == self.listArray[indexPath.row].userId{
            
        }else{
           /* if self.sheetViewController?.options.useInlineMode == true {
                self.sheetViewController?.attemptDismiss(animated: false)
            } else {
                self.dismiss(animated: false, completion: nil)
            }*/
            
            if #available(iOS 13.0, *) {
                
                let controller = StoryBoard.letGo.instantiateViewController(identifier: "UserInfoVC")
                as! UserInfoVC
                
                if self.fromId == Themes.sharedInstance.Getuser_id(){
                    controller.istoHideProfile = 1
                    
                }else{
                    controller.istoHideProfile = 0
                    
                }
                controller.selIndex = indexPath.item
                controller.userObj.name = self.listArray[indexPath.row].name
                controller.userObj.profilePic = self.listArray[indexPath.row].profilePic
                controller.userObj.pickzonId = self.listArray[indexPath.row].pickzonId
                controller.userObj.celebrity = self.listArray[indexPath.row].celebrity
                controller.userObj.userId = self.listArray[indexPath.row].userId
                let useInlineMode = view != nil
                
                controller.title = ""
                controller.navigationController?.navigationBar.isHidden = true
                controller.view.backgroundColor = .clear
                controller.goLivefromId = fromId
                
                if fromId == Themes.sharedInstance.Getuser_id(){
                    
                }else{
                    controller.delegate = self
                }
                var fixedSize = 360
                if UIDevice().hasNotch{
                    fixedSize = 375
                }
                let sheet = SheetViewController(
                    controller: controller,
                    sizes: [.fixed(CGFloat(fixedSize)),.intrinsic],
                    options: SheetOptions(pullBarHeight : 0, presentingViewCornerRadius : 0, useFullScreenMode:false , useInlineMode: useInlineMode))
                sheet.allowGestureThroughOverlay = false
                sheet.cornerRadius = 20
                sheet.navigationController?.navigationBar.isHidden = true
                sheet.contentBackgroundColor = .clear
                
                if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                    sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                } else {
                    (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
                }
                
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            
            if !isDataLoading {
                isDataLoading = true
                self.emitJoinedUserList()
            }
        }
    }
    
    
}
