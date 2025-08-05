//
//  WalletInfoVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 5/24/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class WalletInfoVC: UIViewController {

    var postId = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backBtnAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        let viewController:WalletInfoVC = StoryBoard.promote.instantiateViewController(withIdentifier: "WalletInfoVC") as! WalletInfoVC
        viewController.postId = self.postId
        self.navigationController?.pushView(viewController, animated: true)
        
    }

}
