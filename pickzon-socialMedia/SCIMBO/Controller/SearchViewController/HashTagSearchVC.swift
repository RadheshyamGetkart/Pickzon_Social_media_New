//
//  HashTagSearchVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 26/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class HashTagSearchVC: UIViewController {
 
    @IBOutlet weak var tblView: UITableView!
    
    var srchTxt:String = ""
    private var isDataLoading = false
    private var tagsArray = [HashtagModel]()
    private var emptyView:EmptyList?
    private var isDataMoreAvailable = true
    private var pageNo = 1
    var delegate:SearchPostSelectedDelegate?

    //MARK: Controller life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "HashTagTblCell", bundle: nil), forCellReuseIdentifier: "HashTagTblCell")
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        getHashTagApi()
        
    NotificationCenter.default.addObserver(self, selector:
                                        #selector(self.hashtagSelectedTabIndex(notification:)),
                                       name: NSNotification.Name(rawValue: "hashtagSelectedTabIndex"), object: nil)
    }
    
    
    
    @objc func hashtagSelectedTabIndex(notification: Notification) {
        
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let newToSearch = response["searchText"] as? String{
               
                if srchTxt == newToSearch{
                    
                }else{
                    srchTxt = newToSearch
                    self.pageNo = 1
                    self.getHashTagApi()
                }
            }
        }
    }
    
    //MARK: Api methods
    func getHashTagApi(){
        
        if pageNo == 1{
            self.tagsArray.removeAll()
            self.tblView.reloadData()
        }

        self.isDataLoading = true
        let strUrl = Constant.sharedinstance.feedHashTags + "?pageNumber=\(pageNo)&search=\(srchTxt)"
        
        URLhandler.sharedinstance.makeCall(url: strUrl, param: nil,methodType:.get) { responseObject, error in
        
            
            if(error != nil)
            {
                // Themes.sharedInstance.RemoveactivityView(View: self.view)
                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                
                if status == 1{
                    
                    
                    let data = result.value(forKey: "payload") as? Array<Dictionary<String, Any>> ?? []
                    
                    for dict in data {
                        
                        let hashTag = dict["hashTag"] as? String ?? ""
                        let totalCount = dict["totalCount"] as? Int ?? 0
                        self.tagsArray.append(HashtagModel(hashTag:hashTag,totalCount:totalCount))
                        
                    }
                    self.emptyView?.isHidden = (self.tagsArray.count > 0) ? true : false
                    self.isDataMoreAvailable = (data.count > 5) ? true : false
                    self.pageNo = self.pageNo + 1
                    
                    self.tblView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.isDataLoading = false
                    }
                }else{
                    self.isDataLoading = false
                }
            }
        }
    }
    
}


extension HashTagSearchVC:UITableViewDelegate,UITableViewDataSource{
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return (isDataMoreAvailable) ? 1 : 0
        }
        return tagsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            cell.activityIndicator.startAnimating()
            return cell
        }else{
        
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "HashTagTblCell", for: indexPath) as!
        HashTagTblCell
        cell.lblTitle.text = tagsArray[indexPath.row].hashTag
        cell.lblCount.text = tagsArray[indexPath.row].totalCount.asFormatted_k_String
            
        cell.bgViewImg.layer.cornerRadius = cell.bgViewImg.frame.height/2.0
        cell.bgViewImg.layer.borderColor = UIColor(hexString: "#737A7F").cgColor
        cell.bgViewImg.layer.borderWidth = 1.0
        cell.bgViewImg.clipsToBounds = true
        cell.imgView.image = UIImage(named: "hashtag")
        cell.imgvwProfile.isHidden = true
        
        return cell
    }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
  
        if (indexPath.section == 1 && indexPath.row == 0)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            if !isDataLoading {
                isDataLoading = true
                getHashTagApi()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // delegate?.searchItemSelected(selObj: tagsArray[indexPath.row], type: .hashTag)
        
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = "\(tagsArray[indexPath.row].hashTag)"
        (AppDelegate.sharedInstance.navigationController?.topViewController)?.pushView(destVc, animated: true)
    }
    
    
}

struct HashtagModel{
    
    var hashTag = ""
    var totalCount = 0
    
    init(hashTag:String,totalCount:Int) {
        self.totalCount = totalCount
        self.hashTag = hashTag
    }

}
