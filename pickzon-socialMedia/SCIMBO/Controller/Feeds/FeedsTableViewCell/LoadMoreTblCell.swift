//
//  LoadMoreTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/17/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class LoadMoreTblCell: UITableViewCell {

    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var lblMessage:UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityIndicator.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
