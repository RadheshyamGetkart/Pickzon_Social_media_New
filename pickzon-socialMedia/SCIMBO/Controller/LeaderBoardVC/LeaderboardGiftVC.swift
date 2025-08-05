//
//  LeaderboardGiftVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/2/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import  Kingfisher
import FittedSheets

class LeaderboardGiftVC: UIViewController {
    
    @IBOutlet weak var imgVwBg:UIImageView!
    @IBOutlet weak var imgVwBanner:UIImageView!
    @IBOutlet weak var profilePicWithSvga:ImageWithSvgaFrame!
    @IBOutlet weak var gifterProfilePic:ImageWithSvgaFrame!
    
    @IBOutlet weak var lblNameGifter:UILabel!
    @IBOutlet weak var imgVwCelebrityGifter:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    
    @IBOutlet weak var bgVwTopCount:UIView!
    @IBOutlet weak var imgVwGiftTop:UIImageView!
    @IBOutlet weak var lblGiftCount:UILabel!

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblNavTitle:UILabel!
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var cnstrntLeadingProfile:NSLayoutConstraint!
    @IBOutlet weak var cnstrntHtTopView:NSLayoutConstraint!
    @IBOutlet weak var cnstrntTopCountVw:NSLayoutConstraint!
    @IBOutlet weak var cnstrntLeadingCountVw:NSLayoutConstraint!
    @IBOutlet weak var cnstrntWidthCountVw:NSLayoutConstraint!

    var titleStr:String = ""
    private var listArray  = [GiftLeaderboardModel]()
    private var value = 0
    private  var icon = ""
    private var topBanner = ""
    private var bottomBanner = ""
    private var reward = ""
    private var svga = ""
    private var isDataLoading  = false
    private var rowBanner = ""
    
    var bannerType = 0
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: Controller Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicWithSvga.initializeView()
        gifterProfilePic.initializeView()
        self.cnstrntHtNavbar.constant = self.getNavBarHt
        self.lblNavTitle.text = titleStr
        tblView.refreshControl = topRefreshControl
        self.updateBannerViewWithData()
        registerCells()
        imgVwCelebrityGifter.isHidden = true
        imgVwCelebrity.isHidden = true
        getLeaderboardListApi()
        //375*233nimage size of banner it should be
         self.cnstrntHtTopView.constant = 0.6 * self.view.frame.size.width
        
    }
    
    //MARK: Other Helpful Methods
    func registerCells(){
        
        tblView.register(UINib(nibName: "GiftLevelTblCell", bundle: nil), forCellReuseIdentifier: "GiftLevelTblCell")
        tblView.register(UINib(nibName: "AgencyBannerWithDDTblCell", bundle: nil), forCellReuseIdentifier: "AgencyBannerWithDDTblCell")
    }
    
    
    func updateView(position:Int){
        /*
         position = 1; hoga left,
         position = 2; hoga middle,
         Position = 3 hoga right
         profile width = 130
         */
        
        if position == 1{
            self.cnstrntLeadingProfile.constant = 10
            self.cnstrntLeadingCountVw.constant = self.tblView.frame.size.width - (cnstrntWidthCountVw.constant - 5)
            self.cnstrntTopCountVw.constant =  cnstrntHtTopView.constant - 35
        }else  if position == 2{
            self.cnstrntLeadingProfile.constant = (self.tblView.frame.size.width/2 - 65 )
            
            self.cnstrntLeadingCountVw.constant = 5
            self.cnstrntTopCountVw.constant = 5

        }else  if position == 3{
            self.cnstrntLeadingProfile.constant = (self.tblView.frame.size.width - 150 )
            
            self.cnstrntLeadingCountVw.constant = 5
            self.cnstrntTopCountVw.constant =  cnstrntHtTopView.constant - 35
        }
    }
    

//MARK: Pull to refresh
@objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
    if !isDataLoading{
        self.isDataLoading = true
        getLeaderboardListApi()

    }
    refreshControl.endRefreshing()
}

    //MARK: UIButton Action Methods
    @IBAction func backButtonAction(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func infoButtonAction(_ sender : UIButton){
        
        if #available(iOS 13.0, *) {
            let controller = StoryBoard.premium.instantiateViewController(identifier: "DescriptionPointsVC")
            as! DescriptionPointsVC
            controller.leaderboardType = .giftLeaderBoard
            let useInlineMode = view != nil
            controller.title = ""
            let nav = UINavigationController(rootViewController: controller)
//            var fixedSize = 500
//            if UIDevice().hasNotch{
//                fixedSize = 480
//            }
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.75),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            // addSheetEventLogging(to: sheet)
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
    
    
    //MARK: Api Methods
    
    func getLeaderboardListApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let strUrl = Constant.sharedinstance.get_valentine_leaderboard + "?type=\(bannerType)"
        
     
      
        
        self.isDataLoading = true
        URLhandler.sharedinstance.makeGetAPICall(url: strUrl, param: [:]) {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            self.isDataLoading = false

            if(error != nil) {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    if let payload = result["payload"] as? Dictionary<String,Any>{
                        
                        if let infoDict = payload["info"] as? Dictionary<String,Any>{
                         
                            self.value = infoDict["target"] as? Int ?? 0
                            self.icon =  infoDict["icon"] as? String ?? ""
                            self.topBanner =  infoDict["topBanner"] as? String ?? ""
                            self.bottomBanner =  infoDict["bottomBanner"] as? String ?? ""
                            self.reward =  infoDict["reward"] as? String ?? ""
                            self.svga =  infoDict["svga"] as? String ?? ""
                            self.titleStr  =  infoDict["title"] as? String ?? ""
                            self.rowBanner =  infoDict["rowBanner"] as? String ?? ""
                            let position =  infoDict["position"] as? Int ?? 0
                            DispatchQueue.main.async{
                                
                                self.updateView(position: position)
                            }
                            
                            if let guidelines = infoDict["guidelines"] as? Array<String>{
                                
                                Themes.sharedInstance.arrValentineLeaderboardsKeyPoint = guidelines
                            }
                        }
                        
                        if let payload = payload["data"] as? Array<Dictionary<String,Any>>{
                            self.listArray.removeAll()
                            for item in payload{
                                self.listArray.append(GiftLeaderboardModel(respDict: item))
                            }
                            DispatchQueue.main.async{
                                self.updateBannerViewWithData()
                                self.tblView.reloadData()
                            }
                        }
                                                
                    }
                }else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
   
}


extension LeaderboardGiftVC:UITableViewDelegate,UITableViewDataSource{
    
    //MARK: Update banner view
    func updateBannerViewWithData(){
        
        self.imgVwBanner.kf.setImage(with: URL(string: topBanner))
        self.imgVwBg.kf.setImage(with: URL(string: bottomBanner))
        
      //  self.lblBannerTitle.text = titleStr
      //  self.imgVwGift.kf.setImage(with: URL(string: icon))

//        self.bgVwNameGifter.isHidden = true
//        self.bgVwName.isHidden = true
        self.bgVwTopCount.isHidden = true
       
        if  listArray.count == 0{
            return
        }
        
         let obj = listArray[0]
        


       
        self.bgVwTopCount.isHidden = false
        self.imgVwCelebrity.isHidden = true
//        self.bgVwName.isHidden = false
//        self.bgVwNameGifter.isHidden = false
        
        self.lblGiftCount.text = "\(obj.totalCoins)"
        if obj.totalCoins >= value{
            self.lblGiftCount.textColor = UIColor.init(hexString: "05C305")
        }else{
            self.lblGiftCount.textColor = UIColor.init(hexString: "FEBB00")
        }
        self.imgVwGiftTop.kf.setImage(with: URL(string: icon))

        
        if obj.celebrity == 1{
            self.imgVwCelebrity.isHidden = false
            self.imgVwCelebrity.image = PZImages.greenVerification
        }else if obj.celebrity == 4{
            self.imgVwCelebrity.isHidden = false
            self.imgVwCelebrity.image = PZImages.goldVerification
        }else if obj.celebrity == 5{
            self.imgVwCelebrity.isHidden = false
            self.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        
        imgVwCelebrityGifter.isHidden = true
        if (obj.gifterObj?.celebrity ?? 0) == 1{
            self.imgVwCelebrityGifter.isHidden = false
            self.imgVwCelebrityGifter.image = PZImages.greenVerification
        }else if (obj.gifterObj?.celebrity ?? 0) == 4{
            self.imgVwCelebrityGifter.isHidden = false
            self.imgVwCelebrityGifter.image = PZImages.goldVerification
        }else if (obj.gifterObj?.celebrity ?? 0) == 5{
            self.imgVwCelebrityGifter.isHidden = false
            self.imgVwCelebrityGifter.image = PZImages.blueVerification
        }
        
        
        
        self.lblNameGifter.text = obj.gifterObj?.pickzonId ?? ""
        self.gifterProfilePic.setImgView(profilePic: obj.gifterObj?.profilePic ?? "", remoteSVGAUrl: obj.gifterObj?.avatarSVGA ?? "",changeValue: 7)

        
        self.lblName.text = obj.pickzonId
        self.profilePicWithSvga.setImgView(profilePic: obj.profilePic, remoteSVGAUrl: obj.avatarSVGA,changeValue: 16)
       
        self.profilePicWithSvga.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTopUserProfileTap(_:))))
        
        self.gifterProfilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGifterProfileTap(_:))))

    }
  
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == 1{
            return  (reward.length == 0) ? 0 : 1
        }
        return (listArray.count > 1) ?  (listArray.count - 1) : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1{
           return  280
        }
        return UITableView.automaticDimension
    }
    
    
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 210
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .clear
        view.tintColor = .clear

    }
  
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.backgroundColor = .clear
        view.tintColor = .clear
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GiftBannerTblCell") as! GiftBannerTblCell
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        cell.lblBannerTitle.text = titleStr
        cell.imgVwGift.kf.setImage(with: URL(string: icon), placeholder: PZImages.avatar)
        cell.btnGifterFirst.isHidden = true
        cell.btnGifterSecond.isHidden = true
        cell.btnGifterThird.isHidden = true
        cell.btnUserProfilePic.isHidden = true
        
        if  listArray.count == 0{

            return cell
        }
        
         let obj = listArray[0]
      
        cell.btnUserProfilePic.kf.setImage(with: URL(string: obj.profilePic), for: .normal, placeholder: PZImages.avatar)
        cell.btnUserProfilePic.contentMode = .scaleAspectFit
        cell.btnUserProfilePic.imageView?.contentMode = .scaleAspectFill
        cell.btnUserProfilePic.layer.cornerRadius =  cell.btnUserProfilePic.frame.size.height/2.0
        cell.btnUserProfilePic.isHidden = false

        cell.btnUserProfilePic.addTarget(self, action: #selector(profilePicBtnAction(_ : )), for: .touchUpInside)
        
        cell.btnGifterFirst.addTarget(self, action: #selector(profilePicFirstGifterBtnAction(_ : )), for: .touchUpInside)
        cell.btnGifterSecond.addTarget(self, action: #selector(profilePicSecondGifterBtnAction(_ : )), for: .touchUpInside)
        cell.btnGifterThird.addTarget(self, action: #selector(profilePicThirdGifterBtnAction(_ : )), for: .touchUpInside)


       //Need to persist ordering
                    
        cell.btnGifterFirst.layer.cornerRadius =  cell.btnGifterFirst.frame.size.height/2.0
        cell.btnGifterFirst.layer.borderWidth = 1.0
        cell.btnGifterFirst.layer.borderColor = UIColor.white.cgColor
        cell.btnGifterFirst.clipsToBounds = true
        
        
        cell.btnGifterSecond.layer.cornerRadius =  cell.btnGifterSecond.frame.size.height/2.0
        cell.btnGifterSecond.layer.borderWidth = 1.0
        cell.btnGifterSecond.layer.borderColor = UIColor.white.cgColor
        cell.btnGifterSecond.clipsToBounds = true
        
        
        cell.btnGifterThird.layer.cornerRadius =  cell.btnGifterThird.frame.size.height/2.0
        cell.btnGifterThird.layer.borderWidth = 1.0
        cell.btnGifterThird.layer.borderColor = UIColor.white.cgColor
        cell.btnGifterThird.clipsToBounds = true

        if obj.gifterArray.count > 2 {
            cell.btnGifterThird.isHidden = false
            cell.btnGifterThird.kf.setImage(with: URL(string: obj.gifterArray[2].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        
        if obj.gifterArray.count > 1 {
            cell.btnGifterSecond.isHidden = false
            cell.btnGifterSecond.kf.setImage(with: URL(string: obj.gifterArray[1].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
        
        if obj.gifterArray.count > 0 {
            cell.btnGifterFirst.isHidden = false
            cell.btnGifterFirst.kf.setImage(with: URL(string: obj.gifterArray[0].profilePic), for: .normal, placeholder: PZImages.avatar)
        }
      
        return cell
        
    }
*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgencyBannerWithDDTblCell") as! AgencyBannerWithDDTblCell
            cell.imgVwBanner.kf.setImage(with: URL(string: reward))
            cell.btnDropDown.isHidden = true
            cell.imgVwBanner.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgVwBannerDidTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            cell.imgVwBanner.addGestureRecognizer(tapGesture)
            
            return cell
        }
        
        
        let obj = listArray[indexPath.item + 1]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GiftLevelTblCell") as! GiftLevelTblCell
        cell.lblCounter.text = String(format: "%02d", indexPath.row + 2)
        cell.lblName.text = "@\(obj.pickzonId)"
        cell.lblGiftCount.text = "\(obj.totalCoins)"
        cell.imgVwGift.kf.setImage(with: URL(string: icon), placeholder: PZImages.avatar)
        cell.imgVwRow.kf.setImage(with: URL(string: rowBanner))
        cell.imgVwProfile.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar, changeValue: (obj.avatar.count > 0) ? 8 : 5)
        
        if obj.totalCoins >= value{
            cell.lblGiftCount.textColor = UIColor.init(hexString: "05C305")
        }else{
            cell.lblGiftCount.textColor = UIColor.init(hexString: "FEBB00")
        }
        
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
        
        cell.imgVwProfile.tag = indexPath.item + 1
        cell.lblName.tag = indexPath.item + 1
        
        cell.imgVwProfile.isUserInteractionEnabled = true
        cell.lblName.isUserInteractionEnabled = true
        
        cell.imgVwProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap(_:))))
        
        cell.lblName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap(_:))))
        
        return cell
        
    }
    
    
    //MARK: Selector methods
    
    @objc func imgVwBannerDidTapped(_ sender: UIGestureRecognizer) {

        if  reward.count > 1{
            let zoomCtrl = VKImageZoom()
            zoomCtrl.image_url = URL(string: reward)
            zoomCtrl.modalPresentationStyle = .fullScreen
            self.present(zoomCtrl, animated: true, completion: nil)
        }
    }
 
    
    @objc func handleGifterProfileTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if let obj = listArray.first{
            navigateToUserProfile(userId: obj.gifterObj?.userId ?? "")
        }
       
    }
    
    @objc func handleTopUserProfileTap(_ sender: UITapGestureRecognizer? = nil) {
        if let obj = listArray.first{
            navigateToUserProfile(userId: obj.userId)
        }
    }
    
    @objc func handleProfileTap(_ sender: UITapGestureRecognizer? = nil) {
        
        navigateToUserProfile(userId: listArray[sender?.view?.tag ?? 0].userId)

    }

    @objc func handlePickzonIdTap(_ sender: UITapGestureRecognizer? = nil) {
      
        navigateToUserProfile(userId: listArray[sender?.view?.tag ?? 0].userId)

    }
    
    func navigateToUserProfile(userId:String){
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = userId
        self.navigationController?.pushView(profileVC, animated: true)
    }
    
}
