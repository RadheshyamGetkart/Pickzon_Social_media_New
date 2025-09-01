//
//  AccountSearchVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 26/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit



class AccountSearchVC: UIViewController {
   
    @IBOutlet weak var tblView: UITableView!

    var arrPeopleList = [SearchedUser]()
    var srchTxt:String = ""
    private var isDataLoading = false
    private var emptyView:EmptyList?
    private var isDataMoreAvailable = true
    private var pageNo = 1
    var delegate:SearchPostSelectedDelegate?

    //MARK: Controller life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        tblView.register(UINib(nibName: "PeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "PeopleTableViewCell")
        searchUsersListApi()
      
        NotificationCenter.default.addObserver(self, selector:
                                            #selector(self.accountSelectedTabIndex(notification:)),
                                           name: NSNotification.Name(rawValue: "accountSelectedTabIndex"), object: nil)
        }
        
        
        
        @objc func accountSelectedTabIndex(notification: Notification) {
            
            
            if  let response = notification.userInfo as? Dictionary<String, Any> {
                
                if let newToSearch = response["searchText"] as? String{
                   
                    if srchTxt == newToSearch{
                        
                    }else{
                        srchTxt = newToSearch
                        self.pageNo = 1
                        self.searchUsersListApi()
                    }
                }
            }
        }
    //MARK: Api methods
    
    func searchUsersListApi(){
        
        self.isDataLoading = true
   
 
        if pageNo == 1{
            self.arrPeopleList.removeAll()
            self.tblView.reloadData()
        }
        let param  = ["type":"users","keyword":srchTxt,"pageNumber":pageNo, "pageLimit":21] as [String : Any]

        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.SearchKeyWord, param: param as NSDictionary, completionHandler: {(responseObject, error) ->  () in
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
                        self.arrPeopleList.append(SearchedUser(dict: d as? NSDictionary ?? [:]))
                    }
                    self.emptyView?.isHidden = (self.arrPeopleList.count > 0) ? true : false
                    self.isDataMoreAvailable = (data.count > 5) ? true : false
                    self.pageNo = self.pageNo + 1
                    
                    
                    self.tblView.reloadAnimately{}
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

extension AccountSearchVC:UITableViewDelegate,UITableViewDataSource {
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return  2
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if section == 1{
            return (isDataMoreAvailable) ? 1 : 0
        }
            return self.arrPeopleList.count
            
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            cell.activityIndicator.startAnimating()
            return cell
       
        }else{
        
        let cell = tblView.dequeueReusableCell(withIdentifier:"PeopleTableViewCell") as! PeopleTableViewCell
        cell.selectionStyle = .none
        
        let objSuggestion = arrPeopleList[indexPath.row]
        cell.profilePicView.setImgView(profilePic: objSuggestion.profilePic, frameImg: objSuggestion.avatar,changeValue: (objSuggestion.avatar.count > 0) ? 8 : 5)
        cell.profilePicView?.imgVwProfile?.tag = indexPath.row
        // cell.profilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.handleProfilePicTap(_:))))
        
        cell.btnName.tag = indexPath.row
        cell.btnName.setTitle(objSuggestion.pickzonId, for: .normal)
        //   cell.btnName.addTarget(self, action: #selector(openProfile(sender:)), for: .touchUpInside)
        
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
        
        cell.btnFollow.isHidden = true
        /* if objSuggestion.isFollow > 0 {
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
         */
        return cell
    }
                
    }
        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = arrPeopleList[indexPath.row].id.length > 0 ? arrPeopleList[indexPath.row].id : arrPeopleList[indexPath.row].id
        (AppDelegate.sharedInstance.navigationController?.topViewController)?.pushView(profileVC, animated: true)
        
       // delegate?.searchItemSelected(selObj: arrPeopleList[indexPath.item], type: .users)

        
    }
    
      
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        return CGFloat.leastNonzeroMagnitude
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1 && indexPath.row == 0)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            if !isDataLoading {
                isDataLoading = true
                self.searchUsersListApi()
                
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
    
    
    @objc func followUser(sender:UIButton) {
        
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
        
        let userId = arrPeopleList[sender.tag].id
        let status:Int = arrPeopleList[sender.tag].isFollow == 1 ? 0 :1
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
                    
                    self.arrPeopleList[sender.tag].isFollow = isFollow
                    
                    if let cell = self.tblView.cellForRow(at: indexPath!) as? PeopleTableViewCell {
                        
                        cell.btnFollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: isFollow), for: .normal)
                        cell.btnFollow.setImage((isFollow == 0 || isFollow == 3) ? PZImages.followPlus :  PZImages.followCheckWhite , for: .normal)
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
