//
//  ClipSuggestionCVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/9/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ClipSuggestionCVCell: UICollectionViewCell {

    @IBOutlet weak var viewBack: UIViewX!
    @IBOutlet weak var imgVideoThumb: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVideoThumb.layer.cornerRadius = 5.0
        imgVideoThumb.clipsToBounds = true
    }

    deinit {
    }

}
