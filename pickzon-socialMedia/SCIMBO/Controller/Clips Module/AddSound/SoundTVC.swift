//
//  SoundTVC.swift
//  SCIMBO
//
//  Created by SachTech on 30/07/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit

class SoundTVC: UITableViewCell {

    @IBOutlet weak var songIcon: UIImageViewX!
    @IBOutlet weak var useSong: UIButton!
    @IBOutlet weak var soundName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
