//
//  PreferredSkillsCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 3/7/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

protocol PrefereSkillDelegate {
    func skillSelected(skill:String)
}

class PreferredSkillsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var clnSkillsSuggestion:UICollectionView!
    @IBOutlet weak var clnHeight:NSLayoutConstraint!
    
    var arrSkillsSuggested:Array<String> = Array()
    var arrSkillsSelected:Array<String> = Array()
    var skilDelegate:PrefereSkillDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clnSkillsSuggestion.register(UINib(nibName: "skillClnCell", bundle: nil),
                                     forCellWithReuseIdentifier: "skillClnCell")
        
        /*if let flowLayout = clnSkillsSuggestion?.collectionViewLayout as? UICollectionViewFlowLayout {
              flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            }*/
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrSkillsSuggested.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeue the standard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skillClnCell", for: indexPath) as! skillClnCell
        
        cell.lblTitleSkill.text = " " + arrSkillsSuggested[indexPath.row] + " "
        if arrSkillsSelected.contains(arrSkillsSuggested[indexPath.row]) == true {
            cell.viewBg.backgroundColor = UIColor.systemBlue
            cell.viewBg.layer.borderColor = UIColor.clear.cgColor
            cell.viewBg.layer.borderWidth = 1.0
            cell.viewBg.layer.cornerRadius =  cell.viewBg.frame.height / 2.0
            cell.viewBg.clipsToBounds = true
            cell.lblTitleSkill.textColor = UIColor.white
        }else {
            cell.viewBg.backgroundColor = UIColor.clear
            cell.viewBg.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewBg.layer.borderWidth = 1.0
            cell.viewBg.layer.cornerRadius =  cell.viewBg.frame.height / 2.0
            cell.viewBg.clipsToBounds = true
            cell.lblTitleSkill.textColor = UIColor.lightGray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = arrSkillsSuggested[indexPath.row]
        if !arrSkillsSelected.contains(where: { $0 == obj }) {
            arrSkillsSelected.append(obj)
        }else {
            let index = arrSkillsSelected.firstIndex(where: { $0 == obj }) ?? -1
            if index != -1 {
                arrSkillsSelected.remove(at: index)
            }
        }
        
        skilDelegate?.skillSelected(skill: arrSkillsSuggested[indexPath.row])
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: arrSkillsSuggested[indexPath.item].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width + 30, height: 30)
    }
    
    
}
