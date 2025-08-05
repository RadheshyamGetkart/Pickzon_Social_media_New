//
//  IgnoreTouch.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import SVGAPlayer


class IgnoreTouchView : UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self || ((hitView?.isKind(of: SVGAPlayer.self)) != nil) {
            return nil
        }
        return hitView
    }
}

class IgnoreTouchImageView : UIImageView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self || ((hitView?.isKind(of: UIButton.self)) != nil) {
            return nil
        }
        return hitView
    }
}

