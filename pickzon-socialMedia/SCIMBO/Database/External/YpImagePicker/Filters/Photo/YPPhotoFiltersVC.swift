//
//  YPPhotoFiltersVC.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import UIKit
import Mantis

protocol IsMediaFilterVC: AnyObject {
    var didSave: ((YPMediaItem) -> Void)? { get set }
    var didCancel: (() -> Void)? { get set }
}

open class YPPhotoFiltersVC: UIViewController, IsMediaFilterVC, UIGestureRecognizerDelegate {
    
    required public init(inputPhoto: YPMediaPhoto, isFromSelectionVC: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        self.inputPhoto = inputPhoto
        self.isFromSelectionVC = isFromSelectionVC
    }
    
    public var inputPhoto: YPMediaPhoto!
    public var isFromSelectionVC = false

    public var didSave: ((YPMediaItem) -> Void)?
    public var didCancel: (() -> Void)?

    fileprivate let filters: [YPFilter] = YPConfig.filters

    fileprivate var selectedFilter: YPFilter?
    
    fileprivate var filteredThumbnailImagesArray: [UIImage] = []
    fileprivate var thumbnailImageForFiltering: CIImage? // Small image for creating filters thumbnails
    fileprivate var currentlySelectedImageThumbnail: UIImage? // Used for comparing with original image when tapped

    fileprivate var v = YPFiltersView()

    override open var prefersStatusBarHidden: Bool { return YPConfig.hidesStatusBar }
    override open func loadView() { view = v }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life Cycle ♻️

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup of main image an thumbnail images
        v.imageView.image = inputPhoto.image
        thumbnailImageForFiltering = thumbFromImage(inputPhoto.image)
        DispatchQueue.global().async {
            self.filteredThumbnailImagesArray = self.filters.map { filter -> UIImage in
                if let applier = filter.applier,
                    let thumbnailImage = self.thumbnailImageForFiltering,
                    let outputImage = applier(thumbnailImage) {
                    return outputImage.toUIImage()
                } else {
                    return self.inputPhoto.originalImage
                }
            }
            DispatchQueue.main.async {
                self.v.collectionView.reloadData()
                self.v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                            animated: false,
                                            scrollPosition: UICollectionView.ScrollPosition.bottom)
                self.v.filtersLoader.stopAnimating()
            }
        }
        
        // Setup of Collection View
        v.collectionView.register(YPFilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCell")
        v.collectionView.dataSource = self
        v.collectionView.delegate = self

        view.backgroundColor = YPConfig.colors.filterBackgroundColor
        
        // Setup of Navigation Bar
        title = YPConfig.wordings.filter
        if isFromSelectionVC {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancel))
            navigationItem.leftBarButtonItem?.setFont(font: YPConfig.fonts.leftBarButtonFont, forState: .normal)
        }
        setupRightBarButton()
        
        YPHelper.changeBackButtonIcon(self)
        YPHelper.changeBackButtonTitle(self)
        
        // Touch preview to see original image.
        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        v.imageView.addGestureRecognizer(touchDownGR)
        v.imageView.isUserInteractionEnabled = true
       
        v.customCropButton.isUserInteractionEnabled = true
        v.customCropButton.addTarget(self,
                       action: #selector(customCropButtonTapped),
                       for: .touchUpInside)
    }
    
    // MARK: Setup - ⚙️
    
    fileprivate func setupRightBarButton() {
        let rightBarButtonTitle = isFromSelectionVC ? YPConfig.wordings.done : YPConfig.wordings.next
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonTitle,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
        navigationItem.rightBarButtonItem?.setFont(font: YPConfig.fonts.rightBarButtonFont, forState: .normal)
    }
    
    // MARK: - Methods 🏓

    @objc
    fileprivate func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            v.imageView.image = inputPhoto.originalImage
        case .ended:
            v.imageView.image = currentlySelectedImageThumbnail ?? inputPhoto.originalImage
        default: ()
        }
    }
    
    fileprivate func thumbFromImage(_ img: UIImage) -> CIImage {
        let k = img.size.width / img.size.height
        let scale = UIScreen.main.scale
        let thumbnailHeight: CGFloat = 300 * scale
        let thumbnailWidth = thumbnailHeight * k
        let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
        UIGraphicsBeginImageContext(thumbnailSize)
        img.draw(in: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return smallImage!.toCIImage()!
    }
    
    // MARK: - Actions 🥂
    @objc func customCropButtonTapped() {
        
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//
//            let editor = LFPhotoEditingController()
//            editor.delegate = self
//
//            let nav = UINavigationController(rootViewController: editor)
//            nav.modalPresentationStyle = .fullScreen
//            nav.setNavigationBarHidden(true, animated: false)
//
//            self.present(nav, animated: true)
//        }

        editPhoto()
      /*  return
        
        guard let selectedAssetImage =  v.imageView.image  else {
            // If no selected asset, than the squareCropButton is not visible
            //  squareCropButton.isHidden = true
            return
        }
        let cropViewController = Mantis.cropViewController(image: selectedAssetImage)
        cropViewController.delegate = self
        cropViewController.modalTransitionStyle = .crossDissolve
        cropViewController.isPresented = true
        
        
        
       // cropViewController.definesPresentationContext = true
     //   AppDelegate.sharedInstance.navigationController?.presentView(cropViewController, animated: true)
      //  self.navigationController?.presentView(cropViewController, animated: true)
//       v.assetViewContainer.addSubview(cropViewController.view)
     //   self.pushView(cropViewController, animated: true)
        
    //    UIApplication.shared.keyWindow?.rootViewController?.navigationController?.presentedViewController?.present(cropViewController, animated: true, completion: nil)
        
        let navigationController = UINavigationController(rootViewController: cropViewController)
                
        // Present View "Modally"
        self.present(navigationController, animated: true, completion: nil)
        
        */

    }
    @objc func cancel() {
        didCancel?()
        
     
    }
    
    @objc func save() {
        guard let didSave = didSave else {
            return ypLog("Don't have saveCallback")
        }
        
        self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader

        DispatchQueue.global().async {
            if let f = self.selectedFilter,
                let applier = f.applier,
                let ciImage = self.inputPhoto.originalImage.toCIImage(),
                let modifiedFullSizeImage = applier(ciImage) {
                self.inputPhoto.modifiedImage = modifiedFullSizeImage.toUIImage()
            } else {
                self.inputPhoto.modifiedImage = nil
            }
            DispatchQueue.main.async {
                didSave(YPMediaItem.photo(p: self.inputPhoto))
                self.setupRightBarButton()
            }
        }
    }
    
    
//    
//    open override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = false
//
//    }
//    
    
//    open override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        if let top = self.presentedViewController as? UINavigationController,
//           let editor = top.viewControllers.first as? LFPhotoEditingController {
//            editor.delegate = self
//            print("Reassigned delegate inside viewDidAppear")
//        }
//    }

    @objc private func editPhoto() {
            
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let editor = LFPhotoEditingController()
            editor.delegate = self                      // must be set
            editor.editImage = self.inputPhoto.originalImage

            // UI customization
            editor.menuBackColor = CustomColor.sharedInstance.newThemeColor
            editor.headerBackColor = CustomColor.sharedInstance.newThemeColor
            editor.cancelButtonTitleColorNormal = .label
            editor.oKButtonTitleColorNormal = .label
            editor.headerTitle = "Photo Editing"
            editor.titleTextColor = .label

            // Wrap INSIDE UINavigationController (mandatory)
            let nav = UINavigationController(rootViewController: editor)
            nav.modalPresentationStyle = .fullScreen

            // Hide navigation bar because it blocks the editor's own header buttons
            nav.setNavigationBarHidden(true, animated: false)

            self.present(nav, animated: true)
        }

     /*   DispatchQueue.main.async {
            let lfPhotoEditVC = LFPhotoEditingController()
            lfPhotoEditVC.delegate = self;
            
           // lfPhotoEditVC.minClippingDuration = 5.0;
            lfPhotoEditVC.menuBackColor = CustomColor.sharedInstance.newThemeColor //systemBackground
            lfPhotoEditVC.headerBackColor = CustomColor.sharedInstance.newThemeColor //UIColor.systemBackground
            lfPhotoEditVC.cancelButtonTitleColorNormal = UIColor.label
            lfPhotoEditVC.oKButtonTitleColorNormal = UIColor.label
            lfPhotoEditVC.headerTitle = "Photo Editing"
            lfPhotoEditVC.titleTextColor = UIColor.label
            //lfVideoEditVC.hedaderFont =  [UIFont fontWithName:FONT_BOLD size:18];
            lfPhotoEditVC.editImage = self.inputPhoto.originalImage
            
           // lfPhotoEditVC.setVideoURL(self.inputPhoto.url, placeholderImage: self.inputPhoto.image)
            self.navigationController?.isNavigationBarHidden = true
          self.navigationController?.pushViewController(lfPhotoEditVC, animated: true)
            
           // self.navigationController?.isNavigationBarHidden = true
//            let navigationController = UINavigationController(rootViewController: lfPhotoEditVC)
//            navigationController.modalPresentationStyle = .fullScreen
//            navigationController.setNavigationBarHidden(true, animated: true)
//            // Present View "Modally"
//            self.present(navigationController, animated: true, completion: nil)
            
        }
        */
    }
}


extension YPPhotoFiltersVC:LFPhotoEditingControllerDelegate{
   
    public func lf_PhotoEditingController(_ photoEditingVC: LFPhotoEditingController!, didCancel photoEdit: LFPhotoEdit!) {
        
        photoEditingVC.dismiss(animated: true, completion: nil)
    }
    
    public func lf_PhotoEditingController(_ photoEditingVC: LFPhotoEditingController!, didFinish photoEdit: LFPhotoEdit!) {

        // Always dismiss safely
               photoEditingVC.dismiss(animated: true)

               // If photoEdit is nil → user didn’t modify anything
               guard let edit = photoEdit else {
                   print("No edits applied, photoEdit is nil")
                   return
               }

               // Now safely access editedImage
               if let editedImage = edit.editPreviewImage {
                   print("Received edited image")
                   // Use editedImage
                   self.inputPhoto.originalImage = editedImage
                   self.v.imageView.image = editedImage
                   self.v.imageView.currentImage = editedImage
                   self.inputPhoto.modifiedImage  = editedImage
                   self.currentlySelectedImageThumbnail = editedImage
               } else {
                   print("Edited image missing")
               }

    }
    
    
    
}
/*extension YPPhotoFiltersVC: LFPhotoEditingControllerDelegate {

    public func lf_PhotoEditingController(_ photoEditingVC: LFPhotoEditingController!, didCancel photoEdit: LFPhotoEdit!) {
        // Handle Cancel
        photoEditingVC.dismiss(animated: true, completion: nil)
    }

    public func lf_PhotoEditingController(_ photoEditingVC: LFPhotoEditingController!, didFinish photoEdit: LFPhotoEdit!) {
        // Handle Finished Edited Image
        
        if let editedImage = photoEdit.editImage {
            // Use your edited image here
            print("Edited Image Received")
            self.v.imageView.image = editedImage

        }

        photoEditingVC.dismiss(animated: true, completion: nil)
    }
}

*/

extension YPPhotoFiltersVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredThumbnailImagesArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filter = filters[indexPath.row]
        let image = filteredThumbnailImagesArray[indexPath.row]
        if let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "FilterCell",
                                 for: indexPath) as? YPFilterCollectionViewCell {
            cell.name.text = filter.name
            cell.imageView.image = image
            return cell
        }
        return UICollectionViewCell()
    }
}

extension YPPhotoFiltersVC: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        currentlySelectedImageThumbnail = filteredThumbnailImagesArray[indexPath.row]
        self.v.imageView.image = currentlySelectedImageThumbnail
    }
}


extension YPPhotoFiltersVC : CropViewControllerDelegate{
    
    public func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        
    }
    
    public func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
        
    }
    
    public func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
        
    }
    
    
    public func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        currentlySelectedImageThumbnail = cropped
        self.inputPhoto.originalImage = cropped
        self.inputPhoto.modifiedImage = cropped
        self.v.imageView.image = cropped
        v.imageView.image = cropped
        thumbnailImageForFiltering = thumbFromImage(cropped)
        
        DispatchQueue.global().async {
            self.filteredThumbnailImagesArray = self.filters.map { filter -> UIImage in
                if let applier = filter.applier,
                    let thumbnailImage = self.thumbnailImageForFiltering,
                    let outputImage = applier(thumbnailImage) {
                    return outputImage.toUIImage()
                } else {
                    return self.inputPhoto.originalImage
                }
            }
            DispatchQueue.main.async {
                self.v.collectionView.reloadData()
                self.v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                            animated: false,
                                            scrollPosition: UICollectionView.ScrollPosition.bottom)
                self.v.filtersLoader.stopAnimating()
            }
            
        }
    }
    
    public func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        
    }
    
    func didGetCroppedImage(image: UIImage) {
        self.v.imageView.image = image

    }

    
    //MARK: APi Methods
    
    func uploadMediaToserver(index:Int){
   
    }
}
