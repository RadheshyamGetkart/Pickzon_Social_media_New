//
//  FeedsCollectionViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/26/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import AVKit

class FeedsCollectionViewCell: UICollectionViewCell {    
    
    @IBOutlet weak var imgImageView: UIImageView!
    @IBOutlet weak var btnPlayPause:UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnPreview:UIButton!
    @IBOutlet weak var cnstrntBottomBtnPreview:NSLayoutConstraint!
    
    var isZooming = false
    var originalImageCenter:CGPoint?

    var url:String = ""
    var isFirstTime = true
    var isVideo = false
    var urlArray = Array<String>()
    var selIndex = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnPlayPause.isHidden = true
       
   /*     let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinch.delegate = self
        imgImageView.addGestureRecognizer(pinch)
        
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        imgImageView.addGestureRecognizer(pan)*/
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    func configureCell(isToHidePlayer:Bool,indexPath:IndexPath){
         selIndex = indexPath.row
        //self.backgroundColor = UIColor.darkGray
        //self.mmPlayerLayer.backgroundColor = UIColor.clear.cgColor
       
        if (isToHidePlayer == true){
            //  self.imgImageView.contentMode = .scaleAspectFill
            //let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            //self.imgImageView.addGestureRecognizer(tap)
            
            self.imgImageView.isHidden = false
            self.videoView.isHidden  = true
        }else{
            self.videoView.isHidden = false
            self.imgImageView.isHidden = true
           
            
        }
        
    }
    
  
    func setPreviewBtnFrame(top:Bool)  {
       
        if top == true {
            
            self.btnPreview.frame = CGRect(x: self.frame.size.width - 40, y: self.imgImageView.frame.origin.y + 5 , width: self.btnPreview.frame.size.width, height: self.btnPreview.frame.size.height)
            self.btnPreview.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            self.btnPreview.setImage(UIImage(named: "menu_delete"), for: .normal)
        }
    }
    
    
    
   
    
    
    
    
    func handlePlayPause() {
        
        
    }
    
  
}


extension FeedsCollectionViewCell:UIGestureRecognizerDelegate{
    
    @objc  func pan(sender: UIPanGestureRecognizer) {
     if self.isZooming && sender.state == .began {
         self.originalImageCenter = sender.view?.center
      } else if self.isZooming && sender.state == .changed {
      let translation = sender.translation(in: self)
      if let view = sender.view {
      view.center = CGPoint(x:view.center.x + translation.x,
      y:view.center.y + translation.y)
      }
      sender.setTranslation(CGPoint.zero, in: self.imgImageView.superview)
      }
      }
    
    
      @objc func pinch(sender:UIPinchGestureRecognizer) {
          if sender.state == .began {
          let currentScale = self.imgImageView.frame.size.width / self.imgImageView.bounds.size.width
          let newScale = currentScale*sender.scale
          if newScale > 1 {
          self.isZooming = true
          }
          } else if sender.state == .changed {
          guard let view = sender.view else {return}
          let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
          y: sender.location(in: view).y - view.bounds.midY)
          let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
          .scaledBy(x: sender.scale, y: sender.scale)
          .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
          let currentScale = self.imgImageView.frame.size.width / self.imgImageView.bounds.size.width
          var newScale = currentScale*sender.scale
          if newScale < 1 {
          newScale = 1
          let transform = CGAffineTransform(scaleX: newScale, y: newScale)
          self.imgImageView.transform = transform
          sender.scale = 1
          }else {
          view.transform = transform
          sender.scale = 1
          }
          } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
          guard let center = self.originalImageCenter else {return}
          UIView.animate(withDuration: 0.2, animations: {
          self.imgImageView.transform = CGAffineTransform.identity
          self.imgImageView.center = center
          }, completion: { _ in
          self.isZooming = false
          })
          }
          
          self.imgImageView.reloadInputViews()

          }
    
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
    }
    
}

























