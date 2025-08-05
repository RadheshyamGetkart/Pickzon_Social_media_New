//
//  NotificationViewController.swift
//  Content
//
//  Created by gurmukh singh on 4/28/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI



class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label:UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func didReceive(_ notification: UNNotification) {
        print("HHHH--------")
        let content = notification.request.content
        
        if let urlImageString = content.userInfo["media"] as? String {
            if let url = URL(string: urlImageString) {
                URLSession.downloadImage(atURL: url) { [weak self] (data, error) in
                    if let _ = error {
                        return
                    }
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        
          
    }
    
}

extension URLSession {
    
    class func downloadImage(atURL url: URL, withCompletionHandler completionHandler: @escaping (Data?, NSError?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            completionHandler(data, nil)
        }
        dataTask.resume()
    }
}

