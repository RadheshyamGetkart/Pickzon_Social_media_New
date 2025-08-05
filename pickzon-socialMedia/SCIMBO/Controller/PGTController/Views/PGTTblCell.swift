//
//  PGTTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 09/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class PGTTblCell: UITableViewCell {

    @IBOutlet weak var btnNext:UIButton!
    @IBOutlet weak var btnArrow:UIButton!
    @IBOutlet weak var lblPGTTitle:UILabel!
    @IBOutlet weak var lblPGTMonth:UILabel!
    @IBOutlet weak var imgVWPGT:UIImageView!
    @IBOutlet weak var collectionVw:UICollectionView!
    @IBOutlet weak var cnstrntHtCollectionVw:NSLayoutConstraint!
    @IBOutlet weak var bgVwMain:UIView!

    var listArray = [WallPostModel]()
    var isWinner = false
    var hashtagKeyword = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionVw.register(UINib(nibName: "PGTCell", bundle: nil),
                          forCellWithReuseIdentifier: "PGTCell")
        collectionVw.delegate = self
        collectionVw.dataSource = self
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func updateHtOfCollection(){
        if (collectionVw.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .vertical{
            var multiply = (listArray.count >= 3) ?  2  : 0
            if (listArray.count > 0 && listArray.count <= 3){
                multiply = 1
            }
            cnstrntHtCollectionVw.constant = CGFloat(180 * multiply - 10)
        }else{
            cnstrntHtCollectionVw.constant = 180
        }
    }
}

extension PGTTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: self.collectionVw.frame.width/3-3, height: 170)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  listArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionVw.dequeueReusableCell(withReuseIdentifier: "PGTCell", for: indexPath) as! PGTCell
      
        if let urlStr = listArray[indexPath.item].thumbUrlArray.first {
            
            cell.imgVwThumbnail.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imgVwThumbnail.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
            }
        }
        
        if isWinner == true {
            switch indexPath.item
            {
            case 0:
                cell.lblName.text = "1st Winner"
                break
            case 1:
                cell.lblName.text = "2nd Winner"
                break
            case 2:
                cell.lblName.text = "3rd Winner"
                break
            case 3:
                cell.lblName.text = "4th Winner"
                break
            case 4:
                cell.lblName.text = "5th Winner"
                break
            case 5:
                cell.lblName.text = "6th Winner"
                break
            default:
                cell.lblName.text = ""
                break
            }
        }else{
            cell.lblName.text = ""
        }

        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
        destVC.objWallPost = self.listArray[indexPath.item]
        destVC.firstVideoIndex = 0
        destVC.videoType = .feed
        destVC.isHashTagVideos = true
        destVC.hashTag = hashtagKeyword
        destVC.isRandomVideos = false
       // destVC.arrFeedsVideo = listArray
        destVC.isClipVideo = true
        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)

    }
    
}

