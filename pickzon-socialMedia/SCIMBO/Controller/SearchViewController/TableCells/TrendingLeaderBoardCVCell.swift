//
//  TrendingLeaderBoardCVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/7/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
class TrendingLeaderBoardCVCell: UICollectionViewCell {
    @IBOutlet weak var viewTopBack:UIView!
    @IBOutlet weak var imgBack:UIImageView!
    @IBOutlet weak var imgTop:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnViewAll:UIButton!

    var arrLeaderboard = [LeaderboardModel]()
    var isLiveLeaderBoard = false
    override func awakeFromNib() {
        super.awakeFromNib()
        imgBack.layer.cornerRadius = 5.0
        imgBack.clipsToBounds = true
        
        viewTopBack.roundGivenCorners([.topLeft,.topRight], radius: 5.0)
        viewTopBack.clipsToBounds = true

        
        tblView.register(UINib(nibName: "TrendingGifterInfoTCell", bundle: nil),
                           forCellReuseIdentifier: "TrendingGifterInfoTCell")
    }
}

extension TrendingLeaderBoardCVCell:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLeaderboard.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier:"TrendingGifterInfoTCell") as! TrendingGifterInfoTCell
        
        let obj = arrLeaderboard[indexPath.row]
        cell.lblSNo.text = "\(indexPath.row + 1)"
        
        cell.profileImgView.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar,changeValue:(obj.avatar.count > 0) ? 8 : 5)
        
        cell.lblName.text = obj.pickzonId
        
        switch obj.celebrity{
        case 1:
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.greenVerification
        case 4:
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.goldVerification
        case 5:
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.blueVerification
        default:
            cell.imgCelebrity.isHidden = true
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let destVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC{
            destVC.otherMsIsdn =  arrLeaderboard[indexPath.row].userId
            (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
        }
    }
    
}
