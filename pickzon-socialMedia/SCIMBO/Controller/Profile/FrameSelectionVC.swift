//
//  FrameSelectionVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/15/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import FittedSheets


protocol FrameSelectionDelegate: AnyObject{
    func getUpdatedObject(avatar:String, svgaUrl:String)
}


class FrameSelectionVC: UIViewController {

    var pickzonUser = PickzonUser(respdict: [:])

    @IBOutlet weak var collectionVw:UICollectionView!
    @IBOutlet weak var profileView:ImageWithSvgaFrame!
    @IBOutlet weak var lblPickzonId:UILabel!
    @IBOutlet weak var btnApply:UIButton!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var purchaseSuccessBgVw:UIView!
    @IBOutlet weak var popupFrameImgVw:ImageWithSvgaFrame!
    
    var selectedRowIndex = -1
    var selectedSectionIndex = -1
    var listArray =  [AvatarList]()
    var objSelectectedAvatar:Avatar?
    var frameDelegate:FrameSelectionDelegate?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        btnBack.setImageTintColor(.white)
        purchaseSuccessBgVw.isHidden = true
        btnApply.layer.cornerRadius = 5.0
        btnApply.clipsToBounds = true
        
        lblPickzonId.text = "@" + pickzonUser.pickzonId
        profileView.initializeView()
        profileView.setImgView(profilePic:  pickzonUser.profilePic, remoteSVGAUrl:  pickzonUser.avatarSVGA,changeValue: 20)
        getFramesApi()
        updateData()
    }
      
    
    
    //MARK: Other helpful methods
    func registerCell(){
        
        collectionVw.register(UINib(nibName: "FrameCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FrameCollectionCell")
        collectionVw.register(UINib(nibName: "FrameHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FrameHeaderView")
    }
    
    
    
    func updateData(){
        
        if self.objSelectectedAvatar?.isAllowed == 0 {
            self.btnApply.setTitle("Get Frame", for: .normal)
        }else if self.objSelectectedAvatar?.isActive == 1 {
            self.btnApply.setTitle("Remove", for: .normal)
        }else {
           
                self.btnApply.setTitle("Apply", for: .normal)
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
        
        
        if btnApply.currentTitle == "Apply"{
            if selectedSectionIndex >= 0{
                addAvatarFrameApi(isUpdate: 1)
            }
        }else if btnApply.currentTitle == "Remove"{
            if selectedSectionIndex >= 0{
                addAvatarFrameApi(isUpdate: 0)
            }
        }else{
            /*
             type  // 1=Gifting Level,
                     // 2= Tophost,
                     // 3= Top Senders,
                     // 4= Entry Effect,
                     // 5= Weekly Tophost,
                     // 6= Weekly Top gifter
                     // 7= Paid Frames
                     // 8= Paid Entry Effect
                    // 10 = PickZon Star Top Host
             */
            
            let sectionTitle = self.listArray[selectedSectionIndex].type
          
            if sectionTitle == 1 {
                
               let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                vc.strTitle = ""
                vc.urlString = self.listArray[selectedSectionIndex].giftingLevelDesc
                vc.isFromAvtar = true
                self.navigationController?.pushViewController(vc, animated: true)
          
           }else if sectionTitle == 2 || sectionTitle == 3 {
               
               let viewController = StoryBoard.letGo.instantiateViewController(withIdentifier: "LiveLeaderBoardVC") as! LiveLeaderBoardVC
               viewController.isLastMonth = false
               (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
               
           }else if sectionTitle == 5 || sectionTitle == 6 {
               
               if let destVC:WeeklyLeaderboardVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "WeeklyLeaderboardVC") as? WeeklyLeaderboardVC {
                   self.navigationController?.pushViewController(destVC, animated: true)
               }
               
           }else if sectionTitle == 10 {
               
               if let destVC:LeaderBoardVC = StoryBoard.premium.instantiateViewController(withIdentifier: "LeaderBoardVC") as? LeaderBoardVC {
                   destVC.isLastMonth = false
                   self.navigationController?.pushViewController(destVC, animated: true)
               }
           }
        }
        
    }
    
    //MARK: Api Methods
    
    func getFramesApi(){
     
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.sharedinstance.get_user_avatar_list) { (obj:FrameAvatar) in
            
            if obj.status == 1{
                
                self.listArray.append(contentsOf: obj.payload ?? [AvatarList]())
                DispatchQueue.main.async {
                    self.collectionVw.reloadData()
                }
                self.getBuyingFramesApi()
         

            }else{

            }
        }
    }
    
    
    
    func getBuyingFramesApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.sharedinstance.get_paid_avatar_list) { (obj:FrameAvatar) in
            
            if obj.status == 1{
                if (obj.payload?.count ?? 0) > 0 {
                    self.listArray.append(contentsOf: obj.payload ?? [AvatarList]())
                }
                DispatchQueue.main.async {
                    self.getAppliedSVGAIndex()
                    self.collectionVw.reloadData()
                }
            }else{

            }
            
        }
    }
    
    
    func getAppliedSVGAIndex() {
        
       // if pickzonUser.avatarSVGA.length > 0{
            for row in 0..<self.listArray.count {
                for  index in 0..<self.listArray[row].data!.count {
                    
                    let frameObj = self.listArray[row].data![index]
                    if  (frameObj.isActive == 1) && (frameObj.isAllowed == 1) { //} || (frameObj.avatarSVGA == pickzonUser.avatarSVGA ) {
                            self.profileView.setImgView(profilePic: self.pickzonUser.profilePic, remoteSVGAUrl: frameObj.avatarSVGA ,changeValue: 20)
                            self.frameDelegate?.getUpdatedObject(avatar: self.pickzonUser.profilePic, svgaUrl: frameObj.avatarSVGA)
                        self.objSelectectedAvatar = frameObj
                        self.selectedSectionIndex = row
                        self.selectedRowIndex = index
                        break
                    }
                }
            }
            
            self.collectionVw.reloadWithoutAnimation()
            self.updateData()
        //}
    }
   
    func addAvatarFrameApi(isUpdate:Int){
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)

        let urlStr = Constant.sharedinstance.change_user_avatar_frame + (listArray[selectedSectionIndex].data?[selectedRowIndex].id ?? "")
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
                    
                    for  index in 0..<self.listArray[self.selectedSectionIndex].data!.count {
                        
                        var frameObj = self.listArray[self.selectedSectionIndex].data![index]
                        if frameObj.avatarSVGA == self.objSelectectedAvatar!.avatarSVGA {
                            //Frame removed
                            if isUpdate == 0 {
                                frameObj.isActive = 0
                                self.profileView.setImgView(profilePic: self.pickzonUser.profilePic, remoteSVGAUrl: "",changeValue: 20)
                                self.frameDelegate?.getUpdatedObject(avatar: self.pickzonUser.profilePic, svgaUrl: "")
                            }else {
                                frameObj.isActive = 1
                                self.profileView.setImgView(profilePic: self.pickzonUser.profilePic, remoteSVGAUrl: frameObj.avatarSVGA ,changeValue: 20)
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
                

                }else{

                }
                self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

            }
        }
    }
}


extension FrameSelectionVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionVw.frame.size.width/3-10, height:  150)
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listArray.count > section{
            return listArray[section].data?.count ?? 0
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionVw.dequeueReusableCell(withReuseIdentifier:  "FrameCollectionCell", for: indexPath) as! FrameCollectionCell
        let obj = listArray[indexPath.section].data?[indexPath.row]
        
        cell.imgVwFrame.kf.setImage(with:  URL(string: obj?.url ?? ""), placeholder: PZImages.avatar, options: nil, progressBlock: nil) { response in
        }

        if  (obj?.isAllowed ?? 0) == 0{
            cell.imgVwFrame.alpha = 0.6
        }else {
            cell.imgVwFrame.alpha = 1.0
        }
        
        if obj?.isAllowed == 1  && obj?.isActive == 1 {
            cell.lblOccupied.isHidden = false
        }else {
            cell.lblOccupied.isHidden = true
        }
        
        if indexPath.item == selectedRowIndex &&  indexPath.section == selectedSectionIndex{
            cell.bgVw.layer.borderColor = UIColor.systemYellow.cgColor
            cell.bgVw.layer.borderWidth = 2.0
            cell.imgVwNotch.isHidden = false
            cell.bgVw.layer.cornerRadius = 5.0
            cell.bgVw.clipsToBounds = true
        }else{
            cell.imgVwNotch.isHidden = true
            cell.bgVw.layer.borderColor = UIColor.clear.cgColor
        }
        
        if listArray[indexPath.section].type == 7 && (obj?.isAllowed ?? 0) == 1 {
            
            cell.lblRange.attributedText = self.getTextfromImageAndString(name: obj?.leftTime ?? "", isImageAttached: false)
            cell.bgVwLblRange.secondColor = Themes.sharedInstance.colorWithHexString(hex: "06D902")
            cell.bgVwLblRange.firstColor = Themes.sharedInstance.colorWithHexString(hex: "D2FFC2")
            
        }else if listArray[indexPath.section].type == 7 && (obj?.isAllowed ?? 0) == 0{
            cell.lblRange.attributedText = self.getTextfromImageAndString(name: obj?.title ?? "", isImageAttached: true)
            cell.bgVwLblRange.secondColor = Themes.sharedInstance.colorWithHexString(hex: "FA7A0C")
            cell.bgVwLblRange.firstColor = Themes.sharedInstance.colorWithHexString(hex: "E0DF5A")
            
        }else{
            cell.lblRange.attributedText =  self.getTextfromImageAndString(name: obj?.title ?? "", isImageAttached: false)
            cell.bgVwLblRange.secondColor = Themes.sharedInstance.colorWithHexString(hex: "FA7A0C")
            cell.bgVwLblRange.firstColor = Themes.sharedInstance.colorWithHexString(hex: "E0DF5A")
        }

        return cell
    }
    
    
    func getTextfromImageAndString(name:String, isImageAttached:Bool, color:UIColor = .black, fontSize:CGFloat = 9) -> NSMutableAttributedString {
        
        let nameAttr = NSMutableAttributedString(string: "", attributes:[
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont(name:"Roboto-Regular", size: fontSize)!])
        
        if isImageAttached == false{
            
        }else{
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.bounds = CGRect(x: 0, y: -1.0, width: 9, height: 9)
            attachment.image = UIImage(named: "coinSmall")
            let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
            nameAttr.append(attachmentString)
            nameAttr.append(NSMutableAttributedString(string: " "))
        }
        
        let nameAttr1 = NSMutableAttributedString(string: name, attributes:[
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont(name:"Roboto-Regular", size: fontSize)!])
        nameAttr.append(nameAttr1)
        return nameAttr
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let obj = listArray[safe: indexPath.section]?.data?[indexPath.item] else{ return}
        
        
        
        if listArray[indexPath.section].type == 7 && obj.isAllowed == 0{
            //To display the purchase avtar
            self.purchaseAvatarFramSelected(indexPath: indexPath)
            return
        }
       
        
        
        selectedSectionIndex = indexPath.section
        selectedRowIndex = indexPath.row
        
        
        if let frameObj = listArray[safe: selectedSectionIndex]?.data?[selectedRowIndex]{
            
            self.profileView.setImgView(profilePic: pickzonUser.profilePic, remoteSVGAUrl: frameObj.avatarSVGA,changeValue: 20)
            self.objSelectectedAvatar = frameObj
            

        }
        
        self.collectionVw.reloadWithoutAnimation()
        updateData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if listArray.count > section {
            if listArray[section].type == 7{
            return CGSize(width: self.collectionVw.frame.size.width, height:  80 )
            }
        }
        return CGSize(width: self.collectionVw.frame.size.width, height:  70 )
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

          let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FrameHeaderView", for: indexPath) as! FrameHeaderView
             // Configure Supplementary View
             supplementaryView.backgroundColor = UIColor.clear
             supplementaryView.lblName.text = listArray[safe: indexPath.section]?.title ?? ""
         
            supplementaryView.bgVwPaidDivider.isHidden = (listArray[indexPath.section].type == 7) ? false : true

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
      
    
    @objc func purchaseAvatarFramSelected(indexPath:IndexPath) {
        if #available(iOS 13.0, *) {
            
            guard let obj = listArray[safe: indexPath.section]?.data?[indexPath.item] else{ return}

            let controller = StoryBoard.feeds.instantiateViewController(identifier: "PurchaseAvatarFrameVC")
            as! PurchaseAvatarFrameVC
            controller.planArray = obj.plans ?? []
            controller.pickzonUser = self.pickzonUser
            controller.svgaURL = obj.avatarSVGA
            controller.delegate = self
           
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



extension FrameSelectionVC : PurchaseAvatarDelegate{
        
    func purchasedAvatarEntry(svgaUrl:String) {
        
        purchaseSuccessBgVw.isHidden = false
        popupFrameImgVw.initializeView()
        popupFrameImgVw.setImgView(profilePic: "", remoteSVGAUrl: svgaUrl)
        self.frameDelegate?.getUpdatedObject(avatar: "", svgaUrl: svgaUrl)
        popupFrameImgVw.imgVwProfile?.isHidden = true
        self.profileView.setImgView(profilePic: pickzonUser.profilePic, remoteSVGAUrl: svgaUrl,changeValue: 20)
        self.listArray.removeAll()
        self.collectionVw.reloadData()
        self.getFramesApi()
    }
}

struct FrameAvatar:Codable{
   
    var status:Int?
    var message:String?
    var payload:[AvatarList]?
}

struct AvatarList:Codable{
    var title:String = ""
    var type:Int = 0
    var giftingLevelDesc:String = ""
    var data:[Avatar]?
}

struct Avatar:Codable{
    var id = ""
    var isActive = 0
    var isAllowed = 0
    var title = ""
    var url = ""
    var avatarSVGA = ""
    var leftTime = ""
    var plans:[Plans]?
}


struct Plans:Codable{
    var _id = ""
    var coins = 0
    var day = 0
}

/*
 type
         // 1=Gifting Level,
         // 2= Tophost,
         // 3= Top Senders,
         // 4= Entry Effect,
         // 5= Weekly Tophost,
         // 6= Weekly Top gifter
         // 7= Paid Frames
         // 8= Paid Entry Effect
 */





