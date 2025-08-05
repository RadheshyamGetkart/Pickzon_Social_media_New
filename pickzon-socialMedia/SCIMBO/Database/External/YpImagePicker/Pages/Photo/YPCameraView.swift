//
//  YPCameraView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

//internal class YPCameraView: UIView, UIGestureRecognizerDelegate {


class YPCameraView: UIView { //}, UIGestureRecognizerDelegate {

    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    
    let timeElapsedLabel = UILabel()
    let addSongButton = UIButton()
    
    let progressBar = UIProgressView()
    let filterButton = UIButton()
    
   

     let filterBgview = UIView()
     var  filterCollectionView = UICollectionView(frame:.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var filterIndex = 0

    
    convenience init(overlayView: UIView? = nil) {
        self.init(frame: .zero)

        if let overlayView = overlayView {
            // View Hierarchy
            sv(
                previewViewContainer,
                overlayView,
                progressBar,
                timeElapsedLabel,
                filterButton,
                addSongButton,
                flashButton,
                flipButton,
                
                //filterCollectionView,
                buttonsContainer.sv(
                    shotButton
                ),
                filterBgview
            )
        } else {
            // View Hierarchy
            sv(
                previewViewContainer,
                progressBar,
                timeElapsedLabel,
                filterButton,
                addSongButton,
                flashButton,
                flipButton,
               // filterCollectionView,
                buttonsContainer.sv(
                    shotButton
                ),
                filterBgview
            )
        }
        
        // Layout
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        if YPConfig.onlySquareImagesFromCamera {
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0,
                |buttonsContainer|,
                0
            )
            
            previewViewContainer.heightEqualsWidth()
        } else {
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0
            )
            
            previewViewContainer.fillContainer()
            
            buttonsContainer.fillHorizontally()
            buttonsContainer.height(100)
            buttonsContainer.Bottom == previewViewContainer.Bottom - 50
        }
        
        overlayView?.followEdges(previewViewContainer)
        
        |-(15+sideMargin)-flashButton.size(42)
        flashButton.Bottom == previewViewContainer.Bottom - 15
        
        flipButton.size(42)-(15+sideMargin)-|
        flipButton.Bottom == previewViewContainer.Bottom - 15
        
        timeElapsedLabel-(15+sideMargin)-|
        timeElapsedLabel.Top == previewViewContainer.Top + 15
        
        
        addSongButton.centerHorizontally()
        addSongButton.Top == previewViewContainer.Top
        
        if AppDelegate.sharedInstance.soundInfoSelected.name.length > 0 {
            addSongButton.setTitle(AppDelegate.sharedInstance.soundInfoSelected.name, for: .normal)
        }else {
            addSongButton.setTitle("Add Song", for: .normal)
        }
        
        addSongButton.titleLabel?.textAlignment = .center
        
        
        
        filterButton.size(42)-(15+sideMargin)-|
        filterButton.Top == previewViewContainer.Top + 55

    
       
        shotButton.centerVertically()
        shotButton.size(84).centerHorizontally()
        
        filterBgview.frame = CGRectMake(0, (UIScreen.ft_height()), UIScreen.ft_width(), 94)
        |-(0)-filterBgview.height(94).width(UIScreen.ft_width())
        filterBgview.fillHorizontally()
        filterBgview.backgroundColor = .clear
       // filterBgview.Bottom == previewViewContainer.Bottom-0
        filterBgview.Top == previewViewContainer.Bottom - 94
        filterBgview.isExclusiveTouch = true

        filterCollectionView.frame = CGRectMake(0, 0, UIScreen.ft_width(), 94)
        filterBgview.addSubview(filterCollectionView)
      /*  filterCollectionView.frame = CGRectMake(0, (UIScreen.ft_height()), UIScreen.ft_width(), 94)
        |-(0)-filterCollectionView.height(94).width(UIScreen.ft_width())
        filterCollectionView.fillHorizontally()
        filterCollectionView.Bottom == previewViewContainer.Bottom-0
     */
        // Style
        backgroundColor = YPConfig.colors.photoVideoScreenBackgroundColor
        previewViewContainer.backgroundColor = UIColor.ypLabel
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = YPConfig.fonts.cameraTimeElapsedFont
        }
        progressBar.style { p in
            p.trackTintColor = .clear
            p.tintColor = .ypSystemRed
        }
        flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        shotButton.setImage(YPConfig.icons.capturePhotoImage, for: .normal)
        filterButton.setImage(YPConfig.icons.filterImage, for: .normal)
        filterCollectionView.backgroundColor = .clear
    }
}


/*

extension YPCameraView:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  Constant.sharedinstance.arrFilterEffect.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCVCell", for: indexPath) as! FilterCVCell
        let objFilter = Constant.sharedinstance.arrFilterEffect[indexPath.row]
        cell.lblTitle.text = objFilter.title.capitalized
        if v.filterIndex == indexPath.row {
            cell.lblTitle.textColor = .label
        }else {
            cell.lblTitle.textColor = UIColor.lightGray
        }
        
        cell.imgImage.kf.setImage(with: URL(string: objFilter.icon), placeholder: nil, options:nil, progressBlock: nil, completionHandler: { (resp) in
         })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        v.filterIndex = indexPath.item
        v.filterCollectionView.reloadData()
        self.addFilter()
    }
    
    func addFilter() {
        if v.filterIndex == 0 {
            videoHelper.deepAR.switchEffect(withSlot: "effect", path: nil)
        }else {
            let obj = Constant.sharedinstance.arrFilterEffect[v.filterIndex]
            let url = URL(string: obj.url)
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            DownloadHandler.loadFileAsync(url: url!) { (path, error) in
                DispatchQueue.main.async {
                     Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
                if error == nil {
                    print("File downloaded to : \(path!)")
                    self.videoHelper.deepAR.switchEffect(withSlot: "effect", path: path)
                }
            }
        }
    }
    
}

*/
