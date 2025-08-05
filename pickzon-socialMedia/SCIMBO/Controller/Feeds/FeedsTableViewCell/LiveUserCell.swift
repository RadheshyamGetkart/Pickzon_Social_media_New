//
//  LiveUserCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/18/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class LiveUserCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVwCover:UIImageView!
    @IBOutlet weak var imgVWProfilePic:UIImageView!
    @IBOutlet weak var imgVwPk:UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVWProfilePic.layer.cornerRadius = imgVWProfilePic.frame.size.height/2.0
        imgVWProfilePic.clipsToBounds = true
    }

}
