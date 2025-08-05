//
//  AddPostView.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/21/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

class AddPostView: UIView {

    var optionArray = ["Create Post","Go Live ◉"]// "Post","Pages"]//,"Groups"]//,"Saved"]//"  "Clips","Mall Ads", Go Live","Camera"
    var optionImgArray = ["CreatePost","CreatePage"]//,"CreateGroup"]//,"reels-1","Postad",,"feedsSavePostRed"]//,"Camera"
    @IBOutlet weak var cllctnView:UICollectionView!
    @IBOutlet weak var bgview:UIView!
    @IBOutlet weak var popupBgVw:UIView!

    var delegate:StoriesDelegate? = nil
    @IBOutlet weak var cnstrntBottom:NSLayoutConstraint!

  
    func initializeMethods(frame:CGRect)  {
        self.removeFromSuperview()

        view.backgroundColor = .clear
        bgview.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        self.cllctnView.register(UINib(nibName: "OptionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "OptionCollectionCell")
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height-30)
        self.cllctnView.delegate = self
        self.cllctnView.dataSource = self
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        if UIDevice().hasNotch {
            self.frame = CGRect(x: 0, y: -10, width: frame.size.width, height: frame.size.height-20)

        }else{
            cnstrntBottom.constant = 70
        }
        
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
//            appDelegate.window?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
//        }
//        let frame = popupBgVw.frame
//        popupBgVw.frame = .zero
//        UIView.animate(withDuration: 0.1) {
//            self.popupBgVw.frame = frame
//        }
    }
   
    @objc func tapOnView(){
        self.removeFromSuperview()
    }
}

extension AddPostView:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    //MARK: - UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return optionArray.count
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCollectionCell", for: indexPath) as! OptionCollectionCell
        
//        cell.btnTitle.tag = indexPath.item
//        cell.btnTitle.addTarget(self, action: #selector(optionBtnAction(_ : )), for: .touchUpInside)
//        cell.btnImage.layer.cornerRadius = cell.btnImage.frame.size.height / 2.0
//        cell.btnTitle.clipsToBounds = true
//        cell.btnImage.setImage(UIImage(named: optionImgArray[indexPath.item]), for: .normal)
//        cell.lblTitle.text = optionArray[indexPath.item]
//        cell.lblTitle.textColor = .black
        
        cell.lblTitle.isHidden = true
        cell.btnImage.isHidden = true
        cell.btnTitle.setTitle(optionArray[indexPath.item], for: .normal)
        cell.btnTitle.tag = indexPath.item
        cell.btnTitle.addTarget(self, action: #selector(optionBtnAction(_ : )), for: .touchUpInside)

        if optionArray[indexPath.item] == "Go Live ◉"{
//            if Settings.sharedInstance.isLiveAllowed == 2{
//                cell.btnTitle.setTitle("Get Live ◉", for: .normal)
//
//            }
            cell.btnTitle.setTitleColor(.red, for: .normal)
        }else{
            cell.btnTitle.setTitleColor(.white, for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        return CGSize(width: (self.cllctnView.frame.size.width)/2.0 + 5, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        cllctnView.deselectItem(at: indexPath, animated: true)
        tapOnView()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    //MARK: - Selector Methods
    @objc func optionBtnAction(_ sender : UIButton){
        tapOnView()
        
        if optionArray[sender.tag] == "Create Post"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .postFeed)
            
        }else if optionArray[sender.tag] == "Clips"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .reels)
            
        }else if optionArray[sender.tag] == "Saved"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .saved)
            
        }else if optionArray[sender.tag] == "Pages"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .createPage)
            
        }else if optionArray[sender.tag] == "Groups"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .creategroup)
        }else if optionArray[sender.tag] == "Go Live ◉"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .golive)
        }else if optionArray[sender.tag] == "Camera"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .postFeedWithCamera)
        }else if optionArray[sender.tag] == "Mall Ads"{
            self.delegate?.selectedHeaderOptionsInFeeds(selectionType: .postAds)
        }
        
    }
    
}
