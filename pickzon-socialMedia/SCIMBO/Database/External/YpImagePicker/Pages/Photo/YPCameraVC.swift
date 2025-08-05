//
//  YPCameraVC.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

internal final class YPCameraVC: UIViewController, UIGestureRecognizerDelegate, YPPermissionCheckable {
    var didCapturePhoto: ((UIImage) -> Void)?
    let v: YPCameraView!

    private let photoCapture = YPPhotoCaptureHelper()
    private var isInited = false
    private var videoZoomFactor: CGFloat = 1.0
  //  let filtersdfdsfBgview = UIView()

    override internal func loadView() {
        view = v
    }

    internal required init() {
        self.v = YPCameraView(overlayView: YPConfig.overlayView)
        super.init(nibName: nil, bundle: nil)

        title = YPConfig.wordings.cameraTitle
        navigationController?.navigationBar.setTitleFont(font: YPConfig.fonts.navigationBarTitleFont)
        
        YPDeviceOrientationHelper.shared.startDeviceOrientationNotifier { _ in }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        YPDeviceOrientationHelper.shared.stopDeviceOrientationNotifier()

        photoCapture.cameraController?.deepAR.shutdown()
        if  photoCapture.deepAR == nil {
            
        }else{
            photoCapture.deepAR?.shutdown()
//            photoCapture.deepAR = nil
//            photoCapture.cameraController = nil
        }
        
        self.v.shotButton.isHidden = false
        self.v.filterBgview.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.v.addSongButton.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if  photoCapture.deepAR == nil {
            
        }else{
            photoCapture.deepAR?.shutdown()
            //             videoHelper.deepAR = nil
            //             videoHelper.cameraController = nil
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if  photoCapture.deepAR == nil {
            
        }else{
            photoCapture.deepAR?.shutdown()
            //             videoHelper.deepAR = nil
            //             videoHelper.cameraController = nil
            
        }
    }
    
    
    override internal func viewDidLoad() {
        super.viewDidLoad()

        v.flashButton.isHidden = true
        v.flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        v.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        v.flipButton.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)
        v.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)

        // Prevent flip and shot button clicked at the same time
        v.shotButton.isExclusiveTouch = true
        v.flipButton.isExclusiveTouch = true
        
        // Focus
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.focusTapped(_:)))
        tapRecognizer.delegate = self
        v.previewViewContainer.addGestureRecognizer(tapRecognizer)
        
        // Zoom
        let pinchRecongizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(_:)))
        pinchRecongizer.delegate = self
        v.previewViewContainer.addGestureRecognizer(pinchRecongizer)
        
        initializeFilterView()
        
      
        
    }
    
    
    func initializeFilterView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 88, height: 94)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        v.filterCollectionView.collectionViewLayout = layout
        v.filterCollectionView.delegate = self
        v.filterCollectionView.dataSource = self
        v.filterCollectionView.register(UINib(nibName: "FilterCVCell", bundle: nil), forCellWithReuseIdentifier: "FilterCVCell")
        v.filterBgview.isHidden = true
        v.filterCollectionView.isExclusiveTouch = true
    }
    
    
    private  func getFilterListAPI(){
         
         Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
          let url =  "\(Constant.sharedinstance.getFiltersURL)"
          
          
          URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
              DispatchQueue.main.async {
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
              }
              
              if(error != nil)
              {
                  DispatchQueue.main.async {
                      self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                      print(error ?? "defaultValue")
                  }
              }else{
                  
                  let result = responseObject! as NSDictionary
                  let status = result["status"] as? Int ?? 0
                  let message = result["message"] as? String ?? ""
                  if status == 1 {
                      
                      if let data = result["payload"] as? NSArray {
                          for obj in data {
                              let objFilterEffect = FilterEffects(dict: obj as! Dictionary<String,Any>)
                              Constant.sharedinstance.arrFilterEffect.append(objFilterEffect)
                          }
                          self.v.filterBgview.isHidden = false
                          self.v.shotButton.isHidden = true
                          self.v.filterCollectionView.reloadData()
                      }
                      
                  } else  {
                      DispatchQueue.main.async {
                          self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                      }
                      
                  }
                  
                  
              }
          })
          
      }
      
      // MARK: - Flip Camera
      
      @objc
      func filterButtonTapped() {
          print("filterButtonTapped")
          
          if Constant.sharedinstance.arrFilterEffect.count == 0 {
              self.getFilterListAPI()
              
          }else {
              v.filterBgview.isHidden = v.filterBgview.isHidden==true ? false : true
              v.filterCollectionView.reloadData()
          }
          
          if  v.filterBgview.isHidden == true {
              self.v.shotButton.isHidden = false
          }else{
              self.v.shotButton.isHidden = true
          }
      }
    
    func start() {
        
            if  self.photoCapture.deepAR == nil {
                
            }else{
               // self.photoCapture.deepAR?.shutdown()
              //  self.photoCapture.deepAR = nil
                //self.photoCapture.cameraController = nil
                self.photoCapture.deepAR?.resume()
            }
        
        doAfterCameraPermissionCheck { [weak self] in
            guard let previewContainer = self?.v.previewViewContainer else {
                return
            }

            self?.photoCapture.start(with: previewContainer, completion: {
                DispatchQueue.main.async {
                    self?.isInited = true
                    self?.updateFlashButtonUI()
                }
            })
        }
    }

    @objc
    func focusTapped(_ recognizer: UITapGestureRecognizer) {
        self.v.filterBgview.isHidden = true
        self.v.shotButton.isHidden = false

        guard isInited else {
            return
        }
        
        self.focus(recognizer: recognizer)
    }
    
    func focus(recognizer: UITapGestureRecognizer) {

        let point = recognizer.location(in: v.previewViewContainer)
        
        // Focus the capture
        let viewsize = v.previewViewContainer.bounds.size
        let newPoint = CGPoint(x: point.x/viewsize.width, y: point.y/viewsize.height)
        photoCapture.focus(on: newPoint)
        
        // Animate focus view
        v.focusView.center = point
        YPHelper.configureFocusView(v.focusView)
        v.addSubview(v.focusView)
        YPHelper.animateFocusView(v.focusView)
    }
    
    @objc
    func pinch(_ recognizer: UIPinchGestureRecognizer) {
        guard isInited else {
            return
        }
        
        self.zoom(recognizer: recognizer)
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        photoCapture.zoom(began: recognizer.state == .began, scale: recognizer.scale)
    }

    func stopCamera() {
        
        photoCapture.stopCamera()
    }
    
    @objc
    func flipButtonTapped() {
        self.photoCapture.flipCamera {
            self.updateFlashButtonUI()
        }
    }
    
    @objc
    func shotButtonTapped() {
        doAfterCameraPermissionCheck { [weak self] in
            self?.shoot()
        }
    }
    
    func shoot() {
        // Prevent from tapping multiple times in a row
        // causing a crash
        v.shotButton.isEnabled = false

        photoCapture.shoot { imageData in
            
            guard let shotImage = UIImage(data: imageData) else {
                return
            }
            
            self.photoCapture.stopCamera()
            
            var image = shotImage
            // Crop the image if the output needs to be square.
            if YPConfig.onlySquareImagesFromCamera {
                image = self.cropImageToSquare(image)
            }

            // Flip image if taken form the front camera.
            if let device = self.photoCapture.device, device.position == .front {
                image = self.flipImage(image: image)
            }
            
            let noOrietationImage = image.resetOrientation()
            
            DispatchQueue.main.async {
                self.didCapturePhoto?(noOrietationImage.resizedImageIfNeeded())
            }
        }
    }
    
    func cropImageToSquare(_ image: UIImage) -> UIImage {
        let orientation: UIDeviceOrientation = YPDeviceOrientationHelper.shared.currentDeviceOrientation
        var imageWidth = image.size.width
        var imageHeight = image.size.height
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            // Swap width and height if orientation is landscape
            imageWidth = image.size.height
            imageHeight = image.size.width
        default:
            break
        }
        
        // The center coordinate along Y axis
        let rcy = imageHeight * 0.5
        let rect = CGRect(x: rcy - imageWidth * 0.5, y: 0, width: imageWidth, height: imageWidth)
        let imageRef = image.cgImage?.cropping(to: rect)
        return UIImage(cgImage: imageRef!, scale: 1.0, orientation: image.imageOrientation)
    }
    
    // Used when image is taken from the front camera.
    func flipImage(image: UIImage!) -> UIImage! {
        let imageSize: CGSize = image.size
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.rotate(by: CGFloat(Double.pi/2.0))
        ctx.translateBy(x: 0, y: -imageSize.width)
        ctx.scaleBy(x: imageSize.height/imageSize.width, y: imageSize.width/imageSize.height)
        ctx.draw(image.cgImage!, in: CGRect(x: 0.0,
                                            y: 0.0,
                                            width: imageSize.width,
                                            height: imageSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @objc
    func flashButtonTapped() {
        photoCapture.device?.tryToggleTorch()
        updateFlashButtonUI()
    }
    
    func updateFlashButtonUI() {
        DispatchQueue.main.async {
            let flashImage = self.photoCapture.currentFlashMode.flashImage()
            self.v.flashButton.setImage(flashImage, for: .normal)
            self.v.flashButton.isHidden = !self.photoCapture.hasFlash
        }
    }
}

extension YPCameraVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width:100, height: 95)
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
            photoCapture.deepAR?.switchEffect(withSlot: "effect", path: nil)
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
                    self.photoCapture.deepAR?.switchEffect(withSlot: "effect", path: path)
                }
            }
        }
    }
    
}
