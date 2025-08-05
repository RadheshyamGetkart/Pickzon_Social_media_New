//
//  SearchUserTVC.swift
//  SCIMBO
//
//  Created by SachTech on 02/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit

class SearchUserTVC: UITableViewCell {

    @IBOutlet weak var userVideoCountLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var watchBtn: UIButton!
    @IBOutlet weak var imgVwCelecbrity: UIImageView!
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImgView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
