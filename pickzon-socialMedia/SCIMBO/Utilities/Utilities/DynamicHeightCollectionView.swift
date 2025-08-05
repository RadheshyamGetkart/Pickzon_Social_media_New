//
//  DynamicHeightCollectionView.swift
//  Grub X
//
//  Created by SachTech on 07/08/20.
//  Copyright © 2020 My Apps Development. All rights reserved.
//

import Foundation
import UIKit

class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
