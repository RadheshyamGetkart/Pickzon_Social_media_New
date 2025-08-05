//
//  ReplayTableViewCell.swift
//
//  Created by raguraman on 27/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
import Kingfisher

class ReplayTableViewCell: CustomTableViewCell
{
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView?
    @IBOutlet weak var replayImg: UIImageView!
    @IBOutlet weak var messageLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var replayImgWidth: NSLayoutConstraint!
    @IBOutlet weak var replaycolour: UILabel!
    @IBOutlet weak var replayView: UIView!
    @IBOutlet weak var tailImg: UIImageView!
    @IBOutlet weak var replayMsg: UILabel!
    @IBOutlet weak var replayName: UILabel!
    @IBOutlet weak var bubleImg: UIImageView!
    @IBOutlet weak var timeLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    @IBOutlet weak var readMoreBtn: UIButton!
    private var readMorePressCount = 1
    @IBOutlet weak var imgVwSender: UIImageViewX?

    override var bubleImage: String{
        didSet{
//            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
//            bubleImg.image = UIImage(named:imgName)?.renderImg()
//            bubleImg.tintColor = statusImg != nil ? outgoingBubbleColour : incommingBubbleColour
            
           // self.setChatviewColor()

        }
    }
    
    override var readCount: String{
        didSet{
            readMorePressCount = Int(readCount) ?? 1
            messageLabel.numberOfLines = 50*readMorePressCount
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tailImg.tintColor = chatView.backgroundColor
        self.addButton(to: replayView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextview(tap:)))
        messageLabel.addGestureRecognizer(tap)
        messageLabel.isUserInteractionEnabled = true
        
        bubleImg.isHidden = true

    }
    
    func setChatviewColor(){
        if(messageFrame.message?.from == MessageFrom(rawValue: 1))
        {
           // self.chatView.roundNew(corners: [.topLeft, .topRight,.bottomLeft], cornerRadius: 15)
            self.chatView.backgroundColor = outgoingBubbleColour
            self.replaycolour.backgroundColor = .white
            self.replayName.textColor = .white

        }else{
            self.replaycolour.backgroundColor = outgoingBubbleColour
            self.chatView.backgroundColor =  Themes.sharedInstance.colorWithHexString(hex: "#f6f6f6")
          //  self.chatView.roundNew(corners: [.topLeft, .topRight,.bottomRight], cornerRadius: 15)
            self.replayName.textColor = outgoingBubbleColour
            self.imgVwSender?.kf.setImage(with: URL(string: messageFrame.message.senderImage), placeholder: UIImage(named: "avatar")!, options:  nil, progressBlock: nil) { response in
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        replayView.backgroundColor = statusImg != nil ? outgoingHighlightColour : incommingHighlightColour
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        replayView.backgroundColor = statusImg != nil ? outgoingHighlightColour : incommingHighlightColour
    }
    
    @IBAction func didClickReadMore(_ sender: UIButton) {
        readMorePressCount += 1
        messageLabel.numberOfLines = 50*readMorePressCount
        delegate?.readMorePressed(sender: sender, count: "\(readMorePressCount)")
    }
    
    override var RowIndex: IndexPath{
        didSet{
            readMoreBtn.tag = RowIndex.row
        }
    }

}



extension UIView {
    
    func roundNew(corners: UIRectCorner, cornerRadius: Double) {
        
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}


