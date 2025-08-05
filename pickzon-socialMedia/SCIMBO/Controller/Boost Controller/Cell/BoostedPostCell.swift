//
//  BoostedPostCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class BoostedPostCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblBoostedTime: UILabel!
    @IBOutlet weak var imgVwPost: UIImageView!
    @IBOutlet weak var btnViewInsights: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 5.0
        bgView.clipsToBounds = true
        
        imgVwPost.layer.cornerRadius = 5.0
        imgVwPost.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
