//
//  TopGainerLiveCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/30/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class TopGainerLiveCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lblCoin:UILabel!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgVwVerification:UIImageView!
    @IBOutlet weak var btnFirstGifter:UIButton!
    @IBOutlet weak var btnSecondGifter:UIButton!
    @IBOutlet weak var btnThirdGifter:UIButton!
    @IBOutlet weak var imgVwProfile:UIImageView!
    @IBOutlet weak var imgVwPkStatus:UIImageView!

    @IBOutlet weak var cnstntWidthPkIcon:NSLayoutConstraint!

    @IBOutlet weak var lblFirstGifter:UILabel!
    @IBOutlet weak var lblSecondGifter:UILabel!
    @IBOutlet weak var lblThirdGifter:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Initialization code
        btnFirstGifter.layer.cornerRadius = btnFirstGifter.frame.size.height/2.0
        btnFirstGifter.layer.borderWidth = 2.5
        btnFirstGifter.layer.borderColor = UIColor.white.cgColor
        btnFirstGifter.clipsToBounds = true
        
        btnSecondGifter.layer.cornerRadius = btnSecondGifter.frame.size.height/2.0
        btnSecondGifter.layer.borderWidth = 2.5
        btnSecondGifter.layer.borderColor = UIColor.white.cgColor
        btnSecondGifter.clipsToBounds = true
        
        btnThirdGifter.layer.cornerRadius = btnThirdGifter.frame.size.height/2.0
        btnThirdGifter.layer.borderWidth = 2.5
        btnThirdGifter.layer.borderColor = UIColor.white.cgColor
        btnThirdGifter.clipsToBounds = true
        
        
        btnFirstGifter.contentHorizontalAlignment = .fill
        btnFirstGifter.contentVerticalAlignment = .fill
        btnFirstGifter.imageView?.contentMode = .scaleAspectFill
        
        btnSecondGifter.contentHorizontalAlignment = .fill
        btnSecondGifter.contentVerticalAlignment = .fill
        btnSecondGifter.imageView?.contentMode = .scaleAspectFill
        
        btnThirdGifter.contentHorizontalAlignment = .fill
        btnThirdGifter.contentVerticalAlignment = .fill
        btnThirdGifter.imageView?.contentMode = .scaleAspectFill
        
    }

}
