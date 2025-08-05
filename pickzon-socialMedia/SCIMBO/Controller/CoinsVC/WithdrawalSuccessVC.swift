//
//  WithdrawalSuccessVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/21/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class WithdrawalSuccessVC: UIViewController {

    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    var message = "We have recieved your withdrawal request. Your amount will be credited in 7-14 business days."
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDone.layer.cornerRadius = 5.0
        btnDone.clipsToBounds = true
        lblMessage.text = message
    }
    
    //MARK: Common Button Actions
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }

}
