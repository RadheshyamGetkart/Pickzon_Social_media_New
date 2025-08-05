//
//  GiftBannerTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/2/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class GiftBannerTblCell: UITableViewCell {

    @IBOutlet weak var imgVwGift:UIImageView!
    @IBOutlet weak var imgVwBanner:UIImageView!
    @IBOutlet weak var btnUserProfilePic:UIButton!
    @IBOutlet weak var btnGifterFirst:UIButton!
    @IBOutlet weak var btnGifterSecond:UIButton!
    @IBOutlet weak var btnGifterThird:UIButton!
    @IBOutlet weak var lblBannerTitle:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.lblBannerTitle.font = UIFont(name: "Playball-Regular", size: 20.0)
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.btnGifterFirst.contentMode = .scaleAspectFit
        self.btnGifterFirst.imageView?.contentMode = .scaleAspectFill
        self.btnGifterFirst.layer.cornerRadius =  self.btnGifterFirst.frame.size.height/2.0
        
        self.btnGifterSecond.contentMode = .scaleAspectFit
        self.btnGifterSecond.imageView?.contentMode = .scaleAspectFill
        self.btnGifterSecond.layer.cornerRadius =  self.btnGifterSecond.frame.size.height/2.0
        
        self.btnGifterThird.contentMode = .scaleAspectFit
        self.btnGifterThird.imageView?.contentMode = .scaleAspectFill
        self.btnGifterThird.layer.cornerRadius =  self.btnGifterThird.frame.size.height/2.0
        
    }
    

}
