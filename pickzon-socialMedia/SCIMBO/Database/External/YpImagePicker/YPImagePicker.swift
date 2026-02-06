//
//  YPImagePicker.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


public protocol YPImagePickerDelegate: AnyObject {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker)
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool
}

open class YPImagePicker: UINavigationController {
    public typealias DidFinishPickingCompletion = (_ items: [YPMediaItem], _ cancelled: Bool) -> Void

    // MARK: - Public

    public weak var imagePickerDelegate: YPImagePickerDelegate?
    public func didFinishPicking(completion: @escaping DidFinishPickingCompletion) {
        _didFinishPicking = completion
    }

    /// Get a YPImagePicker instance with the default configuration.
    public convenience init() {
        self.init(configuration: YPImagePickerConfiguration.shared)
    }

    private var selectedPhoto:YPMediaItem?
    
    open var isFromFeedPost = false
    /// Get a YPImagePicker with the specified configuration.
    public required init(configuration: YPImagePickerConfiguration) {
        YPImagePickerConfiguration.shared = configuration
        picker = YPPickerVC()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen // Force .fullScreen as iOS 13 now shows modals as cards by default.
        picker.pickerVCDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return YPImagePickerConfiguration.shared.preferredStatusBarStyle
    }

    // MARK: - Private

    private var _didFinishPicking: DidFinishPickingCompletion?

    // This nifty little trick enables us to call the single version of the callbacks.
    // This keeps the backwards compatibility keeps the api as simple as possible.
    // Multiple selection becomes available as an opt-in.
    private func didSelect(items: [YPMediaItem]) {
        _didFinishPicking?(items, false)
    }
    
    private let loadingView = YPLoadingView()
     let picker: YPPickerVC!

    override open func viewDidLoad() {
        super.viewDidLoad()
        picker.didClose = { [weak self] in
            self?._didFinishPicking?([], true)
        }
        viewControllers = [picker]
        setupLoadingView()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .ypLabel
        view.backgroundColor = .ypSystemBackground

        picker.didSelectItems = { [weak self] items in
            // Use Fade transition instead of default push animation
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            DispatchQueue.main.async {
                self?.view.layer.add(transition, forKey: nil)
            }
            
            
            // Multiple items flow
            if items.count > 1 {
                if YPConfig.library.skipSelectionsGallery {
                    self?.didSelect(items: items)
                    return
                } else {
                    let selectionsGalleryVC = YPSelectionsGalleryVC(items: items) { _, items in
                        self?.didSelect(items: items)
                    }
                    self?.pushViewController(selectionsGalleryVC, animated: true)
                    return
                }
            }
            
            // One item flow
            let item = items.first!
            switch item {
            case .photo(let photo):
                let completion = { (photo: YPMediaPhoto) in
                    let mediaItem = YPMediaItem.photo(p: photo)
                    // Save new image or existing but modified, to the photo album.
                    if YPConfig.shouldSaveNewPicturesToAlbum {
                        let isModified = photo.modifiedImage != nil
                        if photo.fromCamera || (!photo.fromCamera && isModified) {
                            YPPhotoSaver.trySaveImage(photo.image, inAlbumNamed: YPConfig.albumName)
                        }
                    }
                    self?.didSelect(items: [mediaItem])
                }
                
                func showCropVC(photo: YPMediaPhoto, completion: @escaping (_ aphoto: YPMediaPhoto) -> Void) {
                    switch YPConfig.showsCrop {
                    case .rectangle, .circle:
                        let cropVC = YPCropVC(image: photo.image)
                        cropVC.didFinishCropping = { croppedImage in
                            photo.modifiedImage = croppedImage
                            completion(photo)
                        }
                        self?.pushViewController(cropVC, animated: true)
                    default:
                        completion(photo)
                    }
                }
                
              /*  if YPConfig.showsPhotoFilters {
                    let filterVC = YPPhotoFiltersVC(inputPhoto: photo,
                                                    isFromSelectionVC: false)
                    // Show filters and then crop
                    filterVC.didSave = { outputMedia in
                        if case let YPMediaItem.photo(outputPhoto) = outputMedia {
                            showCropVC(photo: outputPhoto, completion: completion)
                        }
                    }
                    self?.pushViewController(filterVC, animated: false)
                } else {
                    showCropVC(photo: photo, completion: completion)
                }
                */
                self?.selectedPhoto = item
                self?.editPhoto(image:  photo.image)
                
                
            case .video(let video):
                let asset = AVAsset(url: video.url)
                let seconds = CMTimeGetSeconds(asset.duration)
                DispatchQueue.main.async {
                    self?.picker.videoVC?.v.shotButton.isHidden = false
                }
                
                if seconds < 3.0 {
                    self?.picker.videoVC?.videoHelper.removeLoader()

                    let alert = UIAlertController(title: "PickZon", message: "Video length must be  at least 3 seconds duration.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                        }))
                    self?.present(alert, animated: true, completion: nil)
                    return
                }else  if YPConfig.showsVideoTrimmer {
                    DispatchQueue.main.async {
                        self?.picker.videoVC?.videoHelper.removeLoader()
                        var videoFiltersVC = YPVideoFiltersVC.initWith(video: video,
                                                                       isFromSelectionVC: false)
                        videoFiltersVC.isfromFeedPost = self?.isFromFeedPost ?? false
                        videoFiltersVC.coverBottomItem.isHidden(value: false)
                        
                        videoFiltersVC.didSave = { [weak self] outputMedia in
                            self?.didSelect(items: [outputMedia])
                        }
                        self?.pushViewController(videoFiltersVC, animated: true)
                    }
                } else {
                    self?.didSelect(items: [YPMediaItem.video(v: video)])
                }
                        
                
            }
        }
    }
    
    deinit {
        ypLog("Picker deinited 👍")
    }
    
    private func setupLoadingView() {
        view.sv(
            loadingView
        )
        loadingView.fillContainer()
        loadingView.alpha = 0
    }
}



extension YPImagePicker: YPPickerVCDelegate {
  
    func libraryHasNoItems() {
        self.imagePickerDelegate?.imagePickerHasNoItemsInLibrary(self)
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        print("numSelections \(numSelections)")
        return self.imagePickerDelegate?.shouldAddToSelection(indexPath: indexPath, numSelections: numSelections)
        ?? true
        
    }
}



extension YPImagePicker:LFPhotoEditingControllerDelegate{
    
    @objc private func editPhoto(image:UIImage) {
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let editor = LFPhotoEditingController()
            editor.delegate = self                      // must be set
            editor.editImage = image
            
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
    }
    public func lf_PhotoEditingController(_ photoEditingVC: LFPhotoEditingController!, didCancel photoEdit: LFPhotoEdit!) {
        
        photoEditingVC.dismiss(animated: true, completion: nil)
    }
    
    public func lf_PhotoEditingController(_ photoEditingVC: LFPhotoEditingController!, didFinish photoEdit: LFPhotoEdit!) {
        
        // Always dismiss safely
        photoEditingVC.dismiss(animated: false) {
            
            // If photoEdit is nil → user didn’t modify anything
            guard let edit = photoEdit else {
                print("No edits applied, photoEdit is nil")
                
                if let item = self.selectedPhoto{
                    
                    switch item {
                    case .photo(let selectedPhoto):
                        // assign edited image
                        
                        // After updating → trigger YP callback
                        // Wrap back into YPMediaItem
                              let updatedMediaItem = YPMediaItem.photo(p: selectedPhoto)
                              
                              // Send it back to picker flow
                              self.didSelect(items: [updatedMediaItem])

                        
                    case .video:
                        print("Video, ignoring edited image")
                    }
                }

                return
            }
            
            // Now safely access editedImage
            if let editedImage = edit.editPreviewImage {
                print("Received edited image")
                // Use editedImage
                
                
                if let item = self.selectedPhoto{
                    
                    switch item {
                    case .photo(let selectedPhoto):
                        // assign edited image
                        
                        selectedPhoto.modifiedImage = editedImage
                        selectedPhoto.originalImage = editedImage
                        
                        // After updating → trigger YP callback
                        // Wrap back into YPMediaItem
                              let updatedMediaItem = YPMediaItem.photo(p: selectedPhoto)
                              
                              // Send it back to picker flow
                              self.didSelect(items: [updatedMediaItem])

                        
                    case .video:
                        print("Video, ignoring edited image")
                    }
                }       // take out
                
                
            } else {
                print("Edited image missing")
            }
            
        }

      //  photoEditingVC.dismiss(animated: true)

    }
    
}

