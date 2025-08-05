//
//  SelectGoalVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 5/18/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class SelectGoalVC: UIViewController {
    @IBOutlet weak var tblGoal:UITableView!
    var postId = ""
    var arrData = [["title":"Get more messages on WhatsApp", "subTitle":"Show your add to group who are likely to send messages on WhatsApp"],["title":"Get more page likes", "subTitle":"Create to help more people find and like your page"],["title":"Get more calls", "subTitle":"Show your ad to people who are likely to call you"],["title":"Get more website visitors", "subTitle":"Show your add to people who are likely to send you a message on Pickzon"]]
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblGoal.register(UINib(nibName: "GoalTVCell", bundle: nil), forCellReuseIdentifier: "GoalTVCell")
        tblGoal.separatorColor = UIColor.clear
        tblGoal.reloadData()
        
    }
    
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectGoalVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "GoalTVCell") as! GoalTVCell
        let obj = arrData[indexPath.row]
        cell.lblTitle.text = obj["title"]
        cell.lblSubtitle.text = obj["subTitle"]
        if indexPath.row == 0 {
            cell.viewBack.backgroundColor = UIColor(red: 25.0 / 255.0, green: 146.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        }else if indexPath.row == 1 {
            cell.viewBack.backgroundColor = UIColor(red: 216.0 / 255.0, green: 41.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
        }else if indexPath.row == 2 {
            cell.viewBack.backgroundColor = UIColor(red: 151.0 / 255.0, green: 38.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0)
        }else {
            cell.viewBack.backgroundColor = UIColor(red: 192.0 / 255.0, green: 95.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController:CreateAddDetailVC = StoryBoard.promote.instantiateViewController(withIdentifier: "CreateAddDetailVC") as! CreateAddDetailVC
        viewController.postId = self.postId
        self.navigationController?.pushView(viewController, animated: true)
    }
    
}
