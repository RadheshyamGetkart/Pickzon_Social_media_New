//
//  SPCategoryPlayListCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/30/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

class SPCategoryPlayListCell: UITableViewCell {
    @IBOutlet weak var imgPlayList:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var btnPlayPause:UIButton!
    @IBOutlet weak var btnSave:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
