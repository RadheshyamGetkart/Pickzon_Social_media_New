//
//  PhotoPreviewViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/15/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class PhotoPreviewViewController: UIViewController {
    @IBOutlet weak var imgPreview:UIImageView!
    
    
    var takenPhoto :UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = takenPhoto {
            imgPreview.image = availableImage
        }
        
      
        imgPreview.isUserInteractionEnabled = true
        let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(sender:)))
        imgPreview.addGestureRecognizer(pinchMethod)
        
    }
    
   
    
    
    

    @objc func pinchImage(sender: UIPinchGestureRecognizer) {
      
    if let scale = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)) {
      guard scale.a > 1.0 else { return }
      guard scale.d > 1.0 else { return }
      sender.view?.transform = scale
      sender.scale = 1.0
     }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
