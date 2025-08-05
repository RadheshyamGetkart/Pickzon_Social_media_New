//
//  WeeklyLeaderboardVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/15/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//
import FittedSheets
import UIKit

class WeeklyLeaderboardVC: UIViewController {
    var leaderboardArray = [LeaderboardModel]()
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cntrntHtNavBar:NSLayoutConstraint!
    var emptyView:EmptyList?
    var isDataLoading = false
    var isThisMonth = 1
    
    @IBOutlet weak var btnLastWeek:UIButton!
    @IBOutlet weak var btnThisWeek:UIButton!
    @IBOutlet weak var lblSeperator:UILabel!
    
    @IBOutlet weak var btnGuidelines:UIButton!


    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    //MARK: Controller Life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        cntrntHtNavBar.constant = self.getNavBarHt
        DispatchQueue.main.async{
            self.emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width:  self.tblView.frame.size.width, height:  self.tblView.frame.size.height))
            self.tblView.addSubview(self.emptyView!)
            self.emptyView?.isHidden = true
            self.emptyView?.lblMsg?.text = ""
            self.emptyView?.imageView?.image = PZImages.noData
        }
        btnGuidelines.setImageTintColor(.label)
       
        self.emptyView?.isHidden = true
        self.tblView.register(UINib(nibName: "ParticipantTblCell", bundle: nil), forCellReuseIdentifier: "ParticipantTblCell")
        getLeaderboardListApi()
        self.tblView.addSubview(self.topRefreshControl)
        
        
        
        self.lblSeperator.frame =  CGRect(x: btnLastWeek.frame.origin.x, y: btnLastWeek.frame.origin.y+btnLastWeek.frame.size.height, width: btnLastWeek.frame.size.width, height: 2)
        self.btnThisWeek.setTitleColor(.lightGray, for: .normal)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwiped))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwiped))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
       
        if isDataLoading == false{
            self.isDataLoading = true
            leaderboardArray.removeAll()
            self.tblView.reloadData()
            getLeaderboardListApi()
        }
        refreshControl.endRefreshing()
    }
    
    
    //MARK: Left & Right swipe methods
    
    @objc  func rightSwiped()
    {
        
        if isThisMonth == 0{
            return
        }
        self.btnLastWeek.setTitleColor(.secondaryLabel, for: .normal)
        self.btnThisWeek.setTitleColor(.secondaryLabel, for: .normal)
        btnThisWeek.setTitleColor(.label, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: self.btnThisWeek.frame.origin.x, y: self.btnThisWeek.frame.origin.y+self.btnThisWeek.frame.size.height, width: self.btnThisWeek.frame.size.width, height: 2) })
        
        isThisMonth = 0
        self.isDataLoading = true
        leaderboardArray.removeAll()
        self.tblView.reloadData()
        getLeaderboardListApi()
        print("right swiped ")
    }

    @objc func leftSwiped()
    {
        if isThisMonth == 1{
            return
        }
        self.btnLastWeek.setTitleColor(.secondaryLabel, for: .normal)
        self.btnThisWeek.setTitleColor(.secondaryLabel, for: .normal)
        btnLastWeek.setTitleColor(.label, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: self.btnLastWeek.frame.origin.x, y: self.btnLastWeek.frame.origin.y+self.btnLastWeek.frame.size.height, width: self.btnLastWeek.frame.size.width, height: 2) })
        
        isThisMonth = 1
        self.isDataLoading = true
        leaderboardArray.removeAll()
        self.tblView.reloadData()
        getLeaderboardListApi()
    }
    
    
    //MARK: UIButton Action Methods
    @IBAction  func backButtonActionMethod(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func guidelinesButtonActionMethod(_ sender:UIButton){
        
        if #available(iOS 13.0, *) {
            let controller = StoryBoard.promote.instantiateViewController(identifier: "GuideLinesVC")
            as! GuideLinesVC
            controller.guidelinesType = .weeklyGuidelines
            controller.title = ""
            let useInlineMode = view != nil
            let nav = UINavigationController(rootViewController: controller)
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.75),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20

            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction  func commonButtonActionMethod(_ sender:UIButton){
        
        self.btnLastWeek.setTitleColor(.secondaryLabel, for: .normal)
        self.btnThisWeek.setTitleColor(.secondaryLabel, for: .normal)
        sender.setTitleColor(.label, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lblSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 2) })
        
        switch sender.tag {
          /*
           type=0 (to get currnet week host list)
           type=1(to get previous week host list)
           */
        case 5000:
            isThisMonth = 1
            break
            
        case 5001:
            isThisMonth = 0
            break
            
        default:
            break
        }
        
        self.getLeaderboardListApi()
    }
    
    
    
    //MARK: Api Methods
    func getLeaderboardListApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        self.isDataLoading = true
        
        let strUrl = Constant.sharedinstance.get_weekly_host_leaderboard + "?type=\(isThisMonth)"
        URLhandler.sharedinstance.makeGetAPICall(url:strUrl , param: [:]) {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.isDataLoading = false
            
            if(error != nil) {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    self.leaderboardArray.removeAll()
                    self.tblView.reloadData()
                    
                    if let payload = result["payload"] as? Array<Dictionary<String,Any>>{
                       
                        
                        for item in payload{
                            self.leaderboardArray.append(LeaderboardModel(respDict: item))
                        }
                        self.tblView.reloadData()
                    }
                    
                   

                }else
                {
                   // self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
                
                self.emptyView?.lblMsg?.text = message
                self.emptyView?.isHidden = ( self.leaderboardArray.count == 0) ? false : true
            }
        }
    }

}

extension WeeklyLeaderboardVC:UITableViewDelegate,UITableViewDataSource{
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  leaderboardArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tblView.dequeueReusableCell(withIdentifier: "ParticipantTblCell") as! ParticipantTblCell
        
        cell.backgroundColor = .clear
      //  cell.bgView.backgroundColor = .clear
        cell.imgVwGoldBg.isHidden = true
      //  cell.bgView.layer.borderWidth = 0.0
        cell.lblCoinCount.textColor = .label
        cell.lblRankNumber.textColor = .label
        cell.lblCoinCount.textColor = .label
     //   cell.btnPIckzonId.setTitleColor(.label, for: .normal)
        
        let obj =  leaderboardArray[indexPath.row]
        
        cell.lblCoinCount.text =  "\(obj.totalCoins)"
      
        cell.lblRankNumber.text = String(format: "%02d", indexPath.row + 1)
        cell.btnPIckzonId.setTitle("@\(obj.pickzonId)", for: .normal)
        cell.btnProfilePicView.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar,changeValue:(obj.avatar.count > 0) ? 8 : 5)
      
        cell.btnProfilePicView.imgVwProfile?.tag = indexPath.row
        cell.btnProfilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))

        cell.btnPIckzonId.tag = indexPath.row
        cell.btnPIckzonId.addTarget(self, action: #selector(pickzonIdBtnAction(_ : )), for: .touchUpInside)

        cell.imgVwCelebrity.isHidden = true
        
        if obj.celebrity == 1 {
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.greenVerification
        }else if obj.celebrity == 4 {
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.goldVerification
        }else if obj.celebrity == 5 {
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        return cell
    }
    
    //Mark: Selector Methods
    @objc func handleProfilePicTap(_ sender : UITapGestureRecognizer){
        if let tag = sender.view?.tag {
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  leaderboardArray[tag].userId
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    
    @objc func pickzonIdBtnAction(_ sender : UIButton){
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  leaderboardArray[sender.tag].userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

 

