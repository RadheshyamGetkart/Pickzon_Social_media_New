//
//  SuggestionListTblCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 1/8/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import OnlyPictures

class SuggestionListTblCell: UITableViewCell {

    @IBOutlet weak var profileImgView:ImageWithFrameImgView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var btnRemove:UIButton!
    @IBOutlet weak var btnConnect:UIButton!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var pictureView:OnlyHorizontalPictures!
    @IBOutlet weak var cnstrntWidthPictures:NSLayoutConstraint!
    @IBOutlet weak var bgViewName:UIView!
    @IBOutlet weak var bgViewPickzonId:UIView!

    var pictures: [Users]  = []
    var followerCount = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnRemove.layer.cornerRadius = 5.0
        btnConnect.layer.cornerRadius = 5.0
        updateOnlyPictures()
        profileImgView.initializeView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension SuggestionListTblCell: OnlyPicturesDataSource,OnlyPicturesDelegate {
   
    func updateOnlyPictures(){
        
        pictureView.layer.cornerRadius = 0.0
        pictureView.layer.masksToBounds = true
        pictureView.dataSource = self
        pictureView.delegate = self
        pictureView.order = .ascending
        pictureView.alignment = .right
        pictureView.countPosition = .left
        pictureView.recentAt = .right
        pictureView.spacingColor = UIColor.white
        pictureView.backgroundColorForCount = .lightGray
        pictureView.gap = 15
        pictureView.textColorForCount = .red
        pictureView.fontForCount = UIFont(name: "HelveticaNeue", size: 18)!
    }
           
       
        func numberOfPictures() -> Int {
            return self.pictures.count
        }
       
        func visiblePictures(onlyPictureView: OnlyPictures) -> Int {
            return self.pictures.count
        }
        
        func pictureViews(_ imageView: UIImageView, index: Int){
            let url = URL(string: self.pictures[index].profilePic)
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "avatar") , options: nil, progressBlock: nil, completionHandler: { response in        })
            imageView.contentMode = .scaleAspectFill
        }
    

    func pictureView(_ imageView: UIImageView, didSelectAt index: Int) {
        print("count value: \(index)")
       // delegate?.selectedFollowingUser(userId: pictures[index].id)
    }
}
