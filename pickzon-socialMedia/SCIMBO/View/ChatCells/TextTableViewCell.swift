//
//  TextTableViewCell.swift
//
//  Created by raguraman on 04/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
import Kingfisher

class TextTableViewCell: CustomTableViewCell {

    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView?
    
    @IBOutlet weak var messageLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var tailImg: UIImageView!
    @IBOutlet weak var timeLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var bubleImg: UIImageView!
    
    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    @IBOutlet weak var imgVwSender: UIImageViewX?


    
    private var readMorePressCount = 1
    override var bubleImage: String{
        didSet{
//            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
//            bubleImg.image = UIImage(named:imgName)?.renderImg()
//           // bubleImg.tintColor = statusImg != nil ? outgoingBubbleColour : incommingBubbleColour
//            bubleImg.setImageColor(color: (statusImg != nil ? outgoingBubbleColour : incommingBubbleColour))
            chatView.backgroundColor =  (statusImg != nil ? outgoingBubbleColour : incommingBubbleColour)
            self.setChatviewColor()

        }
    }
    
    func setChatviewColor(){
        
        if(messageFrame.message?.from == MessageFrom(rawValue: 1))
        {
            //self.chatView.roundNew(corners: [.topLeft, .topRight,.bottomLeft], cornerRadius: 15)
            self.chatView.backgroundColor = outgoingBubbleColour
            

        }else{
            self.chatView.backgroundColor =  Themes.sharedInstance.colorWithHexString(hex: "#f6f6f6")
           // self.chatView.roundNew(corners: [.topLeft, .topRight,.bottomRight], cornerRadius: 15)
            self.imgVwSender?.kf.setImage(with: URL(string: messageFrame.message.senderImage), placeholder: UIImage(named: "avatar")!, options:  nil, progressBlock: nil) { response in
            }
        }
    }
    
    override var readCount: String{
        didSet{
            readMorePressCount = Int(readCount) ?? 1
            messageLabel.numberOfLines = 50*readMorePressCount
        }
    }
    
    override var RowIndex: IndexPath{
        didSet{
            readMoreBtn.tag = RowIndex.row
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
//        print("Editing called")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       tailImg.tintColor = chatView.backgroundColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextview(tap:)))
        messageLabel.addGestureRecognizer(tap)
        messageLabel.isUserInteractionEnabled = true
    }
    
    @IBAction func didClickReadMore(_ sender: UIButton) {
        readMorePressCount += 1
        messageLabel.numberOfLines = 50*readMorePressCount
        delegate?.readMorePressed(sender: sender, count: "\(readMorePressCount)")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
