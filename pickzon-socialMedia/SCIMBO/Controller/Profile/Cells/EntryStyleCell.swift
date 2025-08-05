//
//  EntryStyleCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/6/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class EntryStyleCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVwFrame:UIImageView!
    @IBOutlet weak var bgVw:UIView!
    @IBOutlet weak var imgVwNotch:UIImageView!
    @IBOutlet weak var btnDayLeft:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDayLeft.layer.cornerRadius = 3.0
        btnDayLeft.clipsToBounds = true
    }
    
}
