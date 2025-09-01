//
//  HashTagTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 27/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class HashTagTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblCount:UILabel!
    @IBOutlet weak var bgViewImg:UIView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var bgViewMain:UIView!
    @IBOutlet weak var imgvwProfile:UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgvwProfile.layer.cornerRadius = imgvwProfile.frame.height/2.0
        imgvwProfile.clipsToBounds = true
        imgvwProfile.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
