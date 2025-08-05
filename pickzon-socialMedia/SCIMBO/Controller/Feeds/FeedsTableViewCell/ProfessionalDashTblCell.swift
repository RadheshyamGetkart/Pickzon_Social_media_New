//
//  ProfessionalDashTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/16/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class ProfessionalDashTblCell: UITableViewCell {
    
    @IBOutlet weak var imgVwPost:UIImageView!
    @IBOutlet weak var lblViewCount:UILabel!
    @IBOutlet weak var lblLikeCount:UILabel!
    @IBOutlet weak var seperatorView:UIView!
    
    @IBOutlet weak var bgVwLikesCount:UIView!
    @IBOutlet weak var bgVwStack:UIStackView!
    @IBOutlet weak var bgVwUnqualified:UIView!

    @IBOutlet weak var lblUnqualifiedReason:UILabel!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgVwPost.layer.cornerRadius = 5.0
        imgVwPost.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
