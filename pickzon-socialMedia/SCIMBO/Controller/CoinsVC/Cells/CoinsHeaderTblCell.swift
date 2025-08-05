//
//  CoinsHeaderTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class CoinsHeaderTblCell: UITableViewCell {

    
    @IBOutlet weak var lblNumberOfCoins: UILabel!
    @IBOutlet weak var btnUpgradeToPremium: UIButton!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var bgViewUpgradePremium: UIView!
    @IBOutlet weak var imgVwBanner: UIImageView!
    @IBOutlet weak var lblTitleCoins: UILabel!
    @IBOutlet weak var btnEarnHistory: UIButton!
    @IBOutlet weak var imgVwCoin: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnHistory.layer.cornerRadius = 8.0// btnHistory.frame.size.height/2.0
        btnHistory.clipsToBounds = true
        btnWithdraw.layer.cornerRadius = 8.0 //btnWithdraw.frame.size.height/2.0
        btnWithdraw.layer.borderWidth = 1.5
        btnWithdraw.layer.borderColor = UIColor.white.cgColor
        btnWithdraw.clipsToBounds = true

        btnUpgradeToPremium.layer.cornerRadius = 5.0
        btnUpgradeToPremium.clipsToBounds = true
       
        btnReadMore.layer.cornerRadius = 5.0
        btnReadMore.layer.borderWidth = 1.0
        btnReadMore.layer.borderColor = UIColor.lightGray.cgColor
        btnReadMore.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
