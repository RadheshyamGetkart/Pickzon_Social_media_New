//
//  TabHeaderTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 12/21/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

protocol TabDelegate: AnyObject{
    func selectedTabIndex(title:String,index:Int)
}


class TabHeaderTblCell: UITableViewHeaderFooterView { //} UITableViewCell {

    @IBOutlet weak var collectionVw:UICollectionView!
    @IBOutlet weak var cnstntHt_CollectionView:NSLayoutConstraint!

    var isToshow = true
    var tabArray = ["Posts","Videos","Tag","Share"]
    var selectedTab = 0
    weak var delegate:TabDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionVw.register(UINib(nibName: "TabCollectionCell", bundle: nil),
                              forCellWithReuseIdentifier: "TabCollectionCell")
        collectionVw.delegate = self
        collectionVw.dataSource = self
    }
    
    deinit{
        print("TabHeaderTblCell")
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
}



extension TabHeaderTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //MARK: - UICollectionview delegate and datasource

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: self.view.frame.size.width/tabArray.count, height: 40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isToshow == false{
            return 0
        }
        return tabArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionVw.dequeueReusableCell(withReuseIdentifier: "TabCollectionCell", for: indexPath) as! TabCollectionCell
        
        cell.btnTitle.setTitle(tabArray[indexPath.item], for: .normal)
        cell.btnTitle.layer.cornerRadius = cell.btnTitle.frame.size.height/2.0
        cell.btnTitle.clipsToBounds = true
        cell.btnTitle.tag = indexPath.item
        cell.btnTitle.setBackgroundColor(UIColor.clear,forState: .normal)
        cell.btnTitle.setTitleColor(UIColor.darkGray, for: .normal)
        
        if selectedTab == indexPath.item{
            cell.btnTitle.setBackgroundColor(UIColor.init(hexString: "#e7f3ff"), forState: .normal)
            cell.btnTitle.setTitleColor(UIColor.systemBlue, for: .normal)
        }
        cell.btnTitle.addTarget(self, action: #selector(tabButtonAction(_ : )), for: .touchUpInside)
        
        return cell
    }
    
  
    //MARK: Selector Methods
    @objc func tabButtonAction(_ sender: UIButton) {
        selectedTab = sender.tag
        self.collectionVw.reloadData()
        delegate?.selectedTabIndex(title: tabArray[sender.tag], index:sender.tag)
    }
    
}


