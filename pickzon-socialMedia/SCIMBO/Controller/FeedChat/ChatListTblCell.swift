//
//  ChatListTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/28/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

class ChatListTblCell: UITableViewCell {

    
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

   // @IBOutlet weak var btnProfile:UIButtonX!
    @IBOutlet weak var lblChatCount:UILabelX!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var celebrityImgVw:UIImageView!
    @IBOutlet weak var lblDate:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblChatCount.layer.cornerRadius = lblChatCount.frame.size.height/2.0
        lblChatCount.clipsToBounds = true
        profileImgView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
        
    func setChatlistData(_ chatData: FeedChatModel){
        
        if (chatData.userInfo?.name ?? "").count > 0{
            lblName.text = chatData.userInfo?.name ?? ""
        }else{
            lblName.text = chatData.userInfo?.pickzonId ?? ""
        }
        
        profileImgView.setImgView(profilePic: chatData.userInfo?.profilePic ?? "", frameImg: chatData.userInfo?.avatar ?? "",changeValue: 5)
        celebrityImgVw.isHidden = true
        if chatData.userInfo?.celebrity == 1 {
            celebrityImgVw.isHidden = false
            celebrityImgVw.image = PZImages.greenVerification
        }else if chatData.userInfo?.celebrity == 4 {
            celebrityImgVw.isHidden = false
            celebrityImgVw.image = PZImages.goldVerification
        }else if chatData.userInfo?.celebrity == 5 {
            celebrityImgVw.isHidden = false
            celebrityImgVw.image = PZImages.blueVerification
        }
        let time = (Double(chatData.timeStamp)/1000).timestampToDate()
        lblDate.text = time.offsetFrom()
        lblChatCount.isHidden = chatData.unreadCount == 0
        lblChatCount.text = "\(chatData.unreadCount)"
        lblDesc.attributedText = NSAttributedString(string: chatData.lastMessage)
    }
}
