//
//  SPCategoryCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/1/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

class SPCategoryCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var clnView:UICollectionView!
    var arrItems:Array<SpotifyCategory> = Array()
    var objSPCategoryDelegate:SPCategoryProtocol!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        clnView.register(UINib(nibName: "SpotifyCategoriesCell", bundle: .main), forCellWithReuseIdentifier: "SpotifyCategoriesCell")

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCategoriesCell", for: indexPath as IndexPath) as! SpotifyCategoriesCell
        
        let objSpotifyCategory = arrItems[indexPath.item]
        
        cell.lblName.text = objSpotifyCategory.name
        
        let arrIcons = objSpotifyCategory.icons
        if arrIcons.count > 0 {
            let icon = arrIcons.last
            let url = icon?["url"] as? String ?? ""
            cell.imgCategory.kf.setImage(with: URL(string: "\(url)"), placeholder:PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
            })
        }
        
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*let viewController:SPCategoriesPlayListVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPCategoriesPlayListVC") as! SPCategoriesPlayListVC
        let objSpotifyCategory = arrItems[indexPath.row]
        viewController.category =  objSpotifyCategory.id
        viewController.strTitle = objSpotifyCategory.name
        self.navigationController?.pushViewController(viewController, animated: true)*/
        objSPCategoryDelegate.categorySelected(index: indexPath.row)
    }
        
        
        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            return self.arrItems.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
            return CGSize(width: 150, height: 150)
        }
    
    
}
