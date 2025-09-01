//
//  LiveUsersCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/9/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class LiveUsersCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblViewCount:UILabel!
    @IBOutlet weak var imgVwUser:UIImageView!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var imgVwPk:UIImageView!
    @IBOutlet weak var bgVwJoinCount:UIView!
    @IBOutlet weak var bgViewCoin:UIView!
    @IBOutlet weak var lblCoinCount:UILabel!
    @IBOutlet weak var imgVwProfile:UIImageView!
    @IBOutlet weak var bgView:UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVwProfile.layer.cornerRadius = imgVwProfile.frame.height/2.0
        imgVwProfile.clipsToBounds = true
        
        
        
        imgVwUser.layer.cornerRadius = 10.0
        imgVwUser.clipsToBounds = true
        
        bgView.layer.cornerRadius = 16.0
        bgView.layer.borderColor = CustomColor.sharedInstance.newThemeColor.cgColor
        bgView.layer.borderWidth = 1.0
        bgView.clipsToBounds = true
    }

}
