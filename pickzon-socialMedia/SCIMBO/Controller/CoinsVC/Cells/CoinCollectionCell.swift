//
//  CoinCollectionCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class CoinCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblCoinCount: UILabel!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var btnBuyNow: UIButtonX!
    @IBOutlet weak var lblCoinAmount: UILabel!
    @IBOutlet weak var imgVwOffer: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.btnBuyNow.setGradientColork(colorLeft:Themes.sharedInstance.colorWithHexString(hex: "#E1DE85") , colorRight: Themes.sharedInstance.colorWithHexString(hex: "#B19031"), titleColor: .white, cornerRadious: 0.0, image: "", title: "Buy Now")
        
//        self.btnBuyNow.setGradientColorNew(colorLeft:Themes.sharedInstance.colorWithHexString(hex: "#E1DE85") , colorRight: Themes.sharedInstance.colorWithHexString(hex: "#B19031"), titleColor: .white, cornerRadious: 0.0, image: "", title: "Buy Now")

    }

}
