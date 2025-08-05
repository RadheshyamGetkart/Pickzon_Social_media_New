//
//  TopThreeLiveCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class TopThreeLiveCell: UICollectionViewCell {

    
    @IBOutlet weak var btnCoin:UIButton!
    @IBOutlet weak var imgVwUser:UIImageViewX!
    @IBOutlet weak var btnFirstGifter:UIButton!
    @IBOutlet weak var btnSecondGifter:UIButton!
    @IBOutlet weak var btnThreeGifter:UIButton!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgVwCelebrity:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnFirstGifter.layer.cornerRadius = btnFirstGifter.frame.size.height/2.0
        btnFirstGifter.layer.borderWidth = 0.5
        btnFirstGifter.layer.borderColor = UIColor.white.cgColor
        btnFirstGifter.clipsToBounds = true
        
        btnSecondGifter.layer.cornerRadius = btnSecondGifter.frame.size.height/2.0
        btnFirstGifter.layer.borderWidth = 0.5
        btnFirstGifter.layer.borderColor = UIColor.white.cgColor
        btnSecondGifter.clipsToBounds = true
        
        btnThreeGifter.layer.cornerRadius = btnThreeGifter.frame.size.height/2.0
        btnFirstGifter.layer.borderWidth = 0.5
        btnFirstGifter.layer.borderColor = UIColor.white.cgColor
        btnThreeGifter.clipsToBounds = true
        
    }

}
