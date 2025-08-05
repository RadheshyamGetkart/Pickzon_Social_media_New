//
//  BlockedUserVC.swift
//  SCIMBO
//
//  Created by SachTech on 10/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit

class BlockedUserVC: UIViewController {
   
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var cntrntHtSearch: NSLayoutConstraint!
    @IBOutlet weak var txtFdSearch: UITextField!
    @IBOutlet weak var blockedTbl: UITableView!
    @IBOutlet weak var noDataView: UIView!
   
    var blockedList = [BlockUserModel]()
    var pageNo = 1
    var totalPages = 0
    var isDataLoading = false
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BlockedUserVC")
        cntrntHtSearch.constant = 0
        txtFdSearch.delegate = self
        getBlockedList()
    }
    
    //MARK: UIBUtton Action methods
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        if  cntrntHtSearch.constant > 0{
            cntrntHtSearch.constant = 0
            txtFdSearch.resignFirstResponder()
        }else{
            cntrntHtSearch.constant = 40
            txtFdSearch.becomeFirstResponder()
        }
    }
    
    //MARK: Api Methods
    func getBlockedList(){
        
        Themes.sharedInstance.activityView(View: self.view)
        let param:NSDictionary = [:]
        
        let url =  Constant.sharedinstance.getBlockUserList + (("/\(pageNo)?keyword=\(txtFdSearch.text ?? "")").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        self.isDataLoading = true
        URLhandler.sharedinstance.makeGetCall(url:url as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self.totalPages = result["totalPages"] as? Int ?? 0
                
                if status == 1 {
                    if self.pageNo == 1{
                        self.blockedList.removeAll()
                    }
                    let data = result.value(forKey: "payload") as? NSArray ?? []
                    for d in data
                    {
                        self.blockedList.append(BlockUserModel(dict: d as? NSDictionary ?? [:]))
                    }
                    
                    if self.blockedList.count < 1
                    {
                        self.noDataView.isHidden = false
                    }else{
                        self.noDataView.isHidden = true
                    }
                    self.blockedTbl.reloadData()
                    self.pageNo = self.pageNo + 1
                    self.isDataLoading = false
                    
                }else{
                    self.noDataView.isHidden = false
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func unblockUser(id:String,index:Int){
        
        let param:NSDictionary = ["blockuserId":id,"key":0]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.blockUnblockuser as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                if status == 1{
                    self.blockedList.remove(at: index)
                    self.blockedTbl.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}


extension BlockedUserVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    //MARK: UItextfield Delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        txtFdSearch.text = ""
        pageNo = 1
        totalPages = 0
        self.getBlockedList()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            print(updatedText)
        }
        
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text?.count ?? 0 > 0{
            pageNo = 1
            totalPages = 0
            self.getBlockedList()
        }
        return true
    }
    
    //MARK: UITableview Delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = blockedTbl.dequeueReusableCell(withIdentifier: "SearchUserTVC") as! SearchUserTVC
        
        cell.descriptionLbl.text =  blockedList[indexPath.row].name
        
        cell.profileImgView.setImgView(profilePic:  blockedList[indexPath.row].profilePic, frameImg:  blockedList[indexPath.row].avatar)
        cell.userNameLbl.text = "@\(blockedList[indexPath.row].pickzonId)"
        cell.watchBtn.tag = indexPath.row
        cell.watchBtn.addTarget(self, action: #selector(unBlockUser(sender:)), for: .touchUpInside)
        cell.descriptionLbl.isHidden = (blockedList[indexPath.row].name.count >  0) ? false : true
        cell.imgVwCelecbrity.isHidden = true
         if blockedList[indexPath.row].celebrity == 1{
            cell.imgVwCelecbrity.isHidden = false
            cell.imgVwCelecbrity.image = PZImages.greenVerification
        }else if blockedList[indexPath.row].celebrity == 4{
            cell.imgVwCelecbrity.isHidden = false
            cell.imgVwCelecbrity.image = PZImages.goldVerification
        }else if blockedList[indexPath.row].celebrity == 5{
            cell.imgVwCelecbrity.isHidden = false
            cell.imgVwCelecbrity.image = PZImages.blueVerification
        }
        
        return cell
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            if isDataLoading == false && pageNo <= totalPages{
                self.isDataLoading = true
                self.getBlockedList()
            }
        }
    }
    
    //MARK: Selector Methods
    @objc func unBlockUser(sender:UIButton){
        
        unblockUser(id: blockedList[sender.tag].userId,index: sender.tag)
    }
    
}
