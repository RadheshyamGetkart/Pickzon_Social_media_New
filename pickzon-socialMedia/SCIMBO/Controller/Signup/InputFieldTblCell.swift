//
//  InputFieldTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 20/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class InputFieldTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnRight:UIButton!
    @IBOutlet weak var txtFieldName:UITextField!
    @IBOutlet weak var btnDD:UIButton!
    @IBOutlet weak var btnInfo:UIButton!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var bgViewSegmentControl:UIView!
    @IBOutlet weak var segmentControl:UISegmentedControl!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        
        bgViewSegmentControl.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        bgViewSegmentControl.layer.cornerRadius = 10.0
        bgViewSegmentControl.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
