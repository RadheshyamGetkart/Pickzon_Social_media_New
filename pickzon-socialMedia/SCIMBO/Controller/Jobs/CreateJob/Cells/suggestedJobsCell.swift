//
//  suggestedJobsCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/25/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class suggestedJobsCell: UITableViewCell {
    @IBOutlet weak var viewBack:UIViewX!
    
    @IBOutlet weak var imgProfilePic:UIImageView!
    @IBOutlet weak var lblJobTitle:UILabel!
    @IBOutlet weak var lblCompanyName:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var lblJobTime:UILabel!
    @IBOutlet weak var lblWorkPlace:UILabel!
    @IBOutlet weak var lblExpLevel:UILabel!
    @IBOutlet weak var lblJobType:UILabel!
    @IBOutlet weak var btnApply:UIButton!
    @IBOutlet weak var btnSave:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBack.layer.cornerRadius = 5.0
        
        
        /*viewBack.layer.masksToBounds = false
        viewBack.layer.shadowColor = UIColor.lightGray.cgColor
        viewBack.layer.shadowOpacity = 0.1
        viewBack.layer.shadowOffset = CGSize(width: 0, height: 1)
        viewBack.layer.shadowRadius = 1
        viewBack.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        */
        
        
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.height / 2.0
        lblWorkPlace.layer.cornerRadius = 5.0
        lblExpLevel.layer.cornerRadius = 5.0
        lblJobType.layer.cornerRadius = 5.0
        
        btnApply.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
