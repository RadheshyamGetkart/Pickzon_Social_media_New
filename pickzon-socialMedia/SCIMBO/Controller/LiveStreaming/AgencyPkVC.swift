//
//  AgencyPkVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/10/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Alamofire

class AgencyPkVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cntrntHtNavBar:NSLayoutConstraint!
    
    var isDataLoading = false
    var emptyView:EmptyList?
    var listArray = [AgencyPkModel]()
    var isExpanded = false
    var rewardBannerArr = [String]()
    var pageNumber = 1
   
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: Controller life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cntrntHtNavBar.constant = self.getNavBarHt
        registerCell()
        self.tblView.refreshControl = self.topRefreshControl
        
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        emptyView?.lblMsg?.text = ""
        emptyView?.imageView?.image = PZImages.noData
        getAgencyPkListApi()
    }
    
    
    func registerCell(){
        tblView.register(UINib(nibName: "AgencyPkTblCell", bundle: nil), forCellReuseIdentifier: "AgencyPkTblCell")
        tblView.register(UINib(nibName: "AgencyBannerWithDDTblCell", bundle: nil), forCellReuseIdentifier: "AgencyBannerWithDDTblCell")
    }
    
    //MARK: Other helpful methods
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        
        if isDataLoading == true {
            
        }else{
            self.isExpanded = false
            self.pageNumber = 1
            self.isDataLoading = true
            self.getAgencyPkListApi()
        }
        
        refreshControl.endRefreshing()
    }
    
    
    //MARK: UIButton Action Methods
    
    @IBAction  func backButtonActionMethod(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Api Methods
    
    func getAgencyPkListApi(){
        
        self.isDataLoading = true
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
        
        let strUrl = Constant.sharedinstance.get_agency_pk + "?pageNumber=\(pageNumber)"
        URLhandler.sharedinstance.makeGetCall(url: strUrl, param: [:]) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.isDataLoading = false
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    if self.pageNumber == 1{
                        self.listArray.removeAll()
                        self.rewardBannerArr.removeAll()
                    }
                    
                    if let  toppersArray = result["payload"] as? Array<Dictionary<String, Any>>{
                        
                        for topperDict in toppersArray{
                            
                            if  let rewardBanner =  topperDict["rewardBanner"] as? Array<String>{
                                self.rewardBannerArr = rewardBanner
                                self.tblView.reloadData()

                            }else{
                                self.listArray.append(AgencyPkModel(respDict: topperDict))
                            }
                        }
                    }
                    
                    self.pageNumber = self.pageNumber + 1
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
                
                self.emptyView?.lblMsg?.text = result["message"] as? String ?? ""
                self.emptyView?.isHidden = (self.listArray.count == 0 && self.rewardBannerArr.count == 0) ? false :  true
                self.tblView.reloadData()
                
            }
        }
    }
}


extension AgencyPkVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return  (rewardBannerArr.count > 0) ? 1 : 0
        }
        return listArray.count
    }
    
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return (isExpanded) ? 280 : 140
        }
        return 140
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgencyBannerWithDDTblCell") as! AgencyBannerWithDDTblCell
            
            if !(isExpanded){
                cell.imgVwBanner.kf.setImage(with: URL(string: rewardBannerArr[0]))
            }else{
                cell.imgVwBanner.kf.setImage(with: URL(string: rewardBannerArr[1]))
            }
            
            cell.btnDropDown.addTarget(self, action: #selector(dropDownAction(_ : )), for: .touchUpInside)
            cell.btnDropDown.setImage(((isExpanded) ? UIImage(named: "dropDownUpCircle") : UIImage(named: "dropDownCircle")), for: .normal)
            
            cell.imgVwBanner.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgVwBannerDidTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            cell.imgVwBanner.addGestureRecognizer(tapGesture)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgencyPkTblCell") as! AgencyPkTblCell
        
        cell.btnProfileLeft.layer.cornerRadius = cell.btnProfileLeft.frame.size.height/2.0
        cell.btnProfileLeft.clipsToBounds = true
        cell.btnProfileRight.layer.cornerRadius = cell.btnProfileRight.frame.size.height/2.0
        cell.btnProfileRight.clipsToBounds = true
        
        let userObj = listArray[indexPath.row]
        
        
        
        
        cell.btnNameLeft.setTitle(userObj.pickzonId, for: .normal)
       
        //cell.btnProfileLeft.kf.setImage(with: URL(string: userObj.profilePic), for: .normal, placeholder: PZImages.avatar)
       // cell.imgbtnProfileLeftView.initializeView()
        cell.imgbtnProfileLeftView.setImgView(profilePic: userObj.profilePic, frameImg: userObj.avatar,changeValue: 6)
        //let tap = UITapGestureRecognizer(target: self, action: #selector(leftProfileAction(_ : )))
        //cell.imgbtnProfileLeftView.imgVwProfile?.addGestureRecognizer(tap)
        
        
        cell.lblCoinLeft.text = "\(userObj.coins)"
        
        switch userObj.celebrity{
            
        case 1:
            cell.imgVwCelebrityLeft.isHidden = false
            cell.imgVwCelebrityLeft.image = PZImages.greenVerification
            
        case 4:
            cell.imgVwCelebrityLeft.isHidden = false
            cell.imgVwCelebrityLeft.image = PZImages.goldVerification
        case 5:
            cell.imgVwCelebrityLeft.isHidden = false
            cell.imgVwCelebrityLeft.image = PZImages.blueVerification
            
        default:
            cell.imgVwCelebrityLeft.isHidden = true
            
        }
        
        cell.btnNameRight.setTitle(userObj.pickzonIdRight, for: .normal)
        //cell.btnProfileRight.kf.setImage(with: URL(string: userObj.profilePicRight), for: .normal, placeholder: PZImages.avatar)
        //cell.imgbtnProfileRightView.initializeView()
        cell.imgbtnProfileRightView.setImgView(profilePic: userObj.profilePicRight, frameImg: userObj.avatarRight,changeValue: 6)
        //let tap1 = UITapGestureRecognizer(target: self, action: #selector(rightProfileAction(_ : )))
        //cell.imgbtnProfileRightView.imgVwProfile?.addGestureRecognizer(tap1)
        
        cell.lblCoinRight.text = "\(userObj.coinsRight)"

        switch userObj.celebrityRight{
        case 1:
            cell.imgVwCelebrityRight.isHidden = false
            cell.imgVwCelebrityRight.image = PZImages.greenVerification
            
        case 4:
            cell.imgVwCelebrityRight.isHidden = false
            cell.imgVwCelebrityRight.image = PZImages.goldVerification
        case 5:
            cell.imgVwCelebrityRight.isHidden = false
            cell.imgVwCelebrityRight.image = PZImages.blueVerification
            
        default:
            cell.imgVwCelebrityRight.isHidden = true
        }
        
        cell.btnProfileLeft.tag = indexPath.item
        cell.btnProfileRight.tag = indexPath.item
        cell.btnNameLeft.tag = indexPath.item
        cell.btnNameRight.tag = indexPath.item
        cell.imgVwBG.tag = indexPath.item
        
        cell.btnProfileLeft.addTarget(self, action: #selector(leftProfileAction(_ : )), for: .touchUpInside)
        cell.btnNameLeft.addTarget(self, action: #selector(leftProfileAction(_ : )), for: .touchUpInside)
        cell.btnProfileRight.addTarget(self, action: #selector(rightProfileAction(_ : )), for: .touchUpInside)
        cell.btnNameRight.addTarget(self, action: #selector(rightProfileAction(_ : )), for: .touchUpInside)
        
        cell.imgVwBG.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        cell.imgVwBG.addGestureRecognizer(tapGesture)
        cell.lblLeftStatus.textColor = .white
        cell.lblRightStatus.textColor = .white
        
        // result: { type: Number, default: 0 }, // 0 = No result, 1 = winner/loser, 2 = Tie
       // "status": 0, // 0 = create, 1 = complete, 2 = cancel, 3 = After Join pk(Self Left/Close PK)
        
        if  userObj.winnerId == userObj.userId{
            
            cell.lblLeftStatus.text = "Winner"
            cell.lblRightStatus.text = "Loser"
            cell.lblLeftStatus.textColor = .green
            cell.lblRightStatus.textColor = .red

            if userObj.agencyScheduledPkStatus == 3{
                cell.lblRightStatus.text = "Loser (Left)"
            }
        }else if  userObj.winnerId == userObj.userIdRight{
            
            cell.lblLeftStatus.text = "Loser"
            cell.lblRightStatus.text = "Winner"
            cell.lblRightStatus.textColor = .green
            cell.lblLeftStatus.textColor = .red
            if userObj.agencyScheduledPkStatus == 3{
                cell.lblLeftStatus.text = "Loser (Left)"
            }

        }else if userObj.result == 0{
            
            cell.lblLeftStatus.text = ""
            cell.lblRightStatus.text = ""
            
        }else if userObj.result == 2{
            
            cell.lblLeftStatus.text = "Tie"
            cell.lblRightStatus.text = "Tie"
            cell.lblLeftStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb900")
            cell.lblRightStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb900")
        }
        
        
        if userObj.agencyScheduledPkStatus == 2{
            cell.lblLeftStatus.text = "Cancelled"
            cell.lblRightStatus.text = "Cancelled"
            cell.lblLeftStatus.textColor = .red
            cell.lblRightStatus.textColor = .red
        }
        
        cell.lblTime.text = userObj.startTime
        cell.bgVwLblTime.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb900")
        cell.bgVwLblTime.roundGivenCorners([.bottomLeft,.bottomRight], radius: 8.0)

        cell.btnGifter1Left.isHidden = true
        cell.btnGifter2Left.isHidden = true
        cell.btnGifter3Left.isHidden = true
        
        if userObj.giftersLeftArray.count > 0{
            cell.btnGifter1Left.isHidden = false
            cell.btnGifter1Left.kf.setImage(with: URL(string: userObj.giftersLeftArray[0].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        if userObj.giftersLeftArray.count > 1{
            cell.btnGifter2Left.isHidden = false
            cell.btnGifter2Left.kf.setImage(with: URL(string: userObj.giftersLeftArray[1].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        
        if userObj.giftersLeftArray.count > 2{
            cell.btnGifter3Left.isHidden = false
            cell.btnGifter3Left.kf.setImage(with: URL(string: userObj.giftersLeftArray[2].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        
        cell.btnGifter1Left.tag = indexPath.row
        cell.btnGifter2Left.tag = indexPath.row
        cell.btnGifter3Left.tag = indexPath.row
        
        cell.btnGifter1Left.addTarget(self, action: #selector(btnGifter1Left(_ : )), for: .touchUpInside)
        cell.btnGifter2Left.addTarget(self, action: #selector(btnGifter2Left(_ : )), for: .touchUpInside)
        cell.btnGifter3Left.addTarget(self, action: #selector(btnGifter3Left(_ : )), for: .touchUpInside)
                
        cell.btnGifter1Right.isHidden = true
        cell.btnGifter2Right.isHidden = true
        cell.btnGifter3Right.isHidden = true
        
        if userObj.giftersRightArray.count > 0{
            cell.btnGifter1Right.isHidden = false
            cell.btnGifter1Right.kf.setImage(with: URL(string: userObj.giftersRightArray[0].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        if userObj.giftersRightArray.count > 1{
            cell.btnGifter2Right.isHidden = false
            cell.btnGifter2Right.kf.setImage(with: URL(string: userObj.giftersRightArray[1].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        
        if userObj.giftersRightArray.count > 2{
            cell.btnGifter3Right.isHidden = false
            cell.btnGifter3Right.kf.setImage(with: URL(string: userObj.giftersRightArray[2].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        
        cell.btnGifter1Right.tag = indexPath.row
        cell.btnGifter2Right.tag = indexPath.row
        cell.btnGifter3Right.tag = indexPath.row
        
        cell.btnGifter1Right.addTarget(self, action: #selector(btnGifter1Right(_ : )), for: .touchUpInside)
        cell.btnGifter2Right.addTarget(self, action: #selector(btnGifter2Right(_ : )), for: .touchUpInside)
        cell.btnGifter3Right.addTarget(self, action: #selector(btnGifter3Right(_ : )), for: .touchUpInside)

        return cell
    }
    
   
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            
            if !isDataLoading {
                self.isDataLoading = true
                self.getAgencyPkListApi()
            }
        }
    }
    
    @objc func imgVwBannerDidTapped(_ sender: UIGestureRecognizer) {

        if  rewardBannerArr.count > 1{
            let zoomCtrl = VKImageZoom()
            zoomCtrl.image_url = URL(string: rewardBannerArr[1])
            zoomCtrl.modalPresentationStyle = .fullScreen
            self.present(zoomCtrl, animated: true, completion: nil)
        }
    }
     
    //MARK: Selector Methods
    
    
    @objc func dropDownAction(_ sender : UIButton){
        isExpanded.toggle()
        self.tblView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    }
    
    @objc func btnGifter1Left(_ sender : UIButton){
        
        let obj = listArray[sender.tag].giftersLeftArray[0]
        
        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = obj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @objc func btnGifter2Left(_ sender : UIButton){
        
        let obj = listArray[sender.tag].giftersLeftArray[1]

        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = obj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @objc func btnGifter3Left(_ sender : UIButton){
        let obj = listArray[sender.tag].giftersLeftArray[2]
        
        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = obj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @objc func btnGifter1Right(_ sender : UIButton){
        
        let obj = listArray[sender.tag].giftersRightArray[0]

        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = obj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @objc func btnGifter2Right(_ sender : UIButton){
        
        let obj = listArray[sender.tag].giftersRightArray[1]

        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = obj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @objc func btnGifter3Right(_ sender : UIButton){
        
        let obj = listArray[sender.tag].giftersRightArray[2]

        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = obj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    
    @objc func leftProfileAction(_ sender : UIButton){
        let userObj = listArray[sender.tag]
       
        if userObj.isLivePK == 1 || userObj.isLivePK == 1{
            let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
            viewController.leftRoomId = userObj.userId
            self.navigationController?.pushView(viewController, animated: true)
        }else{
            
            if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                viewController.otherMsIsdn = listArray[sender.tag].userId
                self.navigationController?.pushView(viewController, animated: true)
            }
        }
    }
    
    
    @objc func rightProfileAction(_ sender : UIButton){
        
        let userObj = listArray[sender.tag]
        
        if userObj.isLivePKRight == 1 || userObj.isLivePKRight == 1{
        
            let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
            viewController.leftRoomId = userObj.userIdRight
            self.navigationController?.pushView(viewController, animated: true)
        }else{
            if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                viewController.otherMsIsdn = listArray[sender.tag].userIdRight
                self.navigationController?.pushView(viewController, animated: true)
                
            }
        }
    }
    

    @objc func viewDidTapped(_ sender: UIGestureRecognizer) {
        
        // result: { type: Number, default: 0 }, // 0 = No result, 1 = winner/loser, 2 = Tie
        if let tag = sender.view?.tag {
            let userObj = listArray[tag]
            if   userObj.result == 1 || userObj.result == 2{
                
                
            }else if  userObj.userId == Themes.sharedInstance.Getuser_id(){
                
            }else if userObj.userIdRight == Themes.sharedInstance.Getuser_id(){
                
            }else{
                
                let point = sender.location(ofTouch: 0, in: view)
                
                if userObj.isLiveRight == 1 || userObj.isLivePKRight == 1{
                    let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                   
                    if (point.x) < self.view.bounds.width/2{
                        viewController.leftRoomId = userObj.userId
                    }else{
                        viewController.leftRoomId = userObj.userIdRight
                    }
                    self.navigationController?.pushView(viewController, animated: true)
                }
            }
        }
    }
}


