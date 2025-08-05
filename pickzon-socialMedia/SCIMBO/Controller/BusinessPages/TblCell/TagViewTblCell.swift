//
//  TagViewTblCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/30/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class TagViewTblCell: UITableViewCell {

    @IBOutlet weak var seperatorVw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tagView: TagListView!
    @IBOutlet weak var iconImgVw: UIImageView!
    @IBOutlet weak var btnAdd: UIButtonX!
    @IBOutlet weak var txtfdPlaceholder: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
