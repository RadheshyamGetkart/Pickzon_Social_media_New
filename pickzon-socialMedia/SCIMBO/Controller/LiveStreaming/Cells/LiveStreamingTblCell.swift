//
//  LiveStreamingTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class LiveStreamingTblCell: UITableViewCell {
    
    @IBOutlet weak var imgVwMicMuteLeft: UIImageView!
    @IBOutlet weak var imgVwCameraMuteLeft: UIImageView!
    @IBOutlet weak var imgVwMicMuteRight: UIImageView!
    @IBOutlet weak var imgVwCameraMuteRight: UIImageView!
    @IBOutlet weak var imgVwMicMuteSingleLive: UIImageView!
    @IBOutlet weak var imgVwCameraMuteSingleLive: UIImageView!
    
//    @IBOutlet weak var bgBlurImagevw: UIImageView!
    @IBOutlet weak var imgVwSeperatorGif: UIImageView!
    @IBOutlet weak var bgVwTimer: UIView!

    @IBOutlet weak var bgViewPK: UIView!
    @IBOutlet weak var previewView: UIView!
//    @IBOutlet weak var cnstrntYAxixPkBg: NSLayoutConstraint!

    @IBOutlet weak var bgVwSelectedUser: UIView!
    @IBOutlet weak var btnSelectedName: UIButton!
    @IBOutlet weak var btnSelectedTotalCoin: UIButton!
    @IBOutlet weak var imgVwCelebritySelected: UIImageView!
    @IBOutlet weak var btnSelectedProfilePic: UIButton!
    @IBOutlet weak var btnAddSelected: UIButton!
    @IBOutlet weak var lblWinningStatus: UILabel!
    @IBOutlet weak var cnstrntWidthBtnAddSelected: NSLayoutConstraint!
    @IBOutlet weak var cnstrntWidthTopBtnAdd: NSLayoutConstraint!
   // @IBOutlet weak var backView: IgnoreTouchView!
    @IBOutlet weak var previewViewLeft: UIView!
    @IBOutlet weak var previewViewRight: UIView!
   
    //Top View
    @IBOutlet weak var bgViewTop: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnTotalCoin: UIButton!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var collectionVwJoinedUser: UICollectionView!
    @IBOutlet weak var btnclose: UIButton!
    @IBOutlet weak var btnTotalCountJoined: UIButton!
   // @IBOutlet weak var cnstrntTop: NSLayoutConstraint!
    
    @IBOutlet weak var cnstrntHeightPreviewBg: NSLayoutConstraint!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnLeftCoin: UIButton!
    @IBOutlet weak var btnRightCoin: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var blurPkImgView: UIImageView!
   
  
    @IBOutlet weak var leftBlurBgView: IgnoreTouchView!
    @IBOutlet weak var leftBlurImgView: IgnoreTouchImageView!
    @IBOutlet weak var rightBlurImgVw: IgnoreTouchImageView!
    @IBOutlet weak var rightBlurBgVw: IgnoreTouchView!
    //@IBOutlet weak var imgVwProfileBlur: UIImageView!
    
   // @IBOutlet weak var bgVwBlurImage: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
