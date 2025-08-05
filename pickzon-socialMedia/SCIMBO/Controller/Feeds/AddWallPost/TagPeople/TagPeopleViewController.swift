//
//  TagPeopleViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 7/1/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

protocol TagPeopleDelegate: AnyObject {
    
    func tagPeopleDoneAction(arrTagPeople : Array<Dictionary<String, Any>>)
}

class TagPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var cnstrntNavBarHeight:NSLayoutConstraint!
    @IBOutlet weak var tblPeople:UITableView!
    @IBOutlet weak var sbSearchBar:UISearchBar!
    var arrTagPeople = Array<Dictionary<String, Any>>()
    var arrSearched =  Array<Dictionary<String, Any>>()
    var arrSelectedUser =  Array<Dictionary<String, Any>>()
    var emptyView:EmptyList?
    var tagPeopleDelegate:TagPeopleDelegate!
    var pageNumber = 1
   // var totalPages:Int16 = 0
    var pageNumberSearched = 1
   // var totalPagesSearched:Int16 = 0
    var isDataLoading = false
    var limitToselectMax = 20
    
    var isDataMoreAvailable = false
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntNavBarHeight.constant = self.getNavBarHt
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblPeople.frame.size.width, height: tblPeople.frame.size.height))
        emptyView?.imageView?.image = PZImages.noData
        emptyView?.lblMsg?.text = "Not following anyone"
        self.tblPeople.addSubview(emptyView!)
        emptyView?.isHidden = true
        tblPeople.register(UINib(nibName: "TagPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "TagPeopleTableViewCell")
        tblPeople.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        tblPeople.separatorColor = UIColor.clear
        self.getFriendsListAPI()
        sbSearchBar.delegate = self
    }
    
    //MARK: UIBUtton Action Methods
    @IBAction func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneBtnAction() {
        tagPeopleDelegate.tagPeopleDoneAction(arrTagPeople: arrSelectedUser)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API Implementation
    func getFriendsListAPI(showLoader:Bool = true) {
        
        isDataLoading = true
        if showLoader == true{
            Themes.sharedInstance.activityView(View: self.view)
        }
                
        let params = NSMutableDictionary()
        let txtSearched = sbSearchBar.text ?? ""
        if txtSearched.length == 0 {
            params.setValue(pageNumber, forKey: "pageNumber")
        }else {
            params.setValue(pageNumberSearched, forKey: "pageNumber")
        }
        params.setValue(25, forKey: "pageLimit")
        params.setValue("\(txtSearched)", forKey: "search")
        
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
        
            URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.getFriendsURL as String, param: params, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    if error != Alamofire.AFError.explicitlyCancelled as NSError {
                        self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                        print(error ?? "defaultValue")
                        self.isDataLoading = false

                    }
                }else{
                    
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    if status == 1{
                        let arrFriends = result["payload"] as? Array<Dictionary<String,Any>> ?? Array<Dictionary<String, Any>>()
                        
                        let selArr = self.arrSelectedUser as? Array<Dictionary<String,Any>> ?? Array<Dictionary<String, Any>>()
                        
                       // self.arrSelectedUser.removeAll()
                        
                        if self.pageNumber == 1 {
                            self.arrTagPeople.removeAll()
                        }
                        if self.pageNumberSearched == 1 {
                            self.arrSearched.removeAll()
                        }
                        for var obj in arrFriends {
                            obj["isSelect"] = "0"
                            
//                            if  selArr.filter({ ($0["pickzonId"] as! String) == obj["pickzonId"] as? String ?? "" }).first != nil{
//                                obj["isSelect"] = "1"
//                            }
                            
                            if  selArr.filter({ ($0["pickzonId"] as! String) == obj["pickzonId"] as? String ?? "" }).first != nil{
                                obj["isSelect"] = "1"
                            }
                            
                            if txtSearched.length == 0 {
                                self.arrTagPeople.append(obj)
                            }else {
                                self.arrSearched.append(obj)
                            }
                        }
                        
                        self.isDataMoreAvailable = (arrFriends.count == 0) ? false : true
                        
                        DispatchQueue.main.async {
                            self.tblPeople.reloadData {
                                self.isDataLoading = false
                            }
                        }
                        
                        if txtSearched.length == 0 {
                           // self.totalPages = result["totalPages"] as? Int16 ?? 0
                           // if arrFriends.count < result["totalRecords"] as? Int16 ?? 0 {
                                self.pageNumber = self.pageNumber + 1
                           // }
                        }else {
                           // self.totalPagesSearched = result["totalPages"] as? Int16 ?? 0
                          //  if arrFriends.count < result["totalRecords"] as? Int16 ?? 0 {
                                self.pageNumberSearched = self.pageNumberSearched + 1
                          //  }
                        }
                        
                    }
                    else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        self.isDataLoading = false

                    }
                    
                   DispatchQueue.main.async {
                        if txtSearched.length == 0 {
                            if  self.arrTagPeople.count == 0{
                                self.emptyView?.isHidden = false
                            }else {
                                self.emptyView?.isHidden = true
                            }
                        }else{
                            if  self.arrSearched.count == 0{
                                self.emptyView?.isHidden = false
                            }else {
                                self.emptyView?.isHidden = true
                            }
                        }
                    }
                }
            })
    }
    
    
    @objc func selectUserAction(sender:UIButton){
        
        if sbSearchBar.text!.length > 0 {
            if arrSearched.count < sender.tag || arrSearched.count == 0 {
                return
            }
            var dict = arrSearched[sender.tag]
            
            //may be dict added from arrselected user or from searched users i.e. removed from the list
            for var i in 0..<arrSelectedUser.count{
                if arrSelectedUser.count > i {
                    
                    let obj = arrSelectedUser[i]
                   
                    if obj["pickzonId"] as? String == dict["pickzonId"] as? String {
                        arrSelectedUser.remove(at: i)
                        i = i-1
                    }
                }
            }
            
            if dict["isSelect"] as? String ?? "0" == "0" {
                if arrSelectedUser.count >= limitToselectMax{
                    self.view.makeToast(message: "You can tag only 20 users at a time." , duration: 2, position: HRToastActivityPositionDefault)
                    return
                }
                dict["isSelect"] = "1"
                 arrSearched[sender.tag] = dict
                 arrSelectedUser.append(dict)
            }else {
                dict["isSelect"] = "0"
                arrSearched [sender.tag] = dict
            }
        } else {
            
            if arrTagPeople.count < sender.tag || arrTagPeople.count == 0{
                return
            }
           var dict = arrTagPeople[sender.tag]
            
            //may be dict added from arrselected user or from searched users i.e. removed from the list
            for var i in 0..<arrSelectedUser.count{
                if arrSelectedUser.count > i {
                let obj = arrSelectedUser[i]

                    
                    if obj["pickzonId"] as? String == dict["pickzonId"] as? String {
                    arrSelectedUser.remove(at: i)
                    i = i-1
                }
                }
            }
            
            if dict["isSelect"] as? String ?? "0" == "0" {
                if arrSelectedUser.count >= limitToselectMax{
                    self.view.makeToast(message: "You can tag only \(limitToselectMax) users at a time." , duration: 2, position: HRToastActivityPositionDefault)
                    return
                }
                dict["isSelect"] = "1"
                arrTagPeople[sender.tag] = dict
                arrSelectedUser.append(dict)
            }else {
                dict["isSelect"] = "0"
                arrTagPeople[sender.tag] = dict
            }
        }
        tblPeople.reloadData()
    }
    
    //MARK: - TableviewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let arrcheck = (sbSearchBar.text!.length > 0) ? arrSearched : arrTagPeople
       // let pageNoCheck = (sbSearchBar.text!.length > 0) ? pageNumberSearched : pageNumber
       // let totalPageCheck = (sbSearchBar.text!.length > 0) ? totalPagesSearched : totalPages
        if (arrcheck.count >= 13) && isDataMoreAvailable { //} && (pageNoCheck <= totalPageCheck)){
           return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return 1
        }
        if sbSearchBar.text!.length > 0 {
//            if  self.arrSearched.count == 0{
//                self.emptyView?.isHidden = false
//            }else {
//                self.emptyView?.isHidden = true
//            }
            return arrSearched.count
        }else {
            
//            if  self.arrTagPeople.count == 0{
//                self.emptyView?.isHidden = false
//            }else {
//                self.emptyView?.isHidden = true
//            }
            
            return arrTagPeople.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
          //  cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagPeopleTableViewCell", for: indexPath) as! TagPeopleTableViewCell
        cell.selectionStyle = .none
        
        var dict = Dictionary<String, Any>()
        
        if sbSearchBar.text!.length > 0 {
            dict = arrSearched[indexPath.row]
        } else {
            dict = arrTagPeople[indexPath.row]
        }

        cell.lblUserName.text =  "\(dict["pickzonId"] as? String ?? "")"
        cell.lblName.text = dict["name"] as? String ?? ""
        cell.lblName.isHidden = ((dict["name"] as? String ?? "").count > 0) ? false : true


        cell.imgCelebrity.isHidden = true
        if (dict["celebrity"] as? Int ?? 0 == 1){
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.greenVerification
        }else if (dict["celebrity"] as? Int ?? 0 == 4){
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.goldVerification
        }else if (dict["celebrity"] as? Int ?? 0 == 5){
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.blueVerification
        }
       
        var profile_pic = dict["profilePic"] as? String ?? ""
        if profile_pic.contains("http"){
            cell.profilePicView.setImgView(profilePic: profile_pic, frameImg: dict["avatar"] as? String ?? "",changeValue: 5)
        }else{
            if profile_pic.prefix(1) == "." {
                profile_pic = String(profile_pic.dropFirst(1))
            }
            cell.profilePicView.setImgView(profilePic: profile_pic, frameImg: dict["avatar"] as? String ?? "",changeValue: 5)
        }
        
        if dict["isSelect"] as? String ?? "0" == "0" {
            cell.btnSelectUser.setImage(PZImages.uncheck, for: .normal)
            
        }else {
            cell.btnSelectUser.setImage(PZImages.check, for: .normal)
        }
        cell.btnSelectUser.tag = indexPath.row
        cell.btnSelectUser.addTarget(self, action: #selector(selectUserAction(sender:)), for: .touchUpInside)
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (sbSearchBar.text!.length > 0) && arrSearched.count < indexPath.row {
            return
        }else if arrTagPeople.count < indexPath.row {
            return
        }
        let dict = ((sbSearchBar.text!.length > 0) ? arrSearched : arrTagPeople)[indexPath.row]
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  (dict["userId"] as? String ?? "")
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else  if !isDataLoading {
                if sbSearchBar.text!.length != 0 {
                  //  if self.totalPagesSearched >= pageNumberSearched {
                        self.getFriendsListAPI()
                   // }
                }else {
                    //if self.totalPages >= pageNumber {
                        self.getFriendsListAPI()
                   // }
                }
            }
        }
    }
    
   /* func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       
        if scrollView == tblPeople{
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)  {
                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                    
                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else  if !isDataLoading {
                    if sbSearchBar.text!.length != 0 {
                        if self.totalPagesSearched >= pageNumberSearched {
                            self.getFriendsListAPI()
                        }
                    }else {
                        if self.totalPages >= pageNumber {
                            self.getFriendsListAPI()
                        }
                    }
                }
            }
        }
    }*/
    
    //MARK: - UISearchbar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        
        
       /* arrSearched.removeAll()
        
            for obj in arrTagPeople {
                let first_name = obj["name"] as? String ?? ""
                let pickzonId = obj["pickzonId"] as? String ?? ""
                if first_name.lowercased().hasPrefix(searchText.lowercased()) || pickzonId.lowercased().hasPrefix(searchText.lowercased()) {
                    arrSearched.append(obj)
                }
            }
        */
        if searchText.length != 0 {
            self.arrSearched.removeAll()
            pageNumberSearched = 1
          //  totalPagesSearched = 0
            self.getFriendsListAPI(showLoader: false)
        }else {
            pageNumber = 1
          //  totalPages = 0
            self.arrTagPeople.removeAll()
            tblPeople.reloadData()
            self.getFriendsListAPI(showLoader: false)
        }
    }
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        if sbSearchBar.text!.length > 0 {
            self.arrSearched.removeAll()
            pageNumberSearched = 1
           // totalPagesSearched = 0
            self.getFriendsListAPI(showLoader: false)
        }else {
            pageNumber = 1
           // totalPages = 0
            self.arrTagPeople.removeAll()
            tblPeople.reloadData()
            self.getFriendsListAPI(showLoader: false)
        }
    }
}
