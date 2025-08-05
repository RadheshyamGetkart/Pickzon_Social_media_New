//
//  GiftTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/22/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class GiftTblCell: UITableViewCell {

    @IBOutlet weak var collectionVw:UICollectionView!
    var delegate:CoinUpTblCellDelegate?
    var giftCoinList = [CoinModel]()
    var selectedIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionVw.register(UINib(nibName: "GiftCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GiftCollectionCell")
        collectionVw.delegate = self
        collectionVw.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


//MARK: - UICollectionview delegate and datasource

extension GiftTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return giftCoinList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftCollectionCell", for: indexPath) as! GiftCollectionCell
        cell.btnCoin.setTitle(giftCoinList[indexPath.row].label, for: .normal)
       
        cell.imgVwGift.kf.setImage(with: URL(string: giftCoinList[indexPath.row].icon), placeholder: UIImage(named: "coin1") , options: nil, progressBlock: nil, completionHandler: { response in })
   
        cell.bgVw.layer.cornerRadius = 5.0
        if indexPath.row == selectedIndex{
            cell.bgVw.backgroundColor =  .darkGray //Themes.sharedInstance.colorWithHexString(hex: "")
        }else{
            cell.bgVw.backgroundColor = .clear

        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: self.view.frame.size.width/3.0-5, height: 100)//self.view.frame.size.width/3.0-5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        self.collectionVw.reloadData()
        delegate?.coinGiven(obj: giftCoinList[indexPath.row], index: indexPath.item)
    }
    
 
        
    
}
