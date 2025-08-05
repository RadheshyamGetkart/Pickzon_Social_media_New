//
//  FrameCollectionCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/15/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class FrameCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imgVwFrame:UIImageView!
    @IBOutlet weak var lblRange:UILabel!
    @IBOutlet weak var bgVw:UIView!
    @IBOutlet weak var imgVwNotch:UIImageView!
    @IBOutlet weak var lblOccupied:UILabel!
    @IBOutlet weak var bgVwLblRange:UIViewX!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
