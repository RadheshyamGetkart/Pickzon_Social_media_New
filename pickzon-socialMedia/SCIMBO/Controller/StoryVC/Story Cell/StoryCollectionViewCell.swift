//
//  StoryCollectionViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/9/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var viewBack:UIView!
    @IBOutlet weak var btnUserImage:UIButton!
    @IBOutlet weak var btnUserName:UIButton!
    @IBOutlet weak var viewBack:StatusIndicatorView!
    @IBOutlet weak var btnAdd:UIButton!


    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // viewBack.layer.cornerRadius = viewBack.frame.height / 2.0
       // viewBack.layer.borderWidth = 2
       // viewBack.layer.borderColor = UIColor.lightGray.cgColor
       // viewBack.clipsToBounds = true
        
        
        btnUserImage.layer.cornerRadius = btnUserImage.frame.height / 2.0
        btnUserImage.layer.borderWidth = 1
        btnUserImage.layer.borderColor = UIColor.lightGray.cgColor
        btnUserImage.clipsToBounds = true
        
        btnAdd.setTitle("", for: .normal)
//        btnAdd.layer.cornerRadius = btnAdd.frame.height / 2.0
//        btnAdd.layer.borderWidth = 0.5
//        btnAdd.layer.borderColor = CustomColor.sharedInstance.lightBlueColor.cgColor
//        btnAdd.clipsToBounds = true
        
        //btnAdd.tintColor = UIColor.blue
      //  btnAdd.backgroundColor = UIColor.white

    }
    

}
