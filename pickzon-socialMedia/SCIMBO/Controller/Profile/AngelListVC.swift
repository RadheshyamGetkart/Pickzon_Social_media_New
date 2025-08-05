//
//  AngelListVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/2/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Alamofire


class AngelListVC: UIViewController {
    
    @IBOutlet weak var btnHistory:UIButton!
    @IBOutlet weak var btnCurrent:UIButton!
    @IBOutlet weak var viewSeperator:UIView!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var txtFdSearch:UITextField!
    @IBOutlet weak var searchBgView:UIView!
    @IBOutlet weak var lblTotalRecieved:UILabel!

    var emptyView:EmptyList?
    var selectedType = 1
    var userId = ""
    var pageNumber = 1
    var listArray = Array<JoinedUser>()
    var isDataLoading = false
    var totalCoinRecieved = 0

    //AMRK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        self.searchBgView.isHidden = true
        txtFdSearch.delegate = self
        viewSeperator.frame =  CGRect(x: btnCurrent.frame.origin.x, y: btnCurrent.frame.origin.y+btnCurrent.frame.size.height, width: btnCurrent.frame.size.width, height: 2)
        self.tblView.register(UINib(nibName: "JoinedUserTblCell", bundle: nil), forCellReuseIdentifier: "JoinedUserTblCell")
        
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        emptyView?.lblMsg?.text = ""
        emptyView?.imageView?.image = PZImages.noData
       
        self.btnCurrent.setTitleColor(.label, for: .normal)
        self.btnHistory.setTitleColor(.secondaryLabel, for: .normal)
        
        getAngelListApi()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwiped))
        swipeLeft.direction = .left
        tblView.addGestureRecognizer(swipeLeft)
    

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwiped))
        swipeRight.direction = .right
        tblView.addGestureRecognizer(swipeRight)
        
        lblTotalRecieved.text = totalCoinRecieved.asFormatted_k_String
        
        lblTotalRecieved.text = "\(totalCoinRecieved)"
    }
    
    
    //MARK: Left & Right swipe methods
    
    @objc  func leftSwiped(){
        
        self.commomBtnAction(self.btnHistory)
    }
    

    @objc func rightSwiped(){
        
        self.commomBtnAction(self.btnCurrent)
    }

    
  //MARK: UIBUtton Action Methods
    
    @IBAction func crossBtnAction(_ sender : UIButton){
        self.searchBgView.isHidden = true
        self.txtFdSearch.resignFirstResponder()
        self.txtFdSearch.text = ""
        pageNumber = 1
        self.getAngelListApi()
    }
    
    @IBAction func searchBtnAction(_ sender : UIButton){
        self.searchBgView.isHidden = false
        self.txtFdSearch.becomeFirstResponder()

    }
    @IBAction func backBtnAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commomBtnAction(_ sender : UIButton){
        
        
        self.btnCurrent.setTitleColor(.secondaryLabel, for: .normal)
        self.btnHistory.setTitleColor(.secondaryLabel, for: .normal)
        sender.setTitleColor(.label, for: .normal)

        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 2)
            self.viewSeperator.updateConstraints()
        })

        self.pageNumber = 1
        switch sender.tag{
            
        case 1000:
            selectedType = 1
            break
        case 1001:
            selectedType = 2
            break
        default:
            break
            
        }
        
        self.getAngelListApi()
        
    }
    
    //MARK: Api Methods
    func getAngelListApi(){
        
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)

        let srchText = (txtFdSearch.text ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  ?? ""
        
        let reqDict = ["pageNumber":pageNumber,"userId":userId,"search":srchText,"type":"\(selectedType)"] as [String : Any]
         
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }

        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.user_angel_list, param: reqDict as NSDictionary) { responseObject, error in
     
             Themes.sharedInstance.RemoveactivityView(View: self.view)
             self.isDataLoading = false

             if(error != nil)
             {
                 self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                 print(error ?? "defaultValue")
             }else{
                 let result = responseObject! as NSDictionary
                 let status = result["status"] as? Int ?? 0
                 let msg = result["message"] as? String ?? ""

                 
                 if status == 1 {
                     
                     if let  payloadArr = result["payload"] as? Array<Dictionary<String, Any>>{
                         
                         if self.pageNumber == 1{
                             self.listArray.removeAll()
                         }
                         for dict in payloadArr{
                             self.listArray.append(JoinedUser(respDict: dict))
                         }
                         
                         if payloadArr.count > 0 {
                             self.pageNumber = self.pageNumber + 1
                         }
                     }
                     
                     self.emptyView?.lblMsg?.text = result["message"] as? String ?? ""
                     if self.listArray.count == 0{
                         self.emptyView?.isHidden = false
                     }else{
                         self.emptyView?.isHidden = true
                     }
                     self.tblView.reloadData()
                 }else{
                     self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                 }
             }
         }
     }

}


extension AngelListVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    //MARK: - UItextfield Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
     return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text?.count ?? 0 > 0{
            pageNumber = 1
            self.txtFdSearch.resignFirstResponder()
            self.getAngelListApi()
        }
        return true
        
    }
    //MARK: Tableview data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

         return   listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedUserTblCell") as? JoinedUserTblCell
        cell?.selectionStyle = .none
        //cell?.cnstrntWidthImgVw.constant = 70
        //cell?.cnstrntHeightImgVw.constant = 70
       // cell?.imgVwProfile.layer.cornerRadius = (cell?.cnstrntHeightImgVw.constant)!/2.0
        //cell?.imgVwProfile.clipsToBounds = true
       // cell?.profileImgView.updateFrame()
        cell?.lblName.text = (listArray[indexPath.row].name.count > 0) ?  listArray[indexPath.row].name : listArray[indexPath.row].pickzonId
        
        cell?.profileImgView.setImgView(profilePic: self.listArray[indexPath.row].profilePic, frameImg: self.listArray[indexPath.row].avatar,changeValue: 6)
        
     //   cell?.imgVwProfile.kf.setImage(with: URL(string: self.listArray[indexPath.row].profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in  })
        
        cell?.btnTotalCoin.setTitle("\(self.listArray[indexPath.row].coins)", for: .normal)
        
        switch self.listArray[indexPath.row].celebrity{
        case 1:
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.greenVerification
            
        case 4:
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.goldVerification
        case 5:
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.blueVerification
            
        default:
            cell?.imgVwCelebrity.isHidden = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  self.listArray[indexPath.row].userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height + 50) >= scrollView.contentSize.height)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            
            if !isDataLoading {
                isDataLoading = true
                self.getAngelListApi()
            }
        }
    }
    
    
}
