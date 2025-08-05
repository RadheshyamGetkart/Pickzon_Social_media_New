//
//  ImgCollectionCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/19/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ImgCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imgvw:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgvw.layer.cornerRadius = imgvw.frame.size.height/2.0
        imgvw.layer.borderColor = UIColor.white.cgColor
        imgvw.layer.borderWidth = 0.5
        imgvw.clipsToBounds = true
    }

}
