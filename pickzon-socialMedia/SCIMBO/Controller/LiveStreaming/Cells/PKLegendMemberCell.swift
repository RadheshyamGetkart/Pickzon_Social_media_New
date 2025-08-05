//
//  PKLegendMemberCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 10/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class PKLegendMemberCell: UICollectionViewCell {

    @IBOutlet weak var bgVwLblTime:UIView!
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var btnNameLeftUser:UIButton!
    @IBOutlet weak var imgVwLeftUser:UIImageView!
    @IBOutlet weak var btnNameRightUser:UIButton!
    @IBOutlet weak var imgVwRightUser:UIImageView!
        
    @IBOutlet weak var lblLeftStatus:UILabel!
    @IBOutlet weak var lblRightStatus:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVwLeftUser.layer.cornerRadius = imgVwLeftUser.frame.height/2.0
        imgVwLeftUser.layer.borderWidth = 1.0
        imgVwLeftUser.layer.borderColor = Themes.sharedInstance.colorWithHexString(hex: "00FEEF").cgColor
        imgVwLeftUser.clipsToBounds = true

        imgVwRightUser.layer.cornerRadius = imgVwRightUser.frame.height/2.0
        imgVwRightUser.layer.borderWidth = 1.0
        imgVwRightUser.layer.borderColor = Themes.sharedInstance.colorWithHexString(hex: "00FEEF").cgColor
        imgVwRightUser.clipsToBounds = true
    }

}
