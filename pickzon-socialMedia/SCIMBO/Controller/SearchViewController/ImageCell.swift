//
//  ImageCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 26/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imgVwIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    

}



