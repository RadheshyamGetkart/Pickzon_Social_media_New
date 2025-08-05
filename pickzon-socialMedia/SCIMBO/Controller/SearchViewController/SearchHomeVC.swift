//
//  SearchHomeVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/6/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class SearchHomeVC: UIViewController {
   
    @IBOutlet weak var searchBtnWidth :NSLayoutConstraint!
    @IBOutlet weak var searchTf :UITextField!
    @IBOutlet weak var searchtbl :UITableView!
    
    var pageNumber = 1
    var bannerArray = [BannerModel]()
    var arrTrendingHashTags = [TrendingHashTags]()
    var arrTrendingLeaderBoard = [TrendingLeaderBoard]()
    var isDataLoading = false
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTabeviewCell()
        searchTf.delegate = self
        searchtbl.estimatedRowHeight = 250
        searchtbl.rowHeight = UITableView.automaticDimension
        searchtbl.refreshControl = topRefreshControl
        self.fetchHashTagData()
        self.fetchGetBannerAPI()
        self.fetchTopCreatorsAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let cell = searchtbl.cellForRow(at: IndexPath(row: 0, section: 0)) as? FeedsBannerCell{
            cell.startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         
        if let cell = searchtbl.cellForRow(at: IndexPath(row: 0, section: 0)) as? FeedsBannerCell{
            cell.stopTimer()
        }
    }
    
    
    //MARK: Other helpful methods
    
    func registerTabeviewCell(){
        searchtbl.register(UINib(nibName: "FeedsBannerCell", bundle: nil),
                           forCellReuseIdentifier: "FeedsBannerCell")
        
        
        searchtbl.register(UINib(nibName: "TrendingVideoTVCell", bundle: nil),
                           forCellReuseIdentifier: "TrendingVideoTVCell")
        
        
        searchtbl.register(UINib(nibName: "TrendingLeaderBoardTVCell", bundle: nil),
                           forCellReuseIdentifier: "TrendingLeaderBoardTVCell")
    }
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading{
            self.pageNumber = 1
            self.isDataLoading = true
            self.fetchHashTagData()
            self.fetchGetBannerAPI()
            self.fetchTopCreatorsAPI()
        }
        refreshControl.endRefreshing()
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func searchEditing(_ sender: Any) {
        
        if searchTf.text!.count > 0
        {
            searchBtnWidth.constant = 60.0
        }else
        {
            searchBtnWidth.constant = 0
        }
    }

    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func searchBtn(_ sender: Any) {
        view.endEditing(true)
    }
    

    //MARK: APi Methods
    func fetchGetBannerAPI(){
        
            
            let param = NSDictionary()
            let urString = Constant.sharedinstance.getBannerURL + "?type=2"

            URLhandler.sharedinstance.makeGetCall(url:urString, param: param, completionHandler: {(responseObject, error) ->  () in
                if(error != nil)
                {
                   // Themes.sharedInstance.RemoveactivityView(View: self.view)
                  //  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    if status == 1{
                        //Themes.sharedInstance.RemoveactivityView(View: self.view)
                        
                        if  let payload = result.value(forKey: "payload") as? Array<Dictionary<String,Any>> {
                            self.bannerArray.removeAll()
                            self.searchtbl.reloadData()
                           
                            for dict in payload{
                                self.bannerArray.append(BannerModel(respDict: dict))
                            }
                        }
                        self.searchtbl.reloadData()
                        
                        
                    }
                    else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
            
            
    }
    
    
    
    func fetchTopCreatorsAPI(){
        
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            
            //Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            let param = NSDictionary()
            
            URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getTopCreatorsURL, param: param, completionHandler: {(responseObject, error) ->  () in
                if(error != nil)
                {
                    //Themes.sharedInstance.RemoveactivityView(View: self.view)
                  //  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    if status == 1{
                       // Themes.sharedInstance.RemoveactivityView(View: self.view)
                        
                        if  let payload = result.value(forKey: "payload") as? Array<Dictionary<String,Any>> {
                            self.arrTrendingLeaderBoard.removeAll()
                            self.searchtbl.reloadData()

                            for dict in payload {
                                self.arrTrendingLeaderBoard.append(TrendingLeaderBoard(dict: dict as NSDictionary))
                            }
                            
                        }
                        
                        self.searchtbl.reloadData()
                        
                    }
                    else
                    {
                       // Themes.sharedInstance.RemoveactivityView(View: self.view)
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
            
            
        }else {
            //let msg = "No Network Connection"
           // self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    
    func fetchHashTagData(){
        
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            
            
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            let param = NSDictionary()
            let url = Constant.sharedinstance.getHashTagVideosURL + "?pageNumber=\(self.pageNumber)"
            self.isDataLoading = true
            URLhandler.sharedinstance.makeGetCall(url:url, param: param, completionHandler: {(responseObject, error) ->  () in
                if(error != nil)
                {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                  //  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    
                    if status == 1{
                        
                        if self.pageNumber == 1{
                            self.arrTrendingHashTags.removeAll()
                            self.searchtbl.reloadData()
                        }
                        let payload = (result.value(forKey: "payload") as? NSArray ?? [])
                        for dict in payload {
                            self.arrTrendingHashTags.append(TrendingHashTags(dict: dict as? NSDictionary ?? [:]))
                            self.searchtbl.beginUpdates()
                            self.searchtbl.insertRows(at: [IndexPath(row: self.arrTrendingHashTags.count-1, section: 2)], with: .bottom)
                            self.searchtbl.endUpdates()
                        }
                        self.pageNumber = self.pageNumber + 1
                        self.isDataLoading = false
                    } else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                    
                }
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.isDataLoading = false
            })
            
            
        }else {
            let msg = "No Network Connection"
            self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
   
}

extension SearchHomeVC:UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchFeedUSerListVC") as! SearchFeedUSerListVC
        navigationController?.pushViewController(vc, animated: false)
        
        return false
    }
}

extension SearchHomeVC : UITableViewDelegate, UITableViewDataSource, BusinessMediaDelegate {
  
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
            
        case 0:
            return (self.bannerArray.count > 0) ? 1 : 0
       
        case 1:
            return (self.arrTrendingLeaderBoard.count > 0) ? 1 : 0
       
        case 2:
            return self.arrTrendingHashTags.count
       
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"FeedsBannerCell") as! FeedsBannerCell
            cell.selectionStyle = .none
            cell.bannerArray = self.bannerArray
            cell.cllctnViewBanner.reloadData()
            cell.startTimer()

            return cell
     
        }else if indexPath.section == 1 {
            
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"TrendingLeaderBoardTVCell") as! TrendingLeaderBoardTVCell
            cell.selectionStyle = .none
            cell.arrTrendingLeaderBoard = self.arrTrendingLeaderBoard
            cell.cllctnVw.reloadData()
            return cell
            
        }else{
            
            let cell = searchtbl.dequeueReusableCell(withIdentifier:"TrendingVideoTVCell") as! TrendingVideoTVCell
            cell.selectionStyle = .none
            cell.wallPostArray = self.arrTrendingHashTags[indexPath.row].wallPostArray
            cell.lblTitle.text = "#" + self.arrTrendingHashTags[indexPath.row].title.uppercased()
            cell.btnViewTitle.setTitle("View All", for: .normal)
            cell.parentIndex = indexPath.row
            cell.delegate = self
            cell.cllctnVw.reloadData()
            return cell
        }
    }
    
    
   
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
            
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            if !isDataLoading {
                isDataLoading = true
                self.fetchHashTagData()
            }
        }
    }

    func clickedMediaWith(index:Int, parentIndex:Int) {
     
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
        vc.objWallPost = self.arrTrendingHashTags[parentIndex].wallPostArray[index]
        vc.firstVideoIndex = 0
        vc.videoType = .feed
        vc.isHashTagVideos = true
        vc.hashTag = self.arrTrendingHashTags[parentIndex].title
        vc.isRandomVideos = false
        vc.arrFeedsVideo = self.arrTrendingHashTags[parentIndex].wallPostArray
        vc.arrFeedsVideo.remove(at: index)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func clickedAllMedia(parentIndex:Int) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchFeedUSerListVC") as! SearchFeedUSerListVC
        vc.hashSearchText = self.arrTrendingHashTags[parentIndex].title
        navigationController?.pushViewController(vc, animated: false)
    }
        
     
}



