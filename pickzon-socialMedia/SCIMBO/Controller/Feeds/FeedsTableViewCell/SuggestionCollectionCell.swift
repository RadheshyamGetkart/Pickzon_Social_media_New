//
//  SuggestionCollectionCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 12/15/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit

class SuggestionCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var btnFollow:UIButton!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!
    @IBOutlet weak var bgView:UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnFollow.backgroundColor = CustomColor.sharedInstance.newThemeColor
        btnFollow.layer.cornerRadius = btnFollow.frame.height/2.0
        btnFollow.clipsToBounds = true
        profileImgView.initializeView()
        
        bgView.layer.cornerRadius = 10.0
        bgView.layer.masksToBounds = true

        lblName.font = UIFont.MyMediumFont(12.0)
        lblUserName.font = UIFont.MyRegularFont(12.0)
        btnFollow.titleLabel?.font = UIFont.MyBoldFont(12.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.layer.cornerRadius = 10.0
        bgView.layer.masksToBounds = true
    }
}
