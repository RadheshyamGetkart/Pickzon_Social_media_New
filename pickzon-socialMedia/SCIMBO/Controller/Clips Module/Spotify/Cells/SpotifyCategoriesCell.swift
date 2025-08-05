//
//  SpotifyCategoriesCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/1/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

class SpotifyCategoriesCell: UICollectionViewCell {

    @IBOutlet weak var imgCategory:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCategory.layer.cornerRadius = 10.0
        imgCategory.clipsToBounds = true
    }

}

