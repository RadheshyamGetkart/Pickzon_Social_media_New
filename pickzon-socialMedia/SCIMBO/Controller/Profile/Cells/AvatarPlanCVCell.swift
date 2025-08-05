//
//  AvatarPlanCVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/22/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class AvatarPlanCVCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCoin:UILabel!
    @IBOutlet weak var bgVw:UIView!
    @IBOutlet weak var imgVwNotch:UIImageView!
    @IBOutlet weak var lblDay:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgVw.layer.cornerRadius = 10.0
        bgVw.clipsToBounds = true
    }

}
