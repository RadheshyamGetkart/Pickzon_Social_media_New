//
//  FrameSelectionVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/15/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import SVGAPlayer
import FittedSheets

class EntryStyleSelectionVC: UIViewController {

    // contains the squares
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImagVw: UIImageView!
    @IBOutlet weak var gifImgView: UIImageView!
    @IBOutlet weak var lblPickzonId: UILabel!
    @IBOutlet weak var profilePicvw: ImageWithFrameImgView!

    @IBOutlet weak var collectionVw:UICollectionView!
    @IBOutlet weak var btnApply:UIButton!
    @IBOutlet weak var btnBack:UIButton!
    
    @IBOutlet weak var animationMainBgView: UIView!
    @IBOutlet weak var purchaseSuccessBgVw:UIView!
    @IBOutlet weak var popupFrameImgVw:ImageWithSvgaFrame!
    
    
    @IBOutlet weak var svgaPlayerBgVw: UIView!

    
    var pickzonUser = PickzonUser(respdict: [:])
    var selectedRowIndex = -1
    var selectedSectionIndex = -1
    var listArray =  [EntryList]()
    var objSelectectedAvatar:Entry?
    var frameDelegate:FrameSelectionDelegate?
    var timer:Timer? = nil
    var remoteSVGAPlayer:SVGAPlayer? = nil

   
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        btnBack.setImageTintColor(.white)
        btnApply.layer.cornerRadius = 5.0
        btnApply.clipsToBounds = true
        profilePicvw.initializeView()
        lblPickzonId.text = "@" + pickzonUser.pickzonId
        profilePicvw.setImgView(profilePic: pickzonUser.profilePic, frameImg: "")
        getEntryStyleListApi()
        containerView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(appForeground), name: NSNotification.Name(Constant.sharedinstance.app_Foreground), object: nil)
        startTimer()
        purchaseSuccessBgVw.isHidden = true
    }
    
    
    func animateSVGA(remoteSVGAUrl:String){
        
        stopTimer()
        self.remoteSVGAPlayer?.stopAnimation()
        
        if remoteSVGAPlayer == nil {
            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x: 0, y: 40, width: self.animationMainBgView.frame.size.width , height: 50))
            remoteSVGAPlayer?.backgroundColor = .clear
            remoteSVGAPlayer?.loops = 0
            remoteSVGAPlayer?.clearsAfterStop = false
            self.animationMainBgView.addSubview(self.remoteSVGAPlayer!)
        }
        self.animationMainBgView.backgroundColor = .clear
        self.remoteSVGAPlayer?.contentMode = .top
        self.remoteSVGAPlayer?.isUserInteractionEnabled = true
        
        if let url = URL(string: remoteSVGAUrl) {
            let remoteSVGAParser = SVGAParser()
            remoteSVGAParser.enabledMemoryCache = true
            remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                self.remoteSVGAPlayer?.videoItem = svgaItem
                let para = NSMutableParagraphStyle()
                para.lineBreakMode = .byTruncatingTail
                para.alignment = .left
                
                let shadow = NSShadow()
                shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
                shadow.shadowBlurRadius = 0.0
                shadow.shadowColor = UIColor.black
                
                let str = NSAttributedString(
                    string: "\(self.pickzonUser.pickzonId)",
                    attributes: [
                        .font: UIFont(name: "Amaranth-Bold", size: 40.0)!,
                        .foregroundColor: UIColor.white,.shadow:shadow,
                        .paragraphStyle: para,
                    ])
                self.remoteSVGAPlayer?.setAttributedText(str, forKey: "name")
                
                self.remoteSVGAPlayer?.startAnimation()
            }, failureBlock: { (error) in
                print("--------------------- \(String(describing: error))")
                
            })
        }
    }
    
        
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    
    func startTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func scrollAutomatically(){
        
        startAnimating()
    }
    
    
    //MARK: Observers methods
    
    @objc func appForeground() {
        if selectedRowIndex >= 0{
           // self.startAnimating()
        }
    }
    
    //MARK: Other helpful methods
    
    func startAnimating(pauseAnimation:Bool = false) {
        /* containerView.isHidden = false
         self.containerView.center.x =  self.view.bounds.size.width + self.containerView.frame.width/2.0
         
         UIView.animateKeyframes(withDuration: 1.7, delay: 1.5, options: .repeat, animations: {
         
         self.containerView.center.x -= (self.view.bounds.width  - 10)
         
         }, completion: {_ in
         })
         
         */
        
        if selectedRowIndex < 0{
            return
        }
        self.gifImgView.stopAnimatingGif()

        self.containerView.isHidden = true

        guard let obj = listArray[safe: selectedSectionIndex]?.data?[selectedRowIndex] else{ return}
      
        if listArray[safe: selectedSectionIndex]?.type == 8 {
            stopTimer()
            self.animateSVGA(remoteSVGAUrl: obj.effectUrl)
        }else{
            self.profilePicvw.setImgView(profilePic: self.pickzonUser.profilePic, frameImg: obj.avatar,changeValue:5)
            self.gifImgView.setGifFromURL(URL(string: obj.effectUrl), manager: .defaultManager, loopCount: -1, showLoader: true)
            self.bgImagVw.kf.setImage(with:  URL(string: obj.url ), placeholder: PZImages.avatar, options: nil, progressBlock: nil) { response in
                
                //   self.imgVwProfile.layer.borderColor = self.bgImagVw.image?.getAverageColour?.cgColor
            }
            
            self.containerView.isHidden = true
            
            self.containerView.center.x =  self.view.bounds.size.width + self.containerView.frame.width/2.0
            
            self.containerView.alpha = 1.0
            if pauseAnimation{
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                self.containerView.isHidden = false
                
                UIView.animateKeyframes(withDuration:1.5, delay: 0, options: .beginFromCurrentState, animations: {
                    self.gifImgView.startAnimatingGif()
                    
                    self.containerView.center.x -= (self.view.bounds.width - 15)
                    
                }, completion: {_ in
                    
                    UIView.animate(withDuration: 1.0, delay: 0.9, options: .curveEaseOut,
                                   animations: {
                        self.containerView.alpha = 0
                    },
                                   
                                   completion: { _ in
                        self.containerView.isHidden = true
                        //Do anything else that depends on this animation ending
                        if pauseAnimation == false {
                            // self.startAnimating()
                        }
                    })
                })
                
                if self.timer == nil {
                    self.startTimer()
                }
            }
        }
    }
    
    func registerCell(){
        collectionVw.register(UINib(nibName: "FrameHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FrameHeaderView")
        collectionVw.register(UINib(nibName: "EntryStyleCell", bundle: nil), forCellWithReuseIdentifier: "EntryStyleCell")
    }
    
    
    
    func updateData(){
        
        //if (pickzonUser.avatarSVGA.count == 0 && isUpdated  == false) || selectedSectionIndex > 0{
        
        
        self.btnApply.isHidden = true
        
        if selectedRowIndex >= 0{
            if self.objSelectectedAvatar?.isAllowed == 0 {
                self.btnApply.isHidden = false
                self.btnApply.setTitle("Apply", for: .normal)
            }else if self.objSelectectedAvatar?.isActive == 1 {
                self.btnApply.isHidden = false
                self.btnApply.setTitle("Remove", for: .normal)
            }else {
                self.btnApply.setTitle("Apply", for: .normal)
                self.btnApply.isHidden = false
            }
        }else{
            self.containerView.isHidden = true
        }
       
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func popupcheckNowBtnAction(sender:UIButton){
        
        purchaseSuccessBgVw.isHidden = true
    }
    
    
    @IBAction func backBtnAction(_ sender : UIButton){
       
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func infoBtnAction(_ sender : UIButton){

       /* if Settings.sharedInstance.giftingLevelDesc.count > 0{
            
            let zoomCtrl = VKImageZoom()
            zoomCtrl.image_url = URL(string: Settings.sharedInstance.giftingLevelDesc)
            zoomCtrl.modalPresentationStyle = .fullScreen
            self.present(zoomCtrl, animated: true, completion: nil)
        }*/
    }
    
    @IBAction func applyBtnAction(_ sender : UIButton){
      
        if btnApply.currentTitle == "Remove"{
            if selectedSectionIndex >= 0{
                AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to remove selected occupied entry style ?", buttonTitles: ["Yes","No"], onController: self){title,index in
                    if index == 0{
                        self.addAvatarEntryStyleApi(isUpdate: 0)        
                    }
                }
            }
        }else if btnApply.currentTitle == "Apply"{
            if selectedSectionIndex >= 0{
              
                if self.objSelectectedAvatar?.isAllowed == 0{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Not enable for you.")
                }else{
                    self.addAvatarEntryStyleApi(isUpdate: 1)
                }
            }
        }
    }
    
    //MARK: Api Methods
    
    func getEntryStyleListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.sharedinstance.get_user_entry_ffect_list) { (obj:EntryStyle) in
            
            if obj.status == 1{
                self.listArray.append(contentsOf: obj.payload ?? [EntryList]())
                DispatchQueue.main.async {
                    self.collectionVw.reloadData()
                }
                self.getAppliedSVGAIndex()
            }else{

            }
            
        }
    }
    func getAppliedSVGAIndex() {
        
            for row in 0..<self.listArray.count {
                
                for  index in 0..<self.listArray[row].data!.count {
                    
                    let obj = self.listArray[row].data![index]
                    
                    if obj.isActive == 1 {
                       
                        self.gifImgView.setGifFromURL(URL(string: obj.effectUrl), manager: .defaultManager, loopCount: -1, showLoader: true)
                        self.bgImagVw.kf.setImage(with:  URL(string: obj.url ), placeholder: PZImages.avatar, options: nil, progressBlock: nil) { response in
                            
                      //  self.imgVwProfile.layer.borderColor = self.bgImagVw.image?.getAverageColour?.cgColor

                        }
                        self.profilePicvw.setImgView(profilePic: self.pickzonUser.profilePic, frameImg: obj.avatar)

                        self.containerView.center.x =  self.view.bounds.size.width + self.containerView.frame.width/2.0
                       // self.startAnimating()
                        self.objSelectectedAvatar = obj
                        self.selectedSectionIndex = row
                        self.selectedRowIndex = index
                      
                    }
                }
            }
            
            self.collectionVw.reloadWithoutAnimation()
            self.updateData()
        
    }
    
   
    func addAvatarEntryStyleApi(isUpdate:Int){
     
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)

        let urlStr = Constant.sharedinstance.change_user_entry_effect + (listArray[selectedSectionIndex].data?[selectedRowIndex].id ?? "")
        let param:NSDictionary = ["isUpdate":isUpdate]
        URLhandler.sharedinstance.makeCall(url: urlStr, param: param, methodType:.put) { responseObject, error in
            
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
                    
                    if isUpdate == 0{
                        self.selectedRowIndex = -1
                        self.selectedSectionIndex = -1
                        self.containerView.isHidden = true
                        self.updateData()
                    }
                    AlertView.sharedManager.presentAlertWith(title: "", msg: msg as NSString, buttonTitles: ["Ok"], onController: self){title,index in
                        self.navigationController?.popViewController(animated: true)
                    }
        
                    
                  /*
                    for  index in 0..<self.listArray[self.selectedSectionIndex].data!.count {
                        
                        var frameObj = self.listArray[self.selectedSectionIndex].data![index]
                        if frameObj.avatarSVGA == self.objSelectectedAvatar!.avatarSVGA {
                            //Frame removed
                            if isUpdate == 0 {
                                frameObj.isActive = 0
                                self.profileView.setImgView(profilePic: self.pickzonUser.profilePic, remoteSVGAUrl: "")
                                self.frameDelegate?.getUpdatedObject(avatar: self.pickzonUser.profilePic, svgaUrl: "")
                            }else {
                                frameObj.isActive = 1
                                self.profileView.setImgView(profilePic: self.pickzonUser.profilePic, remoteSVGAUrl: frameObj.avatarSVGA )
                                self.frameDelegate?.getUpdatedObject(avatar: self.pickzonUser.profilePic, svgaUrl: frameObj.avatarSVGA)
                            }
                            self.objSelectectedAvatar = frameObj
                        }else {
                            frameObj.isActive = 0
                        }
                            self.listArray[self.selectedSectionIndex].data?[index] = frameObj
                    }
                    self.collectionVw.reloadWithoutAnimation()
                    self.updateData()
                   */
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
}


extension EntryStyleSelectionVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: self.collectionVw.frame.size.width - 10, height:  70 )
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if listArray.count > section{
            return listArray[section].data?.count ?? 0
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionVw.dequeueReusableCell(withReuseIdentifier:  "EntryStyleCell", for: indexPath) as! EntryStyleCell
        let obj = listArray[indexPath.section].data?[indexPath.row]
        
        cell.imgVwFrame.kf.setImage(with:  URL(string: obj?.previewImage ?? ""), placeholder: PZImages.avatar, options: nil, progressBlock: nil) { response in
        }
        
      /*  cell.lblRange.text = obj?.title ?? ""
        print("obj?.isAllowed: \(obj?.isAllowed)")
        if  (obj?.isAllowed ?? 0) == 0{
            cell.imgVwNotch.isHidden = true
            cell.bgVw.layer.borderColor = UIColor.clear.cgColor
            cell.imgVwFrame.alpha = 0.6
        }else {
            
            cell.imgVwFrame.alpha = 1.0
            if indexPath.item == selectedRowIndex &&  indexPath.section == selectedSectionIndex{
                cell.bgVw.layer.borderColor = UIColor.systemYellow.cgColor
                cell.bgVw.layer.borderWidth = 2.0
                cell.imgVwNotch.isHidden = false
            }else{
                cell.bgVw.layer.borderColor = UIColor.clear.cgColor
                cell.imgVwNotch.isHidden = true
            }
        }
        */
        
        cell.imgVwFrame.alpha = 1.0
        
        if indexPath.item == selectedRowIndex &&  indexPath.section == selectedSectionIndex{
            cell.bgVw.layer.borderColor = UIColor.systemYellow.cgColor
            cell.bgVw.layer.borderWidth = 2.0
            cell.imgVwNotch.isHidden = false
            cell.bgVw.layer.cornerRadius = 5.0
            cell.bgVw.clipsToBounds = true
        }else{
            cell.bgVw.layer.borderColor = UIColor.clear.cgColor
            cell.imgVwNotch.isHidden = true
        }
        
        if listArray[indexPath.section].type == 8{
            cell.imgVwFrame.contentMode = .scaleAspectFit //.scaleAspectFill
            cell.btnDayLeft.isHidden = false
        }else{
            cell.imgVwFrame.contentMode = .scaleAspectFit
            cell.btnDayLeft.isHidden = true
        }
        cell.btnDayLeft.setTitle(((obj?.isAllowed ?? 0) == 1 ? (obj?.leftTime ?? "") : "Buy Now"), for: .normal)
        
        if (obj?.isAllowed ?? 0) == 1 && (obj?.isActive ?? 0) == 1 {
            cell.imgVwNotch.isHidden = false
        }else{
            cell.imgVwNotch.isHidden = true
        }
        
        
        cell.btnDayLeft.tag = indexPath.item
        cell.btnDayLeft.addTarget(self, action: #selector(buyNowEntry(_ : )), for: .touchUpInside)
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedSectionIndex == indexPath.section && selectedRowIndex == indexPath.row{
            return
        }
        guard let obj = listArray[safe: indexPath.section]?.data?[indexPath.row] else{ return}
        self.containerView.isHidden = true
        stopTimer()
        selectedSectionIndex = indexPath.section
        selectedRowIndex = indexPath.row
        if listArray[safe: indexPath.section]?.type == 8 {
            stopTimer()
            self.animateSVGA(remoteSVGAUrl: obj.effectUrl)
        }else{
            self.remoteSVGAPlayer?.removeFromSuperview()
            self.remoteSVGAPlayer = nil
            self.remoteSVGAPlayer?.stopAnimation()
            startAnimating()
        }
        self.objSelectectedAvatar = obj
        self.collectionVw.reloadWithoutAnimation()
        updateData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if listArray.count > section {
            if listArray[section].type == 8{
            return CGSize(width: self.collectionVw.frame.size.width, height:  75 )
            }
        }
        return CGSize(width: self.collectionVw.frame.size.width, height:  70 )
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

          let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FrameHeaderView", for: indexPath) as! FrameHeaderView
             // Configure Supplementary View
             supplementaryView.backgroundColor = UIColor.clear
             supplementaryView.lblName.text = listArray[safe: indexPath.section]?.title ?? ""
         supplementaryView.bgVwPaidDivider.isHidden = (listArray[ indexPath.section].type == 8) ? false : true
             return supplementaryView
         
         
       /* switch kind {

        case UICollectionView.elementKindSectionHeader:

            if let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FrameHeaderView", for: indexPath) as? FrameHeaderView {
                // Configure Supplementary View
                supplementaryView.backgroundColor = UIColor.clear
                supplementaryView.lblName.text = listArray[safe: indexPath.section]?.title ?? ""

                return supplementaryView
            }

            fatalError("Unable to Dequeue Reusable Supplementary View")

        default:

            assert(false, "Unexpected element kind")
        }
         return UICollectionReusableView()
        */
    }
      
    
    @objc func buyNowEntry(_ sender : UIButton){
        let buttonPosition = sender.convert(CGPoint.zero, to: self.collectionVw)
        if let indexPath = self.collectionVw.indexPathForItem(at: buttonPosition) {
            
            guard let obj = listArray[safe: indexPath.section]?.data?[indexPath.item] else{ return}
            
            if obj.isAllowed == 0 && (listArray[indexPath.section].type == 8){
                self.purchaseAvatarFramSelected(indexPath: indexPath)
            }
        }
        
    }
    
    
    @objc func purchaseAvatarFramSelected(indexPath:IndexPath) {
        if #available(iOS 13.0, *) {
            
            guard let obj = listArray[safe: indexPath.section]?.data?[indexPath.item] else{ return}

            let controller = StoryBoard.feeds.instantiateViewController(identifier: "PurchaseAvatarFrameVC")
            as! PurchaseAvatarFrameVC
            controller.planArray = obj.plans ?? []
            controller.pickzonUser = self.pickzonUser
            controller.delegate = self
            controller.svgaURL = obj.effectUrl
            controller.isAvatarPurchase = false
            let useInlineMode = view != nil
            let nav = UINavigationController(rootViewController: controller)
           
            let sheet = SheetViewController(
                controller: controller,
                sizes: [.fixed(CGFloat(490)),.intrinsic],
                options: SheetOptions(pullBarHeight : 0, shrinkPresentingViewController : false , useInlineMode: useInlineMode))
            sheet.allowPullingPastMaxHeight = false
            sheet.pullBarBackgroundColor = .clear
            
            if let view = view {
                sheet.animateIn(to: view, in: self)
            } else {
                self.present(sheet, animated: true, completion: nil)
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
}



extension EntryStyleSelectionVC : PurchaseAvatarDelegate {
    
    func purchasedAvatarEntry(svgaUrl:String) {
        purchaseSuccessBgVw.isHidden = false
        popupFrameImgVw.initializeView()
        popupFrameImgVw.setImgView(profilePic: "", remoteSVGAUrl:svgaUrl)
        popupFrameImgVw.imgVwProfile?.isHidden = true
        self.listArray.removeAll()
        self.collectionVw.reloadData()
        self.getEntryStyleListApi()
    }
}

struct EntryStyle:Codable{
   
    var status:Int?
    var message:String?
    var payload:[EntryList]?
}


struct EntryList:Codable{
    
    var title:String = ""
    var giftingLevelDesc:String = ""
    var data:[Entry]?
    var type:Int = 0
}


struct Entry:Codable {
   
    var id = ""
    var isActive = 0
    var isAllowed = 0
    var title = ""
    var url = ""
    var effectUrl = ""
    var previewImage = ""
    var avatar = ""
    var leftTime = ""
    var plans:[Plans]?
}
