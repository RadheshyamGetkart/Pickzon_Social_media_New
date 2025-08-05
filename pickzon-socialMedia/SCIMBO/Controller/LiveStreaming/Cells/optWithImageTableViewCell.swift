//
//  optWithImageTableViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 4/27/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class optWithImageTableViewCell: UITableViewCell {
    @IBOutlet weak var imgOption:UIImageView!
    @IBOutlet weak var lblText:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
