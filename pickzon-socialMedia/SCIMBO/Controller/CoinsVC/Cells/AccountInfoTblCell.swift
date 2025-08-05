//
//  AccountInfoTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/20/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AccountInfoTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var txtFdName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtFdName.layer.cornerRadius = 5.0
        txtFdName.layer.borderWidth = 1.0
        txtFdName.layer.borderColor = UIColor.lightGray.cgColor
        txtFdName.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
