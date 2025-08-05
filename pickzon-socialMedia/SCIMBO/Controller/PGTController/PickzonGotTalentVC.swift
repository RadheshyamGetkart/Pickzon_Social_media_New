//
//  PickzonGotTalentVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 09/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import FittedSheets
import Kingfisher
import AVFoundation
import AVKit

class PickzonGotTalentVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var bgVwFirstHeader:UIView!
    @IBOutlet weak var bgVwSecondHeader:UIView!
    @IBOutlet weak var btnVideo:UIButton!

    var listArray = [PGTModel]()
    var  guideline = ""
    var  winnerPrizeDetails = ""
    var guidelineVideoURL = ""
    var isDataLoading = false
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bgVwFirstHeader.layer.cornerRadius = 8.0
        bgVwFirstHeader.clipsToBounds = true
        bgVwSecondHeader.layer.cornerRadius = 8.0
        bgVwSecondHeader.clipsToBounds = true
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "PGTTblCell", bundle: nil), forCellReuseIdentifier: "PGTTblCell")
        tblView.refreshControl = topRefreshControl
        getPGTTalentApi()
    }
 
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if self.isDataLoading == false{
            self.isDataLoading = true
            self.listArray.removeAll()
            self.tblView.reloadData()
            self.getPGTTalentApi()
        }
        refreshControl.endRefreshing()
    }
    
    
    //MARK: UIButton Action Methods
    
    @IBAction func backBtnAction(_ sender:UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
   
    
    @IBAction func howToParticipateBtnAction(_ sender:UIButton){
       
        let vc = StoryBoard.premium.instantiateViewController(withIdentifier: "VideoPlayerVC") as! VideoPlayerVC
        vc.videoURL = guidelineVideoURL
        vc.strTitle = "How To Participate"
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func knowBtnAction(_ sender:UIButton){
        
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
        vc.urlString = Constant.sharedinstance.guidelines_hashTagPgtGuidelines
        vc.isHtmlString = true
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Api Methods
    func getGuidelinesApi(){
        
        let hashTag = listArray.first?.title as? String ?? ""
        let strUrl = "\(Constant.sharedinstance.hash_tag_guidelines)?hashTag=\(hashTag)"

        URLhandler.sharedinstance.makeGetCall(url: strUrl, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                _ = result["message"]
                
                if status == 1 {
                    
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                       
                        if  let guidelineVideo = payload["guidelineVideo"] as? Dictionary<String,Any> {
                            
                            self.guidelineVideoURL = guidelineVideo["url"] as? String ?? ""
                            let thumbUrl = guidelineVideo["thumbUrl"] as? String ?? ""
                            self.btnVideo.kf.setImage(with: URL(string: thumbUrl), for: .normal)
                        }
                    
                        if  let guideline = payload["guideline"] as? String {
                            self.guideline = guideline
                        }
                        
                        if let winnerPrizeDetails = payload["winnerPrizeDetails"] as? String {
                            self.winnerPrizeDetails = winnerPrizeDetails
                        }
                    }
                }
            }
        }
    }
    
    
    func getPGTTalentApi(){
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.hash_tag_got_talent , param: [:]) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    if let  payload = result["payload"] as? Array<Dictionary<String, Any>>{
                        
                        for dict in payload{
                            
                            self.listArray.append(PGTModel(respDict: dict))
                        }
                    }
                    self.tblView.reloadData()
                    if  self.listArray.count > 0 {
                        self.getGuidelinesApi()
                    }
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
}


extension PickzonGotTalentVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if listArray.count == 0 { return 0}else{ return 2 }
       
    }
    
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PGTTblCell") as! PGTTblCell
        
        cell.lblPGTMonth.text = listArray[indexPath.section].date
        
        if indexPath.row == 1{
            cell.btnNext.setTitle(listArray[indexPath.section].totalViews.asFormatted_k_String + " views", for: .normal)
            
            if let layout1 = cell.collectionVw.collectionViewLayout as? UICollectionViewFlowLayout {
                if  layout1.scrollDirection == .vertical {
                    
                  //  let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    layout1.scrollDirection = .horizontal
                    layout1.minimumInteritemSpacing = 0
                    layout1.minimumLineSpacing = 5
//                    cell.collectionVw.collectionViewLayout = layout
                }
            }
            cell.listArray = listArray[indexPath.section].clipsArray
            cell.lblPGTTitle.text = listArray[indexPath.section].title.uppercased()
            cell.btnArrow.setImage(UIImage(named: "NextIcon"), for: .normal)
            cell.isWinner = false
            cell.bgVwMain.isHidden = false
        }else{
            cell.listArray = listArray[indexPath.section].winnersClipsArray
            cell.btnNext.setTitle("Detail", for: .normal)
            if let layout1 = cell.collectionVw.collectionViewLayout as? UICollectionViewFlowLayout {
                if  layout1.scrollDirection == .horizontal {
                   // let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    layout1.scrollDirection = .vertical
                    layout1.minimumInteritemSpacing = 0
                    layout1.minimumLineSpacing = 5
//                    cell.collectionVw.collectionViewLayout = layout
                }
            }
            cell.lblPGTTitle.text = listArray[indexPath.section].title.uppercased() + " WINNERS"
            cell.btnArrow.setImage(UIImage(named: "octicon_info-16"), for: .normal)
            cell.isWinner = true
            cell.bgVwMain.isHidden =  (listArray[indexPath.section].winnersClipsArray.count == 0) ? true : false
        }
        cell.collectionVw.collectionViewLayout.invalidateLayout()

        cell.hashtagKeyword = listArray[indexPath.section].title
        cell.btnNext.tag = indexPath.row
        cell.btnNext.addTarget(self, action: #selector(viewAllBtnAction(_ : )), for: .touchUpInside)
        cell.updateHtOfCollection()
        cell.collectionVw.reloadData()
        
        return cell
    }
    
    //MARK: Selector methods
    @objc func viewAllBtnAction(_ sender : UIButton){
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblView)
        if let indexPath = self.tblView.indexPathForRow(at:buttonPosition){
            
            if indexPath.row == 1{
                let vc:PGTClipsVC = StoryBoard.promote.instantiateViewController(withIdentifier: "PGTClipsVC") as! PGTClipsVC
                vc.pgtObj = listArray[indexPath.section]
                self.navigationController?.pushView(vc, animated: true)
            }else{
                                  
                    if #available(iOS 13.0, *) {
                        let controller = StoryBoard.promote.instantiateViewController(identifier: "GuideLinesVC")
                        as! GuideLinesVC
                        controller.isHtmlText = winnerPrizeDetails
                        controller.title = ""
                        let useInlineMode = view != nil
                        let nav = UINavigationController(rootViewController: controller)
                        let sheet = SheetViewController(
                            controller: nav,
                            sizes: [.percent(0.55),.intrinsic],
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
        }
    }
}





