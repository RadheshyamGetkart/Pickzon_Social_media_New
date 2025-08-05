//
//  DynamicHeightTableView.swift
//  Grub X
//
//  Created by SachTech on 30/07/20.
//  Copyright © 2020 My Apps Development. All rights reserved.
//

import Foundation
import UIKit

public class DynamicSizeTableView: UITableView
{
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        return contentSize
    }
}
