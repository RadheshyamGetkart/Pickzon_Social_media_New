//
//  DescriptionPointsVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/6/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

enum LeaderBoardType:Int{
    
    case leaderboard = 1
    case liveLeaderboard = 2
    case agencyCoinInfo = 3
    case giftLeaderBoard = 4
}

class DescriptionPointsVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    var leaderboardType:LeaderBoardType = .leaderboard
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")
        // Do any additional setup after loading the view.
        addBackButton()
    }
        
    //MARK: APi Methods
    
    //MARK: UIBUtton Action Methods
    func addBackButton(){
        let someButton = UIButton(frame: CGRect(x: 0, y: 5, width: 40, height: 40))
        someButton.setImage(UIImage(named: "crossMark"), for: .normal)
        someButton.addTarget(self, action: #selector(backBtnAction1(_ : )), for: .touchUpInside)
        someButton.showsTouchWhenHighlighted = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: someButton)
    }
    
    @IBAction func backBtnAction1(_ sender: UIButton) {
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}


extension DescriptionPointsVC:UITableViewDelegate,UITableViewDataSource{
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if leaderboardType == .agencyCoinInfo{
            return 2
        }else {
            return 1
        }
            
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if leaderboardType == .leaderboard{
            return  Themes.sharedInstance.leaderboardKeyPoints.count + 1
        }else if leaderboardType == .liveLeaderboard{
            return  Themes.sharedInstance.liveLeaderboardKeyPoints.count + 1
        }else if leaderboardType == .agencyCoinInfo{
            if section == 0 {
               return Themes.sharedInstance.arrRechargeList.count + 1
            }else {
                return Themes.sharedInstance.arrTermList.count + 1
            }
        }else   if leaderboardType == .giftLeaderBoard{
            return  Themes.sharedInstance.arrValentineLeaderboardsKeyPoint.count + 1

        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
        if leaderboardType == .agencyCoinInfo{
            if indexPath.row == 0{
                cell.btnCheck.isHidden = false
                cell.lblTitle.isHidden =  true
                cell.btnCheck.setImage(nil, for: .normal)
                if indexPath.section == 0 {
                    cell.btnCheck.setTitle("\(Themes.sharedInstance.strRechargeTitle)" , for: .normal)
                }else {
                    cell.btnCheck.setTitle("\(Themes.sharedInstance.strTermTitle)" , for: .normal)
                }
                
                cell.btnCheck.contentHorizontalAlignment = .left
            }else{
                cell.btnCheck.isHidden =  false
                cell.lblTitle.isHidden =  false
                cell.btnCheck.contentHorizontalAlignment = .center
                cell.btnCheck.setImage(nil, for: .normal)
                //cell.btnCheck.setTitle("•", for: .normal)
                if indexPath.section == 0 {
                    cell.lblTitle.text =  Themes.sharedInstance.arrRechargeList[indexPath.row-1]
                }else {
                    cell.lblTitle.text =  Themes.sharedInstance.arrTermList[indexPath.row-1]
                }
            }
            
        }else if indexPath.row == 0{
            cell.btnCheck.isHidden = false
            cell.lblTitle.isHidden =  true
            cell.btnCheck.setImage(nil, for: .normal)
            cell.btnCheck.setTitle("Guidelines" , for: .normal)
            cell.btnCheck.contentHorizontalAlignment = .left
        }else{
            cell.btnCheck.isHidden =  false
            cell.lblTitle.isHidden =  false
            cell.btnCheck.contentHorizontalAlignment = .center
            cell.btnCheck.setImage(nil, for: .normal)
            cell.btnCheck.setTitle("•", for: .normal)
            if leaderboardType == .leaderboard{
                cell.lblTitle.text =  Themes.sharedInstance.leaderboardKeyPoints[indexPath.row-1]
            }else if leaderboardType == .liveLeaderboard{
                cell.lblTitle.text =  Themes.sharedInstance.liveLeaderboardKeyPoints[indexPath.row-1]
            }else  if leaderboardType == .giftLeaderBoard{
                cell.lblTitle.text =  Themes.sharedInstance.arrValentineLeaderboardsKeyPoint[indexPath.row-1]
            }
        }
   
        return cell
    }
        
}
