//
//  PKLegendTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 10/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class PKLegendTblCell: UITableViewCell {

    @IBOutlet weak var lblRound:UILabel!
    @IBOutlet weak var lblGroup:GradientLabel!
    @IBOutlet weak var collectionVw:UICollectionView!
    @IBOutlet weak var bgVw:UIViewX!
    var groupObj = PKLegendModel(respDict: [:])

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionVw.register(UINib(nibName: "PKLegendMemberCell", bundle: nil), forCellWithReuseIdentifier: "PKLegendMemberCell")
        collectionVw.delegate = self
        collectionVw.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
                   
    //MARK: - UICollectionview delegate and datasource

    extension PKLegendTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return groupObj.groupMembers.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PKLegendMemberCell", for: indexPath) as! PKLegendMemberCell
            
            let userObj = groupObj.groupMembers[indexPath.item]
            
            cell.bgVwLblTime.roundGivenCorners([.bottomLeft,.bottomRight], radius: 8.0)
            cell.lblTime.text = groupObj.groupMembers[indexPath.item].startDateTime
            cell.btnNameLeftUser.setTitle(groupObj.groupMembers[indexPath.item].pickzonId, for: .normal)
            cell.btnNameRightUser.setTitle(groupObj.groupMembers[indexPath.item].pickzonIdRight, for: .normal)
            cell.imgVwLeftUser.kf.setImage(with: URL(string: groupObj.groupMembers[indexPath.item].profilePic), placeholder: PZImages.avatar)
            cell.imgVwRightUser.kf.setImage(with: URL(string: groupObj.groupMembers[indexPath.item].profilePicRight), placeholder: PZImages.avatar)
            
            cell.btnNameLeftUser.tag = indexPath.item
            cell.imgVwLeftUser.tag = indexPath.item
            cell.btnNameRightUser.tag = indexPath.item
            cell.imgVwRightUser.tag = indexPath.item
            
            
            // result: { type: Number, default: 0 }, // 0 = No result, 1 = winner/loser, 2 = Tie
           // "status": 0, // 0 = create, 1 = complete, 2 = cancel, 3 = After Join pk(Self Left/Close PK)
            
            
            if  userObj.winnerId == userObj.userId{
                
                cell.lblLeftStatus.text = "Winner"
                cell.lblRightStatus.text = "Loser"
                cell.lblLeftStatus.textColor = .green
                cell.lblRightStatus.textColor = .red

                if userObj.scheduledPkStatus == 3{
                    cell.lblRightStatus.text = "Loser (Left)"
                }
            }else if  userObj.winnerId == userObj.userIdRight{
                
                cell.lblLeftStatus.text = "Loser"
                cell.lblRightStatus.text = "Winner"
                cell.lblRightStatus.textColor = .green
                cell.lblLeftStatus.textColor = .red
                if userObj.scheduledPkStatus == 3{
                    cell.lblLeftStatus.text = "Loser (Left)"
                }

            }else if userObj.result == 0{
                
                cell.lblLeftStatus.text = ""
                cell.lblRightStatus.text = ""
                
            }else if userObj.result == 2{
                
                cell.lblLeftStatus.text = "Tie"
                cell.lblRightStatus.text = "Tie"
                cell.lblLeftStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb900")
                cell.lblRightStatus.textColor = Themes.sharedInstance.colorWithHexString(hex: "#ffb900")
            }
            
            
            if userObj.scheduledPkStatus == 2{
                cell.lblLeftStatus.text = "Cancelled"
                cell.lblRightStatus.text = "Cancelled"
                cell.lblLeftStatus.textColor = .red
                cell.lblRightStatus.textColor = .red
            }
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftImgViewDidTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            cell.imgVwLeftUser.addGestureRecognizer(tapGesture)
            
            let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(rightImgViewDidTapped(_:)))
            tapGesture1.numberOfTapsRequired = 1
            cell.imgVwRightUser.addGestureRecognizer(tapGesture1)
            cell.btnNameLeftUser.addTarget(self, action: #selector(leftProfileAction(_ : )), for: .touchUpInside)
            cell.btnNameRightUser.addTarget(self, action: #selector(rightProfileAction(_ : )), for: .touchUpInside)
            
           
           
            return cell
        }
        

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: self.collectionVw.frame.size.width, height: 85)
        }
        
        //MARK: Selector methods
                
        @objc func leftProfileAction(_ sender : UIButton){
            let userObj = groupObj.groupMembers[sender.tag]
           
            if userObj.isLivePK == 1 || userObj.isLivePK == 1{
                let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                viewController.leftRoomId = userObj.userId
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
            }else{
                
                if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                    viewController.otherMsIsdn = groupObj.groupMembers[sender.tag].userId
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
                }
            }
        }
        
        
        @objc func rightProfileAction(_ sender : UIButton){
            
            let userObj = groupObj.groupMembers[sender.tag]
            
            if userObj.isLivePKRight == 1 || userObj.isLivePKRight == 1{
            
                let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                viewController.leftRoomId = userObj.userIdRight
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
            }else{
                if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                    viewController.otherMsIsdn = groupObj.groupMembers[sender.tag].userIdRight
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
                }
            }
        }
        
        

        @objc func rightImgViewDidTapped(_ sender: UIGestureRecognizer) {
            
            if let tag = sender.view?.tag {
              
                let userObj = groupObj.groupMembers[tag]
                
                if userObj.isLivePKRight == 1 || userObj.isLivePKRight == 1{
                
                    let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                    viewController.leftRoomId = userObj.userIdRight
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
                }else{
                    if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                        viewController.otherMsIsdn = groupObj.groupMembers[tag].userIdRight
                        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
                    }
                }
            }
        }
        
        
        @objc func leftImgViewDidTapped(_ sender: UIGestureRecognizer) {
            
            if let tag = sender.view?.tag {
                let userObj = groupObj.groupMembers[tag]
               
                if userObj.isLivePK == 1 || userObj.isLivePK == 1{
                    let viewController:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                    viewController.leftRoomId = userObj.userId
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
                }else{
                    
                    if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                        viewController.otherMsIsdn = groupObj.groupMembers[tag].userId
                        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
                    }
                }
            }
        }
    }

