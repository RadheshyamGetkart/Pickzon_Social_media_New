//
//  LeaderBoardVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class LeaderBoardVC: UIViewController {

    @IBOutlet weak var btnLastMonth:UIButton!
    @IBOutlet weak var btnThisMonth:UIButton!
    @IBOutlet weak var lblSeperator:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    var isLastMonth = true
    var lastMonthLeaderboardArray = [LeaderboardModel]()
    var thismonthLeaderboardArray = [LeaderboardModel]()
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "ParticipantTblCell", bundle: nil), forCellReuseIdentifier: "ParticipantTblCell")
        tblView.register(UINib(nibName: "ParticipantTopTblCell", bundle: nil),
                                  forHeaderFooterViewReuseIdentifier: "ParticipantTopTblCell")
        if isLastMonth == true {
            lblSeperator.frame =  CGRect(x: btnLastMonth.frame.origin.x, y: btnLastMonth.frame.origin.y+btnLastMonth.frame.size.height, width: btnLastMonth.frame.size.width, height: 2)
            if lastMonthLeaderboardArray.count == 0{
             getLeaderboardListApi()
            }
        }else{
            lblSeperator.frame =  CGRect(x: btnThisMonth.frame.origin.x, y: btnThisMonth.frame.origin.y+btnThisMonth.frame.size.height, width: btnThisMonth.frame.size.width, height: 2)
            if thismonthLeaderboardArray.count == 0{
                 getLeaderboardListApi()
            }
        }
        self.tblView.addSubview(self.topRefreshControl)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwiped))
        swipeLeft.direction = .left
        tblView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwiped))
        swipeRight.direction = .right
        tblView.addGestureRecognizer(swipeRight)
    }
    
    
    deinit{
        print("Leaderboard deinit")
    }
    
    
    //MARK: Left & Right swipe methods
    
    @objc  func rightSwiped(){
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: self.btnLastMonth.frame.origin.x, y: self.btnLastMonth.frame.origin.y + self.btnLastMonth.frame.size.height, width: self.btnLastMonth.frame.size.width, height: 2) })
        isLastMonth = true
        if lastMonthLeaderboardArray.count == 0{
            getLeaderboardListApi()
        }
        self.tblView.reloadData()
    }
    

    @objc func leftSwiped(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: self.btnThisMonth.frame.origin.x, y: self.btnThisMonth.frame.origin.y + self.btnThisMonth.frame.size.height, width: self.btnThisMonth.frame.size.width, height: 2) })
        isLastMonth = false
        getLeaderboardListApi()
    }
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if isLastMonth == false{
            getLeaderboardListApi()
        }else{
            if lastMonthLeaderboardArray.count == 0{
                getLeaderboardListApi()
            }
        }
        refreshControl.endRefreshing()
    }
    
    //MARK: UIBUtton Action Methods
    @IBAction func backButtonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func commonHeaderButtonAction(_ sender:UIButton){
        
        self.btnLastMonth.setTitleColor(.secondaryLabel, for: .normal)
        self.btnThisMonth.setTitleColor(.secondaryLabel, for: .normal)
        sender.setTitleColor(.label, for: .normal)

        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 2) })
        switch sender.tag{
            
        case 1000:
            isLastMonth = true
            if lastMonthLeaderboardArray.count == 0{
              getLeaderboardListApi()
            }
            self.tblView.reloadData()
            break
        
        case 1001:
            isLastMonth = false
            getLeaderboardListApi()
            break
            
        default:
            break
        }
     
    }
    
    //MARK: Api Methods
    
    func getLeaderboardListApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let strUrl = Constant.sharedinstance.get_leaderboard_data + "?type=\((isLastMonth ? 2 : 1))"
        
        URLhandler.sharedinstance.makeGetAPICall(url: strUrl, param: [:]) {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    if let payload = result["payload"] as? Array<Dictionary<String,Any>>{
                        if self.isLastMonth{
                             self.lastMonthLeaderboardArray.removeAll()
                        }else{
                            self.thismonthLeaderboardArray.removeAll()
                        }
                       
                        for item in payload{
                            if self.isLastMonth{
                                self.lastMonthLeaderboardArray.append(LeaderboardModel(respDict: item))
                            }else{
                                self.thismonthLeaderboardArray.append(LeaderboardModel(respDict: item))
                            }
                        }
                        self.tblView.reloadData()
                    }
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }

}


extension LeaderBoardVC:UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        if let firstTopper = (self.isLastMonth) ? self.lastMonthLeaderboardArray.first : self.thismonthLeaderboardArray.first{
            
            if (firstTopper.gifterPickzonId.count == 0) {
                return 220
            }
        }
        return 245
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let firstTopper = (self.isLastMonth) ? self.lastMonthLeaderboardArray.first : self.thismonthLeaderboardArray.first{
            
            if (firstTopper.gifterPickzonId.count == 0) {
                return 220
            }
        }
        return 245
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if ((self.isLastMonth) ? self.lastMonthLeaderboardArray : self.thismonthLeaderboardArray).count == 0{
            return nil
        }
        let cell = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "ParticipantTopTblCell")! as! ParticipantTopTblCell
        cell.leaderboardArray = (self.isLastMonth) ? self.lastMonthLeaderboardArray : self.thismonthLeaderboardArray
        
        cell.cllctionView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  (self.isLastMonth) ? max(self.lastMonthLeaderboardArray.count-3,0) : max(self.thismonthLeaderboardArray.count-3,0)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tblView.dequeueReusableCell(withIdentifier: "ParticipantTblCell") as! ParticipantTblCell
        
        if self.isLastMonth && self.lastMonthLeaderboardArray.count < (indexPath.row+3){
            return UITableViewCell()
        }else if self.thismonthLeaderboardArray.count < (indexPath.row+3) && self.isLastMonth == false{
            return UITableViewCell()
        }
        let obj =  (self.isLastMonth) ? self.lastMonthLeaderboardArray[indexPath.row+3] : self.thismonthLeaderboardArray[indexPath.row+3]
        cell.lblCoinCount.text =  obj.totalViews
        
        cell.imgVwCoin.image = PZImages.viewIcon
        cell.lblRankNumber.text = String(format: "%02d", indexPath.row + 4)
        cell.lblRankNumber.textColor = UIColor.label
        cell.btnPIckzonId.setTitle("@\(obj.pickzonId)", for: .normal)
        cell.btnProfilePicView.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar,changeValue: (obj.avatar.count > 0) ? 7 : 5)
        cell.btnProfilePicView.imgVwProfile?.tag = indexPath.row
        cell.btnProfilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))
        cell.btnPIckzonId.tag = indexPath.row
        cell.btnPIckzonId.addTarget(self, action: #selector(pickzonIdBtnAction(_ : )), for: .touchUpInside)
        cell.imgVwCelebrity.isHidden = true

        if obj.celebrity == 1{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.greenVerification
        }else if obj.celebrity == 4{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.goldVerification
        }else if obj.celebrity == 5{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        return cell
    }
    
    //Mark: Selector Methods
    
    @objc func handleProfilePicTap(_ sender : UITapGestureRecognizer){
        if let tag = sender.view?.tag {
            let obj =  (self.isLastMonth) ? self.lastMonthLeaderboardArray[tag+3] : self.thismonthLeaderboardArray[tag+3]
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  obj.userId
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    @objc func pickzonIdBtnAction(_ sender : UIButton){
        let obj =  (self.isLastMonth) ? self.lastMonthLeaderboardArray[sender.tag+3] : self.thismonthLeaderboardArray[sender.tag+3]
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  obj.userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

 
