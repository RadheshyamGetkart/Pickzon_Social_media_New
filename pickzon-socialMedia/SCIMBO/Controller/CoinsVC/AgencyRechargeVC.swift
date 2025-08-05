//
//  AgencyRechargeVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/23/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyRechargeVC: UIViewController {
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnRechargeNow:UIButton!
    
    var coinOfferArray = [CoinOfferModel]()
    var arrRechargeList:Array<String> = Array()
    var strRechargeTitle:String = ""
    
    var arrTermList:Array<String> = Array()
    var strTermTitle:String = ""
    var objConiSelected :CoinOfferModel = CoinOfferModel(respDict: [:])
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        
        self.btnRechargeNow.layer.cornerRadius = 5.0
        self.btnRechargeNow.clipsToBounds = true
        self.btnRechargeNow.isHidden = true
        
        tblView.register(UINib(nibName: "CheerCoinTblCell", bundle: nil), forCellReuseIdentifier: "CheerCoinTblCell")
        
        tblView.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")
        tblView.separatorColor = UIColor.clear
        tblView.isHidden = true
        self.getAgencyPlanOffersApi()
    }
    
    @IBAction func backButonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Appi Methods
    
    func getAgencyPlanOffersApi(){
        Themes.sharedInstance.activityView(View: self.view)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.agencyPlanOffersURL, param: [:]) {(responseObject, error) ->  () in
           
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        let agencyPlanOffer = payload["agencyPlanOffer"] as? Array<Any> ?? []
                        for dict in agencyPlanOffer{
                            self.coinOfferArray.append(CoinOfferModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        
                        let agencyguidelines = payload["agencyguidelines"] as? Dictionary<String, Any> ?? [:]
                        
                        let dictRecharge = agencyguidelines["recharge"] as? Dictionary<String, Any> ?? [:]
                        self.arrRechargeList =  dictRecharge["list"] as? Array<String> ?? []
                        self.strRechargeTitle = dictRecharge["title"] as? String ?? ""
                        
                        let dictTerms = agencyguidelines["terms"] as? Dictionary<String, Any> ?? [:]
                        self.arrTermList =  dictTerms["list"] as? Array<String> ?? []
                        self.strTermTitle = dictTerms["title"] as? String ?? ""
                        
                        self.tblView.reloadData()
                        self.tblView.isHidden = false
                    }
                        
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func rechargeNowAction() {
        if objConiSelected._id != "" {
            print(objConiSelected)
            let vc = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyListViewController") as! AgencyListViewController
            vc.objConiSelected = self.objConiSelected
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

extension AgencyRechargeVC :CheerCoinDelegate {
    
    
    func cheeredCoinBuyNow(obj:CoinOfferModel,isAgency: Bool) {
        print("cheeredCoinBuyNow")
        if obj._id != objConiSelected._id {
            if let index = coinOfferArray.firstIndex(where: {$0._id == obj._id}) {
                objConiSelected = obj
                objConiSelected.isSelected = true
                coinOfferArray[index] = objConiSelected
                btnRechargeNow.setBackgroundColor(UIColor.systemBlue, forState: .normal)
                for index1 in 0..<coinOfferArray.count {
                    if index1 == index {
                        coinOfferArray[index1].isSelected = true
                    }else {
                        coinOfferArray[index1].isSelected = false
                    }
                }
                
            }
        }else {
            objConiSelected = CoinOfferModel(respDict: [:])
            for index1 in 0..<coinOfferArray.count {
                    coinOfferArray[index1].isSelected = false
            }
            btnRechargeNow.setBackgroundColor(UIColor.lightGray, forState: .normal)
        }
        tblView.reloadData()
    }
}

extension AgencyRechargeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
                //return 1
            return 0
        }else if section == 1 {
            return arrRechargeList.count + 1
        }else if section == 2 {
            return arrTermList.count  + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            let count = coinOfferArray.count
            let width = CGFloat((self.view.frame.size.width/3)/2 + 30)
            let divide =  CGFloat(count/3) * width
            var  remainder = CGFloat(count % 3) * width
            if  (count % 3) > 0 && count % 3 < 3{
                remainder = width
            }else{
                remainder = 0
            }
            return  CGFloat(divide + remainder + 20)
        }
        return  UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
                let cell = tblView.dequeueReusableCell(withIdentifier: "CheerCoinTblCell") as! CheerCoinTblCell
                cell.lblTitle.text = "Choose Package"
                cell.coinOfferArray = coinOfferArray
                cell.isAgencyCell = true
                cell.collectioVwCheerCoin.reloadData()
                cell.delegate = self
                return cell
            
        }else {
            let cell = tblView.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
            
            if indexPath.row == 0{
                
                let title = (indexPath.section == 1) ? "How to recharge:" : "Terms and condition" //"Key Points for Premium users"
                cell.btnCheck.isHidden = false
                cell.lblTitle.isHidden =  true
                cell.btnCheck.setImage(nil, for: .normal)
                cell.btnCheck.setTitle(title, for: .normal)
                cell.btnCheck.contentHorizontalAlignment = .left
            }else{
                cell.btnCheck.isHidden =  false
                cell.lblTitle.isHidden =  false
                cell.btnCheck.contentHorizontalAlignment = .center
                
                cell.btnCheck.setImage(nil, for: .normal)
                if indexPath.section == 1 {
                    cell.btnCheck.setTitle("", for: .normal)
                    cell.btnCheck.setTitleColor(.systemBlue, for: .normal)
                }else {
                    cell.btnCheck.setTitle("", for: .normal)
                }
                
                cell.lblTitle.text =  (indexPath.section == 1) ? arrRechargeList[indexPath.row-1] : arrTermList[indexPath.row-1] //premiumKeyPoints[indexPath.row-1]
                cell.lblTitle.textColor = .black
            }
            return cell
       
            
        }
    }
    
    
}
