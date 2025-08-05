//
//  CheerCoinTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

protocol CheerCoinDelegate: AnyObject{
    
    func cheeredCoinBuyNow(obj:CoinOfferModel, isAgency:Bool)
}

class CheerCoinTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collectioVwCheerCoin:UICollectionView!
    var coinOfferArray = [CoinOfferModel]()
    var delegate:CheerCoinDelegate?
    var isAgencyCell = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectioVwCheerCoin.register(UINib(nibName: "CoinCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CoinCollectionCell")
        collectioVwCheerCoin.register(UINib(nibName: "AgencyCoinCVCell", bundle: nil), forCellWithReuseIdentifier: "AgencyCoinCVCell")
       collectioVwCheerCoin.delegate = self
       collectioVwCheerCoin.dataSource = self
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


//MARK: - UICollectionview delegate and datasource

extension CheerCoinTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coinOfferArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isAgencyCell == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AgencyCoinCVCell", for: indexPath) as! AgencyCoinCVCell
            
            cell.lblOffer.text = "\(coinOfferArray[indexPath.item].discount)%"
            cell.lblCoinAmount.text = "\(coinOfferArray[indexPath.item].currencySymbol)\(coinOfferArray[indexPath.item].amount)"
            cell.lblCoinCount.text = "\(coinOfferArray[indexPath.item].oldCoins)"
            
            /*if coinOfferArray[indexPath.item].isSelected == true {
                cell.viewBack.layer.borderColor = UIColor.black.cgColor
                cell.imgVwCheck.isHidden = false
            }else {
                cell.imgVwCheck.isHidden = true
                cell.viewBack.layer.borderColor = UIColor(red: 184.0/255.0, green: 153.0/255.0, blue: 159.0/255.0, alpha: 1.0).cgColor
            }*/
            
            if coinOfferArray[indexPath.item].discount == 0{
                cell.lblOffer.isHidden = true
                cell.imgVwOffer.isHidden = true
            }else{
                cell.lblOffer.isHidden = false
                cell.imgVwOffer.isHidden = false
            }
            if coinOfferArray[indexPath.item].oldCoins <  coinOfferArray[indexPath.item].coins {
                cell.lblExtraCoin.isHidden = false
                cell.lblExtraCoin.text = "(+\(coinOfferArray[indexPath.item].coins - coinOfferArray[indexPath.item].oldCoins))"
            }else {
                cell.lblExtraCoin.isHidden = true
            }
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinCollectionCell", for: indexPath) as! CoinCollectionCell
            cell.lblOffer.text = "\(coinOfferArray[indexPath.item].discount)%"
            cell.lblCoinAmount.text = "\(coinOfferArray[indexPath.item].currencySymbol)\(coinOfferArray[indexPath.item].amount)"
            cell.lblCoinCount.text = "\(coinOfferArray[indexPath.item].coins)"
            
            if coinOfferArray[indexPath.item].discount == 0{
                cell.lblOffer.isHidden = true
                cell.imgVwOffer.isHidden = true
            }else{
                cell.lblOffer.isHidden = false
                cell.imgVwOffer.isHidden = false
            }
            cell.btnBuyNow.tag = indexPath.item
            cell.btnBuyNow.addTarget(self, action: #selector(buyBtnAction(_ : )), for: .touchUpInside)
            return cell
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isAgencyCell == true {
            return CGSize(width: self.view.frame.size.width/3.0 , height: (self.view.frame.size.width/3)/2 + 30)
        }else {
            return CGSize(width: self.view.frame.size.width/3.0, height: self.view.frame.size.width/3.0-5 )
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cheeredCoinBuyNow(obj: coinOfferArray[indexPath.row], isAgency: isAgencyCell)

    }
    
    //MARK: - Follow Btn Action
    
    @objc func buyBtnAction(_ sender : UIButton){
        delegate?.cheeredCoinBuyNow(obj: coinOfferArray[sender.tag],isAgency: isAgencyCell)
    }
    
  
    
    
}
