//
//  WeeklyLeaderboardHeaderCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/27/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class WeeklyLeaderboardHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePicFirstBgView:UIView!
    @IBOutlet weak var profilePicSecondBgView:UIView!
    @IBOutlet weak var profilePicThirdBgView:UIView!
    
    @IBOutlet weak var profilePicFirstView:ImageWithSvgaFrame!
    @IBOutlet weak var profilePicSecondView:ImageWithSvgaFrame!
    @IBOutlet weak var profilePicThirdView:ImageWithSvgaFrame!
    
    @IBOutlet weak var lblNameFirst:UILabel!
    @IBOutlet weak var lblNameSecond:UILabel!
    @IBOutlet weak var lblNameThird:UILabel!
    
    @IBOutlet weak var lblNameFirstGifter:UILabel!
    @IBOutlet weak var lblNameSecondGifter:UILabel!
    @IBOutlet weak var lblNameThirdGifter:UILabel!

    @IBOutlet weak var profilePicFirstGifterView:ImageWithSvgaFrame!
    @IBOutlet weak var profilePicSecondGifterView:ImageWithSvgaFrame!
    @IBOutlet weak var profilePicThirdGifterView:ImageWithSvgaFrame!
    @IBOutlet weak var btnSeeAll:UIButton!
    
    
    @IBOutlet weak var lblCoin1st:UILabel!
    @IBOutlet weak var lblCoin2nd:UILabel!
    @IBOutlet weak var lblCoin3rd:UILabel!
    
    @IBOutlet weak var bgVwCoin1st:UIView!
    @IBOutlet weak var bgVwCoin2nd:UIView!
    @IBOutlet weak var bgVwCoin3rd:UIView!
    
    
    @IBOutlet weak var imgVwCelebrity1st:UIImageView!
    @IBOutlet weak var imgVwCelebrity2nd:UIImageView!
    @IBOutlet weak var imgVwCelebrity3rd:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicFirstView.initializeView()
        profilePicSecondView.initializeView()
        profilePicThirdView.initializeView()
        
        profilePicFirstGifterView.initializeView()
        profilePicSecondGifterView.initializeView()
        profilePicThirdGifterView.initializeView()
    }

}
