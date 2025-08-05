//
//  PKLegendVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 10/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class PKLegendVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    
    var isDataLoading = false
    var pageNo = 1
    var listArray = [PKLegendModel]()
    
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        registerCell()
        getLegendApi()
        tblView.refreshControl = topRefreshControl
    }
    
    //MARKK: Other Helpful Methods
    func registerCell(){
        tblView.register(UINib(nibName: "PKLegendTblCell", bundle: nil), forCellReuseIdentifier: "PKLegendTblCell")
    }
    
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading{
            self.isDataLoading = true
            self.pageNo = 1
            self.getLegendApi()
        }
        refreshControl.endRefreshing()
        topRefreshControl.endRefreshing()
    }
    
    
    //MARK:UIButton action methods
    
    @IBAction func backButtonActionMethods(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Api Methods
    
    func getLegendApi(){
        
        self.isDataLoading = true
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
      
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.get_pk_legend , param: [:]) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.isDataLoading = false
            
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
                            
                            self.listArray.append(PKLegendModel(respDict: dict))
                            
                            self.tblView.reloadData()
                            
                            
                        }
                    }
                    
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
                
            }
        }
    }


}


extension PKLegendVC: UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if listArray.count > indexPath.row {
             let count = (listArray[indexPath.item].groupMembers.count * 85) + 70
            return CGFloat(count)
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PKLegendTblCell") as! PKLegendTblCell

        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.lblGroup.text = listArray[indexPath.item].groupName
        cell.groupObj = listArray[indexPath.item]
        cell.lblRound.text = "ROUND \(listArray[indexPath.item].round)"
        cell.lblGroup.layoutSubviews()
        cell.collectionVw.reloadData()
        
        return  cell
    }
    
}



@IBDesignable
class GradientLabel: UILabel {

    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.5647058824, green: 0.01568627451, blue: 0.01568627451, alpha: 1) {
        didSet { setNeedsLayout() }
    }
   
    @IBInspectable var middleColor: UIColor = #colorLiteral(red: 1, green: 0.768627451, blue: 0.1215686275, alpha: 1) {
        didSet { setNeedsLayout() }
    }

    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.9607843137, green: 0, blue: 0, alpha: 1) {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateTextColor()
    }

    private func updateTextColor() {
        let image = UIGraphicsImageRenderer(bounds: bounds).image { context in
            let colors = [topColor.cgColor, middleColor.cgColor , bottomColor.cgColor]
            guard let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil) else { return }
            context.cgContext.drawLinearGradient(gradient,
                                                 start: CGPoint(x: bounds.midX, y: bounds.minY),
                                                 end: CGPoint(x: bounds.midX, y: bounds.maxY),
                                                 options: [])
        }

        textColor = UIColor(patternImage: image)
    }

}





struct PKLegendModel{
    
 
    var groupMembers = [LegendGroupModel]()
    var round = 0
    var groupName = ""
    
    // var duration = 5
    // var result = 0
 //    var startDateTime = ""
 //    var startTime = ""
 //    var status = 0
    // var winnerId = ""

    init(respDict:Dictionary<String,Any>){
        
//        self.duration = respDict["duration"] as? Int ?? 0
//        self.startDateTime = respDict["startDateTime"] as? String ?? ""
//        self.winnerId = respDict["winnerId"] as? String ?? ""
//        self.result = respDict["result"] as? Int ?? 0
//        self.status = respDict["status"] as? Int ?? 0
      //  self.startTime = respDict["startTime"] as? String ?? ""
        self.round = respDict["round"] as? Int ?? 0
        self.groupName = respDict["groupName"] as? String ?? ""

        if let  groupMembers = respDict["groupMembers"] as? Array<Dictionary<String, Any>> {
            
            for dict in groupMembers {
                self.groupMembers.append(LegendGroupModel(respDict: dict))
            }
            
        }
    }

}




struct LegendGroupModel{
    
    var coverPic = ""
    var name = ""
    var pickzonId = ""
    var profilePic = ""
    var avatar = ""
    var userId = ""
    var celebrity = 0
    var isLivePK = 0
    var coins = 0
    var isLive = 0

    var coverPicRight = ""
    var nameRight = ""
    var pickzonIdRight = ""
    var profilePicRight = ""
    var avatarRight = ""
    var userIdRight = ""
    var celebrityRight = 0
    var isLivePKRight = 0
    var coinsRight = 0
    var isLiveRight = 0
    var result = 0
    var startDateTime = ""
    var startTime = ""
    var duration = 0
    var winnerId = ""
    var scheduledPkStatus = 0
    
    init(respDict:Dictionary<String,Any>){
        
        self.duration = respDict["duration"] as? Int ?? 0
        self.startDateTime = respDict["startDateTime"] as? String ?? ""
        self.startTime = respDict["startTime"] as? String ?? ""
        self.winnerId = respDict["winnerId"] as? String ?? ""
        self.result = respDict["result"] as? Int ?? 0
        self.scheduledPkStatus = respDict["status"] as? Int ?? 0
        

        if let userInfo = respDict["userInfo1"] as? Dictionary<String,Any>{
            
            self.name = userInfo["name"] as? String ?? ""
            self.pickzonId = userInfo["pickzonId"] as? String ?? ""
            self.profilePic = userInfo["profilePic"] as? String ?? ""
            self.avatar = userInfo["avatar"] as? String ?? ""
            self.userId = userInfo["userId"] as? String ?? ""
            self.celebrity = userInfo["celebrity"] as? Int ?? 0
            self.isLivePK = userInfo["isLivePK"] as? Int ?? 0 //"isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
            self.coverPic =  userInfo["coverImageCdnCompress"] as? String ?? ""
            self.coins = userInfo["coins"] as? Int ?? 0
            self.isLive = userInfo["isLive"] as? Int ?? 0
        }
        
        
        if let userInfo = respDict["userInfo2"] as? Dictionary<String,Any>{
            
            self.nameRight = userInfo["name"] as? String ?? ""
            self.pickzonIdRight  = userInfo["pickzonId"] as? String ?? ""
            self.profilePicRight  = userInfo["profilePic"] as? String ?? ""
            self.avatarRight  = userInfo["avatar"] as? String ?? ""
            self.userIdRight  = userInfo["userId"] as? String ?? ""
            self.celebrityRight  = userInfo["celebrity"] as? Int ?? 0
            self.isLivePKRight  = userInfo["isLivePK"] as? Int ?? 0 //"isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
            self.coverPicRight  =  userInfo["coverImageCdnCompress"] as? String ?? ""
            self.coinsRight  = userInfo["coins"] as? Int ?? 0
            self.isLiveRight = userInfo["isLive"] as? Int ?? 0
         
        }
    }
}

