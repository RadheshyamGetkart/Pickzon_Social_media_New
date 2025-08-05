//
//  SalaryCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 3/1/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class SalaryCell: UITableViewCell {
    
    @IBOutlet weak var lblSalaryOption:UILabel!
    @IBOutlet weak var btnSalaryOption:UIButton!
    @IBOutlet weak var btnCurrencyOption:UIButton!
    @IBOutlet weak var txtMinSalary:UITextField!
    @IBOutlet weak var txtMaxSalary:UITextField!
    @IBOutlet weak var btnShowSalaryOnPost:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
