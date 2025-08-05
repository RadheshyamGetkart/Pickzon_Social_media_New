//
//  PkRequestTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/7/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class PkRequestTblCell: UITableViewCell {

    
    @IBOutlet weak var btnAccept:UIButton!
    @IBOutlet weak var btnDecline:UIButton!
    @IBOutlet weak var btnProfilePic:UIButton!
    @IBOutlet weak var btnName:UIButton!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var bgVwName:UIViewX!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnAccept.layer.cornerRadius = btnAccept.frame.size.height/2.0
        btnAccept.clipsToBounds = true
        
        btnDecline.layer.cornerRadius = btnDecline.frame.size.height/2.0
        btnDecline.clipsToBounds = true
        
        btnProfilePic.layer.cornerRadius = btnProfilePic.frame.size.height/2.0
        btnProfilePic.clipsToBounds = true
        
        bgVwName.layer.cornerRadius = bgVwName.frame.size.height/2.0
        bgVwName.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
