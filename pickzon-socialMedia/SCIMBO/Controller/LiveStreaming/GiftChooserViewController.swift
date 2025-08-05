//
//  GiftChooserViewController.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import UIKit
import SocketIO

class GiftChooserViewController: UIViewController {
    
    
    var socket: SocketIOClient!
    var room: Room!
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(GiftChooserViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)

    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func giftButtonPressed(_ sender: UIButton) {
        
        socket.emit("gift", [
            "roomKey": room.key,
            "senderId": User.currentUser.id,
            "giftId": sender.tag,
            "giftCount": 1
        ] as [String : Any])
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
