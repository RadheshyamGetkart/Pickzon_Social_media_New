//
//  CoinUpTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

protocol CoinUpTblCellDelegate: AnyObject{
    func coinGiven(obj:CoinModel,index:Int)
}

class CoinUpTblCell: UITableViewCell {

    @IBOutlet weak var collectionVwCoinUp:UICollectionView!
    @IBOutlet weak var lblAvailableCoin:UILabel!
    @IBOutlet weak var lblAvailableTitle:UILabel!
    @IBOutlet weak var availableClick:UIButton!
    @IBOutlet weak var btnArrow:UIButton!

    var delegate:CoinUpTblCellDelegate?
    
    var cheerCoinList = [CoinModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionVwCoinUp.register(UINib(nibName: "CheerUpCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CheerUpCollectionCell")
        collectionVwCoinUp.delegate = self
        collectionVwCoinUp.dataSource = self
        btnArrow.setImageTintColor(CustomColor.sharedInstance.newThemeColor)
    }
 

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UICollectionview delegate and datasource

extension CoinUpTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cheerCoinList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheerUpCollectionCell", for: indexPath) as! CheerUpCollectionCell
        cell.lblCoinName.text = cheerCoinList[indexPath.row].label
        cell.imgVwCoin.kf.setImage(with: URL(string: cheerCoinList[indexPath.row].icon), placeholder: UIImage(named: "coin1") , options: nil, progressBlock: nil, completionHandler: { response in })
        //        cell.b.tag = indexPath.item
        //        cell.btnBuyNow.addTarget(self, action: #selector(buyBtnAction(_ : )), for: .touchUpInside)
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

//        return CGSize(width: self.view.frame.size.width/3.0-5, height: self.view.frame.size.width/3.0-5)
        return CGSize(width: self.view.frame.size.width/3.0-5, height: 95)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        delegate?.coinGiven(obj: cheerCoinList[indexPath.row],index:indexPath.row)
    }
    
    //MARK: - Follow Btn Action
    @objc func buyBtnAction(_ sender : UIButton){
      
    }
        
    
}
