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
   //@IBOutlet weak var imgVw:UIImageView!
    @IBOutlet weak var btnFollow:UIButton!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnFollow.layer.cornerRadius = 5.0
        profileImgView.initializeView()
    }

}
