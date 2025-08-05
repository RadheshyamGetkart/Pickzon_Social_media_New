//
//  PostInsightsVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/4/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class PostInsightsVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var imgVwPost:UIImageView!
    @IBOutlet weak var lblPostBoostedDate:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBoostAgain:UIButton!
    @IBOutlet weak var tblFooterVw:UIView!

    var firstSecRowArray = ["Coins Spent","Post reached"]
    var secondSecRowArray = ["Likes","Comments","Shares","Saves"]
    var thirdSecRowArray = ["Profile visits","Follows"]
    var secondSecImgRowArray = ["heart_blank","CommentIcon","Shareicon","saveIcon"]
    var thirdSecImgRowArray = ["profileVisitBlack","followRoundBlack"]
    var objPost:BoostedPost?
    var feedId = ""
    var id = ""
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "BoostPackTblCell", bundle: nil), forCellReuseIdentifier: "BoostPackTblCell")
        tblView.register(UINib(nibName: "SectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")
        imgVwPost.layer.cornerRadius = 10.0
        imgVwPost.clipsToBounds = true
        
        self.tblView.refreshControl = topRefreshControl
        
        btnBoostAgain.layer.cornerRadius = 6.0
        btnBoostAgain.clipsToBounds = true
        self.btnBoostAgain.isHidden = true
        getBoostedPostDetails()
        
//        if let strUrl = objPost?.thumbUrl{
//            self.imgVwPost.kf.setImage(with: URL(string: strUrl), placeholder: PZImages.dummyCover, progressBlock: nil) { response in}
//        }
//        self.lblPostBoostedDate.text = objPost?.boostDate ?? ""
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    

//MARK: Pull to refresh
@objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
    getBoostedPostDetails()
    refreshControl.endRefreshing()
    topRefreshControl.endRefreshing()
}

    //MARK: UIButton action methods
    
    @IBAction func backBtnActionMethod(_ sender:UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func boostAgainBtnActionMethod(_ sender:UIButton){
        
        if Settings.sharedInstance.usertype == 1{
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Your account is private. Please update your account privacy to public to boost your post.", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                if index == 0 {
                    
                    let editProfileVC:ProfileEditVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
                    editProfileVC.isCreatingNewPost = true
                    AppDelegate.sharedInstance.navigationController?.pushViewController(editProfileVC, animated: true)
                }
            }
        }else{
            
            getSingleWallPost()
        }
    }
  
    
    //MARK: Api methods
    
    func getSingleWallPost(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let url = "\(Constant.sharedinstance.getSingleWallPost)/\(feedId)"
        let param:NSDictionary =  [:]

        URLhandler.sharedinstance.makeGetAPICall(url: url, param: param) { responseObject, error in
            
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
                    
                    if  let payloadDict = result.value(forKey: "payload") as? NSDictionary{
                        if payloadDict.count > 0 {
                            
                            DispatchQueue.main.async {
                                
                             /*
                                var isFound = false
                                for controller in AppDelegate.sharedInstance.navigationController!.viewControllers as Array {
                                    print("Controlller = \(controller)")
                                    if isFound {
                                        
                                        self.navigationController?.popToViewController(controller, animated: false)
                                      //  AppDelegate.sharedInstance.navigationController?.popToViewController(controller, animated: false)
                                        break
                                    }
                                    if controller.isKind(of: BoostPostVC.self) {
                                        isFound = true
                                    }
                                }
                                */
                                
                                let destVC:BoostPostVC = StoryBoard.promote.instantiateViewController(withIdentifier: "BoostPostVC") as! BoostPostVC
                                destVC.objWallpost = WallPostModel(dict: payloadDict)
                                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                            }
                            
                        }else {
                            
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }
                
            }
        }
    }
    
    
    func getBoostedPostDetails(){
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)

        var strUrl = Constant.sharedinstance.get_boost_post_details + "?feedId=\(feedId)"
        if self.id.count > 0{
            strUrl = Constant.sharedinstance.get_boost_post_details + "?feedId=\(feedId)&id=\(self.id)"
        }
        URLhandler.sharedinstance.makeGetCall(url:strUrl , param: [:]) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""

                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        self.objPost = BoostedPost(respDict: payload)
                        
                        DispatchQueue.main.async {
                            self.lblPostBoostedDate.text = self.objPost?.boostDate ?? ""
                            self.tblView.reloadData()
                            // 1 means show 0 means hide
                            self.btnBoostAgain.isHidden = ((self.objPost?.status ?? 0) == 0) ? true : false
                        }
                        if let strUrl = self.objPost?.thumbUrl{
                            self.imgVwPost.kf.setImage(with: URL(string: strUrl), placeholder: PZImages.dummyCover, progressBlock: nil) { response in}
                        }
                    }
                    
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
}


extension PostInsightsVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return firstSecRowArray.count
        }else if section == 1{
            return secondSecRowArray.count
        }else{
            return thirdSecRowArray.count
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! SectionHeaderCell
        
        cell.lblCount.text = ""
        cell.seperatorVw.isHidden = false

        if section == 0{
            cell.seperatorVw.isHidden = true
            cell.lblTitle.text = "Overview"
        }else if section == 1{
            cell.lblTitle.text = "Post interactions"
            cell.lblCount.text = "\(objPost?.postInteractions ?? 0)"
        }else{
            cell.lblTitle.text = "Profile activity"
            cell.lblCount.text = "\(objPost?.profileActivity ?? 0)"

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoostPackTblCell", for: indexPath) as! BoostPackTblCell
        cell.lblVIewCount.isHidden = true
        cell.lblRecommended.isHidden = true
        cell.imgVwClipIcon.isHidden = false
        cell.rightImgVwIcon.isHidden = true
        cell.cnstrntWidthClipImg.constant = 25
        cell.cnstrntHeightClipImg.constant = 25
        cell.lblCoin.font = UIFont(name: "Roboto-Regular", size: 15.0)
        cell.lblTitle.font = UIFont(name: "Roboto-Regular", size: 15.0)

        if indexPath.section ==  0{
            cell.cnstrntLeadingClipImg.constant = -25
            cell.lblTitle.text = firstSecRowArray[indexPath.row]
            cell.imgVwClipIcon.isHidden = true
            cell.rightImgVwIcon.isHidden = false
            
            if indexPath.row == 0{
                cell.rightImgVwIcon.image = UIImage(named: "coinSmall")
                cell.lblCoin.text = "\(objPost?.coinsSpent ?? 0)"
                
            }else{
                cell.rightImgVwIcon.image = PZImages.viewIcon
                cell.lblCoin.text = "\(objPost?.postReached ?? 0)"

            }
        }else if indexPath.section ==  1{
            cell.cnstrntLeadingClipImg.constant = 10
            cell.lblTitle.text = secondSecRowArray[indexPath.row]
            cell.imgVwClipIcon.image = UIImage(named: secondSecImgRowArray[indexPath.row])
            switch indexPath.row{
                
            case 0:
                cell.lblCoin.text = "\(objPost?.likes ?? 0)"
                break
            case 1:
                cell.lblCoin.text = "\(objPost?.comments ?? 0)"
                break
            case 2:
                cell.lblCoin.text = "\(objPost?.shares ?? 0)"
                break
            case 3:
                cell.lblCoin.text = "\(objPost?.saves ?? 0)"
                break
           
            default:
                break
            }
            
        }else if indexPath.section ==  2{
            cell.cnstrntLeadingClipImg.constant = 10
            cell.lblTitle.text = thirdSecRowArray[indexPath.row]
            cell.imgVwClipIcon.image = UIImage(named: thirdSecImgRowArray[indexPath.row])
            
            switch indexPath.row{
                
            case 0:
                cell.lblCoin.text = "\(objPost?.profileVisit ?? 0)"
                break
            case 1:
                cell.lblCoin.text = "\(objPost?.followers ?? 0)"
                break
                
            default:
                break
            }
        }
       
        return cell
    }
}
