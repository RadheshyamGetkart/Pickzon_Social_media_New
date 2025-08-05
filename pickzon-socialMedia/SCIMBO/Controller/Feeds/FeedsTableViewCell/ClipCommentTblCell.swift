//
//  ClipCommentTVC.swift
//  SCIMBO
//
//  Created by Getkart on 12/06/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

import Kingfisher

class ClipCommentTblCell: UITableViewCell {
    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var btnDay:UIButton!
    @IBOutlet weak var btnLike:UIButton!
    @IBOutlet weak var btnReply:UIButton!
    @IBOutlet weak var likeBgVw:UIView!
    @IBOutlet weak var btnHeart:UIButton!
    @IBOutlet weak var btnProfile:UIButtonX!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var cnstrntLeading:NSLayoutConstraint!
    @IBOutlet weak var lblComment:ExpandableLabel!
    @IBOutlet weak var btnExpand:UIButton!
    @IBOutlet weak var btnDelete:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicView.initializeView()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
//        lblComment.numberOfLines = 3
//        lblComment.collapsed = true
//        lblComment.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
        
        //        let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
        //            NSAttributedString.Key.foregroundColor: Themes.sharedInstance.tagAndLinkColor(),
        //            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        //        ]
        //        let readLessTextAttributes = [
        //            NSAttributedString.Key.foregroundColor: UIColor.red,
        //            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16)
        //        ]
        // txtVwComment.attributedReadMoreText = NSAttributedString(string: "... Readmore" ,attributes: readMoreTextAttributes)
        //  txtVwComment.attributedReadLessText = NSAttributedString(string: " Read less",attributes: readLessTextAttributes)
    }
    
}
