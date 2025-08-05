//
//  ParticipateEventsVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/5/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher



class ParticipateEventsVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblNavTitle:UILabel!
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var imgVwBanner:UIImageView!
    @IBOutlet weak var btnCheckAll:UIButton!
    @IBOutlet weak var btnSubmit:UIButton!
    var strTitle = ""
    var banner = ""
    var listArray = ["Rose Day","Propose Day","Chocolate Day","Teddy Day","Kiss Day","Valentine's Day"]
    var selectedIdArray = [Int]()
    var hideIdArray = [Int]()
    var completedEventArray = [Int]()
   /*
    Static Id's to Participate -->> Jaspreet Singh, Naresh Kumar sir
    Rose -- 17,
    Propose  -- 18,
    Chocolate -- 19,
    Teddy -- 20,
    Kiss -- 21,
    Valentine -- 22*/
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cnstrntHtNavbar.constant = self.getNavBarHt
        lblNavTitle.text = strTitle
        registerCells()
        btnCheckAll.layer.cornerRadius = 5.0
        btnCheckAll.clipsToBounds = true
        
        btnSubmit.layer.cornerRadius = 5.0
        btnSubmit.clipsToBounds = true
        
        getListOfEventsApi()
    }
    
    
    //MARK: Other Helpful Methods
    func registerCells(){
        self.imgVwBanner.kf.setImage(with: URL(string: banner), placeholder: PZImages.dummyCover)
        tblView.register(UINib(nibName: "EventTypeTblCell", bundle: nil), forCellReuseIdentifier: "EventTypeTblCell")
    }
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func submitButtonAction(_ sender : UIButton){
        
        if selectedIdArray.count == 0{
            self.view.makeToast(message: "Please select events you want to participate." , duration: 3, position: HRToastActivityPositionDefault)

        }else{
            self.submitFormApi()
        }
    }
    
   
    @IBAction func checkAllButtonAction(_ sender : UIButton){
        
        
        /*  if selectedIdArray.contains(17) {
              //Rose
              
          }else if selectedIdArray.contains(18){
              //Propose  -- 18
          }else if selectedIdArray.contains(19){
              //Chocolate -- 19
          }else if selectedIdArray.contains(20){
              //Teddy -- 20
          }else if selectedIdArray.contains(21){
              // Kiss -- 21
          }else if selectedIdArray.contains(22){
              // Valentine -- 22
          }
          */
       // selectedIdArray = [17,18,19,20,21,22]
        
        let itemsArr = [17,18,19,20,21,22]
        
        for item in itemsArr{
            
            if completedEventArray.contains(item) {
                
            }else{
                if !selectedIdArray.contains(item){
                    selectedIdArray.append(item)
                }
            }
        }
       
        self.tblView.reloadAnimately {
            
        }

    }
    
    //MARK: Api Methods
    func getListOfEventsApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetAPICall(url: Constant.sharedinstance.weekEvents_fetch_week_events, param: [:]) {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            

            if(error != nil) {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    
                    
                    if let payload = result["payload"] as?  Dictionary<String,Any>{
                        
                        if let selectedEvent = payload["selectedEvent"] as?  Array<Int>{
                            self.selectedIdArray = selectedEvent
                        }
                        
                        if let completedEvent = payload["completedEvent"] as?  Array<Int>{
                            self.completedEventArray = completedEvent
                        }
                        
                        DispatchQueue.main.async{
                            self.tblView.reloadData()
                        }
                    }
                    
                }else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    
    func submitFormApi(){
        
        let params = ["eventId":selectedIdArray] as [String : Any]
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.weekEvents_add_week_events, param: params as NSDictionary, completionHandler: {(responseObject, error) ->  () in
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
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self, dismissBlock:{ title, index in
                        
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}


extension ParticipateEventsVC:UITableViewDelegate,UITableViewDataSource{
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTypeTblCell") as! EventTypeTblCell
        
        cell.lblTitle.text = listArray[indexPath.item]
        
        
        if selectedIdArray.contains(indexPath.row + 17){
            cell.btnCheckBox.setImage(UIImage(named: "chkSel"), for: .normal)

        }else{
            cell.btnCheckBox.setImage(UIImage(named: "chkUnSel"), for: .normal)
        }
        
        
        if completedEventArray.contains(indexPath.row + 17){
            cell.btnCheckBox.isUserInteractionEnabled = false
            cell.bgVw.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }else{
            cell.btnCheckBox.isUserInteractionEnabled = true
            cell.bgVw.backgroundColor = .clear
        }
        
      /*  if selectedIdArray.contains(17) {
            //Rose
            
        }else if selectedIdArray.contains(18){
            //Propose  -- 18
        }else if selectedIdArray.contains(19){
            //Chocolate -- 19
        }else if selectedIdArray.contains(20){
            //Teddy -- 20
        }else if selectedIdArray.contains(21){
            // Kiss -- 21
        }else if selectedIdArray.contains(22){
            // Valentine -- 22
        }
        */
        cell.btnCheckBox.tag = 17 + indexPath.row
        cell.btnCheckBox.addTarget(self, action: #selector(selectionBtnAction(_ : )), for: .touchUpInside)
        
        return cell
        
    }
    
    
    
    //MARK: Selector methods
    
    
    @objc func selectionBtnAction(_ sender: UIButton) {
        
        if selectedIdArray.contains(sender.tag) {            
            selectedIdArray.remove(at: sender.tag)
        }else{
            selectedIdArray.append(sender.tag)

        }
        self.tblView.reloadAnimately {

        }
    }
    
}
