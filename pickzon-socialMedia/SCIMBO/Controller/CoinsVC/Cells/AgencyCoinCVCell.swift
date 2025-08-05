//
//  AgencyCoinCVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/23/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyCoinCVCell: UICollectionViewCell {
    @IBOutlet weak var viewBack: UIViewX!
    @IBOutlet weak var lblCoinCount: UILabel!
    @IBOutlet weak var lblExtraCoin: UILabel!
    @IBOutlet weak var lblCoinAmount: UILabel!
    @IBOutlet weak var imgVwOffer: UIImageView!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var imgVwCheck: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgVwCheck.isHidden = true
        
        
    }

}
