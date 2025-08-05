//
//  PanCardInfoVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/20/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

protocol PanCardDelegate: AnyObject{
    func selectedPanCard(card:String,isPanCardInfo:Bool,isPanCardSaved:Bool)
}
class PanCardInfoVC: UIViewController {
    @IBOutlet weak var collectionVw: UICollectionView!
    @IBOutlet weak var lblExchnahgeCoinLimit: UILabel!
    @IBOutlet weak var bgVwCollection: UIView!

    @IBOutlet weak var lblCheckBoxTitle: UILabel!
    @IBOutlet weak var lblTile: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var cnstrntHtMainVw: NSLayoutConstraint!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var txtFdPanCard: UITextFieldX!
    var delegate:PanCardDelegate?
    var isChecked = true
    var isPanCardInfo = true
    var exchangeLimit = 100
    var panNumber = ""
    var giftedCoin = 0
    var coinArray = [String]() //["500","1000","1500","2000"]
    
    //MARK: Controller life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.layer.cornerRadius = 5.0
        btnNext.clipsToBounds = true
        self.view.backgroundColor = .clear //UIColor.white.withAlphaComponent(0.54)
        
        if isPanCardInfo{
            if panNumber.count > 0{
                self.txtFdPanCard.text = panNumber
            }
            btnNext.setTitle("Next", for: .normal)
            lblTile.text = "Provide your PAN CARD details"
            lblSubTitle.text = "Enter correct information of your PAN CARD for withdrawal."
            lblCheckBoxTitle.text = "Save your details for future withdrawal"
            txtFdPanCard.setAttributedPlaceHolder(text: "Enter pan card number", color: .lightGray)
            cnstrntHtMainVw.constant = 320
            bgVwCollection.isHidden = true
            txtFdPanCard.keyboardType = .default
        }else{
            
            for i in 0...4{
                let value = exchangeLimit + 500 * i
                coinArray.append("\(value)")
            }
            txtFdPanCard.setAttributedPlaceHolder(text: "Enter Gift Coins", color: .lightGray)
            btnNext.setTitle("Exchange", for: .normal)
            btnCheckBox.isHidden = true
            lblTile.text = "Exchange gift coins to cheer coins"
            lblSubTitle.text = ""
            lblExchnahgeCoinLimit.text = "Minimum \(exchangeLimit) gift coins can be exchanged"
            cnstrntHtMainVw.constant = 330
            bgVwCollection.isHidden = false
            lblCheckBoxTitle.isHidden = true
            txtFdPanCard.keyboardType = .numberPad
        }
        collectionVw.register(UINib(nibName: "BtnCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BtnCollectionCell")

    }
    
    //MARK: Common Button Actions
  
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if isPanCardInfo{

            //PAN CARD Info
            if  txtFdPanCard.text?.count ?? 0 < 10{
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter valid 10 digit PAN CARD number.")
                
            }else if !(txtFdPanCard.text ?? "").isPanCardValid{
              
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter valid PAN CARD number.")
                
            }else{
                self.dismiss(animated: false, completion: nil)
                delegate?.selectedPanCard(card: txtFdPanCard.text ?? "",isPanCardInfo:isPanCardInfo,isPanCardSaved:isChecked)
            }
        }else{
           //Exchange
            if (Int(txtFdPanCard.text!) ?? 0 == 0 || Int(txtFdPanCard.text!) ?? 0 < 0) {
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter valid coins")


            }else if  Int(txtFdPanCard.text!) ?? 0 < exchangeLimit{
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You cannot exchange gift coins less than exchange limit.")
             }else if  Int(txtFdPanCard.text!) ?? 0 > giftedCoin{
                 AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You have no sufficient gift coins.")

              }else{
                 self.dismiss(animated: false, completion: nil)
                 delegate?.selectedPanCard(card: txtFdPanCard.text ?? "",isPanCardInfo:isPanCardInfo,isPanCardSaved:false)
             }
        }
    }
    
    
    @IBAction func btnCheckBoxAction(_ sender: UIButton) {
        self.view.endEditing(true)
        isChecked.toggle()
        if isChecked{
            btnCheckBox.setImage(UIImage(named: "ic_round-check-box"), for: .normal)
        }else{
            btnCheckBox.setImage(UIImage(named: "ic_round-uncheck-box"), for: .normal)

        }
    }
}

extension PanCardInfoVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate{
   
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        
        if isPanCardInfo{
            
            if updatedText.length > 10 {
                return false
            }
            return updatedText.isAlphanumeric
            
        }else{
            
            if updatedText.length > 6 {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coinArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BtnCollectionCell", for: indexPath) as! BtnCollectionCell
        cell.lblItem.text = coinArray[indexPath.row]
        cell.lblItem.layer.cornerRadius = cell.lblItem.frame.size.height/2.0
        cell.lblItem.layer.borderWidth = 1.0
        cell.lblItem.layer.borderColor = UIColor.lightGray.cgColor
        cell.lblItem.clipsToBounds = true
        
        return cell
    }
    

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: self.view.frame.size.width/3.0-5, height: self.view.frame.size.width/3.0-5)
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        txtFdPanCard.text = coinArray[indexPath.row]
    }
    
    //MARK: - Follow Btn Action
    @objc func buyBtnAction(_ sender : UIButton){
      
    }
        
    
}


