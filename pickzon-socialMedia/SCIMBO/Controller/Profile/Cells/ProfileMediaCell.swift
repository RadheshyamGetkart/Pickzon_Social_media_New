//
//  ProfileMediaCell.swift
//  SCIMBO
//
//  Created by Getkart on 01/07/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class ProfileMediaCell: UICollectionViewCell {
    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var imgVideoThumb: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var btnDeleteVideo: UIButton!
    @IBOutlet weak var btnEditVideo: UIButton!
    @IBOutlet weak var eye: UIImageView!
    @IBOutlet weak var imgVwVideoIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDeleteVideo.isHidden = true
        lblViewCount.isHidden = true
        eye.isHidden = true
        btnEditVideo.isHidden = true
        imgVideoThumb.layer.cornerRadius = 5.0
        imgVideoThumb.clipsToBounds = true
        lblDesc.layer.cornerRadius = 5.0
        lblDesc.clipsToBounds = true
    }

    deinit {
       
    }
    func setVideoIcon(urlStr:String){
        
            if checkMediaTypes(strUrl: urlStr) == 1{
                imgVwVideoIcon.isHidden = true
            }else{
                imgVwVideoIcon.isHidden = false
            }
    }
}

