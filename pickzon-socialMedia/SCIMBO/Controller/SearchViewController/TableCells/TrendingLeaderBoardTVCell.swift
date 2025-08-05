//
//  TrendingLeaderBoardTVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/7/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class TrendingLeaderBoardTVCell: UITableViewCell {
  
    @IBOutlet weak var cllctnVw:UICollectionView!
    var arrTrendingLeaderBoard = [TrendingLeaderBoard]()
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cllctnVw.register(UINib(nibName: "TrendingLeaderBoardCVCell", bundle: nil),
                          forCellWithReuseIdentifier: "TrendingLeaderBoardCVCell")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension TrendingLeaderBoardTVCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if arrTrendingLeaderBoard.count == 1{
            return CGSize(width: self.cllctnVw.frame.width, height: self.cllctnVw.frame.height)
        }
        
        return CGSize(width: self.cllctnVw.frame.width*0.8, height: self.cllctnVw.frame.height)
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTrendingLeaderBoard.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cllctnVw.dequeueReusableCell(withReuseIdentifier: "TrendingLeaderBoardCVCell", for: indexPath) as! TrendingLeaderBoardCVCell
        cell.arrLeaderboard =  arrTrendingLeaderBoard[indexPath.row].arrLeaderboard
        cell.lblTitle.text = arrTrendingLeaderBoard[indexPath.row].title
         
        //type -"Pickzon star" -->1 || "PK Leaderboard" -->2 || "Go Live" --> 3
        switch (arrTrendingLeaderBoard[indexPath.row].typeVal){
            
        case 1:
            cell.imgTop.image = UIImage(named:"pickzonStar")
            break
        case 2:
            cell.imgTop.image = UIImage(named:"pkSmall")
            break
        case 3:
            cell.imgTop.image = UIImage(named:"liveIcon")
            cell.isLiveLeaderBoard = true
            break
        default:
            cell.isLiveLeaderBoard = false
            break
        }
      
        cell.tblView.reloadData()
        cell.btnViewAll.tag = indexPath.item
        cell.btnViewAll.addTarget(self, action: #selector(viewAllBtnAction(_ :)), for: .touchUpInside)
        return cell
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    @objc func viewAllBtnAction(_ sender : UIButton){
        //type -"Pickzon star" -->1 || "PK Leaderboard" -->2 || "Go Live" --> 3
       
        switch (arrTrendingLeaderBoard[sender.tag].typeVal){
            
        case 1:
            let destVC:LeaderBoardVC = StoryBoard.premium.instantiateViewController(withIdentifier: "LeaderBoardVC") as! LeaderBoardVC
            (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
            break
            
        case 2:
            break
            
        case 3:
            let viewController = StoryBoard.letGo.instantiateViewController(withIdentifier: "LiveLeaderBoardVC") as! LiveLeaderBoardVC
            (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
            break
            
        default:
            break
            
        }
    }
    
    @IBAction func viewAllAction(sender:UIButton) {
        /*if sender.tag == 0 {
            let viewController = StoryBoard.letGo.instantiateViewController(withIdentifier: "LiveLeaderBoardVC") as! LiveLeaderBoardVC
            self.navigationController?.pushView(viewController, animated: true)
        }else if sender.tag == 1 {
            
        }else {
            
        }*/
    }
    
    //MARK: - Follow Btn Action
        
}
