//
//  DashboardVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class DashboardVC: UIViewController {
   
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblViewCount:UILabel!
    @IBOutlet weak var lblCoinSpent:UILabel!
    @IBOutlet weak var lbldateFirst:UILabel!
    @IBOutlet weak var lblDateSecond:UILabel!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    var coinsSpent = 0
    var postReached = 0
    var isDateFirstSelected = true
    var pageNumber = 1
    var fromDate = ""
    var toDate = ""
    var listArray = [BoostedPost]()
    var isDataAvailable = true
    var isDataLoading = false
    var isNeedBackBtn = false
    var emptyView:EmptyList?

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if isNeedBackBtn{
            cnstrntHtNavBar.constant = self.getNavBarHt
        }else{
            cnstrntHtNavBar.constant = 0

        }
        tblView.register(UINib(nibName: "BoostedPostCell", bundle: nil), forCellReuseIdentifier: "BoostedPostCell")
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        let day = Date().dateBeforeOrAfterFromToday(numberOfDays: -28)
        fromDate = day.getDateFormat(formatString: "yyyy/MM/dd")
        toDate = Date().getDateFormat(formatString: "yyyy/MM/dd")
        
        let dayDiff = Calendar.current.dateComponents([.day], from: day, to: Date()).day ?? 1
        
        getBoostedPostOverviewApi()
        getboostedPostHistoryApi()
        
        self.lbldateFirst.text = "Post, Last \(dayDiff) days"
        self.lblDateSecond.text = "Post, Last \(dayDiff) days"
        
        self.emptyView = EmptyList(frame: CGRect(x: 0, y: 280, width:  self.tblView.frame.size.width, height:  self.tblView.frame.size.height-280))
        self.tblView.addSubview(self.emptyView!)
        self.emptyView?.isHidden = true
        self.emptyView?.lblMsg?.text = ""
        self.emptyView?.imageView?.image = PZImages.noData

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear DashboardVC")
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func backBtnAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func filterFirstBtnAction(_ sender:UIButton){
        isDateFirstSelected = true
        let destVC:FilterBoostVC = StoryBoard.promote.instantiateViewController(withIdentifier: "FilterBoostVC") as! FilterBoostVC
        destVC.delegate = self
        self.presentView(destVC, animated: true)
        
    }
    
    @IBAction func filterSecondBtnAction(_ sender:UIButton){
        isDateFirstSelected = false

        let destVC:FilterBoostVC = StoryBoard.promote.instantiateViewController(withIdentifier: "FilterBoostVC") as! FilterBoostVC
        destVC.delegate = self
        self.presentView(destVC, animated: true)
        
    }
    
    //MARK: Api Methods
    
    
    
    func getBoostedPostOverviewApi(){
        
        let params = ["fromDate":fromDate,"toDate":toDate]

        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)
      
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.get_boost_performance_overview, param: params as NSDictionary) { (responseObject, error) ->  () in
            
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
                   if let payload = result["payload"] as? Dictionary<String,Any>{
                       
                       self.coinsSpent = payload["coinsSpent"] as? Int ?? 0
                       self.postReached = payload["postReached"] as? Int ?? 0
                       self.lblCoinSpent.text = "\(self.coinsSpent)"
                       self.lblViewCount.text = self.postReached.asFormatted_k_String
                    }
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    
    func getboostedPostHistoryApi(){
        
        let params = ["fromDate":fromDate,"toDate":toDate,"pageNumber":"\(pageNumber)"]
        isDataLoading = true

        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)
      
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.get_boost_post_history, param: params as NSDictionary) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""

                if status == 1 {
                    
                  
                    if self.pageNumber == 1{
                        self.listArray.removeAll()
                    }
                   if let payload = result["payload"] as? Array<Dictionary<String,Any>>{
                        
                        for dict in payload {
                            self.listArray.append(BoostedPost(respDict: dict))
                        }
                       self.isDataAvailable = (payload.count > 8) ? true : false
                    }
                   
                    self.emptyView?.isHidden = true

                    if  self.pageNumber == 1 && self.listArray.count == 0{
                       // self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                        self.emptyView?.isHidden = false
                        self.emptyView?.lblMsg?.text = msg
                    }
                            
                    self.tblView.reloadData {
                        self.pageNumber =   self.pageNumber + 1
                        self.isDataLoading = false
                    }
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false

                }
            }
        }
    }
}


extension  DashboardVC : UITableViewDelegate,UITableViewDataSource,FilterDateDelegate{
    
    func filterSelectedDate(date1:String,date2:String,lastDays:Int){
            
        fromDate = date1
        toDate = date2

        if isDateFirstSelected{
            self.lbldateFirst.text = "Post, Last \(lastDays) days"
            getBoostedPostOverviewApi()
        }else{
            self.pageNumber = 1
            self.lblDateSecond.text = "Post, Last \(lastDays) days"
            getboostedPostHistoryApi()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return isDataAvailable ? 1 : 0
        }
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1{
            return 50
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if indexPath.section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell") as! LoadMoreTblCell
            return cell
       
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BoostedPostCell") as! BoostedPostCell
            cell.btnViewInsights.tag = indexPath.row
            cell.btnViewInsights.addTarget(self, action: #selector(viewInsightsPost(_:)), for: .touchUpInside)
            cell.bgView.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#EDEEF3")
            cell.bgView.layer.cornerRadius = 5.0
            cell.bgView.clipsToBounds = true
            cell.lblBoostedTime.text = listArray[indexPath.item].boostDate
            cell.imgVwPost.kf.setImage(with: URL(string: listArray[indexPath.item].thumbUrl), placeholder: PZImages.dummyCover, progressBlock: nil) { response in }
           
            return cell
        }
    }
    
    
    @objc func viewInsightsPost(_ sender:UIButton){
        
        let destVC:PostInsightsVC = StoryBoard.promote.instantiateViewController(withIdentifier: "PostInsightsVC") as! PostInsightsVC
        destVC.id = listArray[sender.tag].id
        destVC.feedId = listArray[sender.tag].feedId
        self.pushView(destVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (listArray.count - 1) == indexPath.row  && isDataLoading == false  && isDataAvailable == true {
            isDataLoading = true
            self.getboostedPostHistoryApi()
        }
    }
}


