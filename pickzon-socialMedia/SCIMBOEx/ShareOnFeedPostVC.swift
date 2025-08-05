//
//  ShareOnFeedPostVC.swift
//  SCIMBOEx
//
//  Created by gurmukh singh on 9/30/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import GrowingTextView
import MobileCoreServices
import Social
import SDWebImage
import CoreData
import CoreServices
import Photos
import Alamofire


class ShareOnFeedPostVC: UIViewController, UITextViewDelegate {
   
    var arrData = Array<Data>()
    var urlSelectedItemsArray = Array<String>()
    var sharedText = ""
    
    var sharedFilesURLArray = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
             //Note currently share extension allows only 5-6 MB of data to transfer.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            
            self.fetchFiles{ success, assets in
                
                print("++++++++ HHHH",success, assets)
                if success == true {
                    self.addNewPostAction()
                }else {
                    self.dismiss()
                }
            }
           
            
        })
            
        
    }

    
    func dismiss() {
        UIView.animate(withDuration: 0.20, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        }) { finished in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    
    @objc func openURL(_ url: URL) -> Bool {
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    return application.perform(#selector(openURL(_:)), with: url) != nil
                }
                responder = responder?.next
            }
            return false
        }
    
    func getCompressedData(completion : @escaping(_ success : Bool) -> ()){
        
        
            
            for index in 0...self.urlSelectedItemsArray.count - 1 {
                let url = URL (fileURLWithPath: self.urlSelectedItemsArray[index])
                print("Size before Compression",url.sizePerMB())
                if checkMediaTypes(strUrl:url.absoluteString) == 3 {
                    
                    
                    FYVideoCompressor().compressVideo(url, quality: .highQuality) { result in
                        switch result {
                        case .success(let compressedVideoURL):
                            if let data = try? Data(contentsOf: compressedVideoURL) {
                                do {
                                    print("Size before Compression",compressedVideoURL.sizePerMB())
                                    //data limit to sharing is 4 MB
                                   
                                        self.arrData.append(data)
                                        print("saved Success")
                                    
                                    do {
                                        try FileManager.default.removeItem(at: compressedVideoURL)
                                    } catch {
                                     // Catch any errors
                                     print("Unable to read the file")
                                    }
                                        
                                        if self.arrData.count == self.urlSelectedItemsArray.count {
                                        completion(true)
                                    }
                                    
                                    
                                } catch {
                                    print("error saving file to documents:", error)
                                }
                            }
                            break
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }
                }else if checkMediaTypes(strUrl:url.absoluteString) == 1 {
                    if let image = UIImage(contentsOfFile: url.path) {
                        let data = image.jpegData(compressionQuality: 0.8) ?? Data()
                        //data limit to sharing is 4 MB
                       
                            self.arrData.append(data)
                            if self.arrData.count == self.urlSelectedItemsArray.count {
                                completion(true)
                            }
                        
                    }
                    
                }
                
                
            }
            
        
        
    }
    @IBAction func addNewPostAction(){
        Themes.sharedInstance.removeallSharedObjects()
        
        if self.sharedText.length > 0  {
            Themes.sharedInstance.saveSharedText(text: self.sharedText)
            guard let url = URL.init(string: "pickzon://")
            else { return }
            self.openURL(url)
            self.dismiss()
        }else {
            self.getCompressedData{ success in
                if success == true {
                     
                    self.savefileinDocumentDirectory()
                    Themes.sharedInstance.saveSharedFilesURLArray(urlArray: self.sharedFilesURLArray)
                    
                    
                    guard let url = URL.init(string: "pickzon://")
                    else { return }
                    self.openURL(url)
                    self.dismiss()
                }else {
                    self.dismiss()
                }
                
            }
            
        }
            
    }
   
    func savefileinDocumentDirectory(){
        let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.NHBQDLLJN4.com.PickZonGroup")
        
        
        for index in 0...self.urlSelectedItemsArray.count - 1 {
            let url = URL (fileURLWithPath: self.urlSelectedItemsArray[index])
            let fileName = url.lastPathComponent
            if let fileURL = documentsDirectory?.appendingPathComponent("\(fileName)"){
                let data = arrData[index]
                // Save the data
                do {
                    try data.write(to: fileURL)
                    print("File saved: \(fileURL.absoluteURL)")
                    self.sharedFilesURLArray.append(fileURL.absoluteString)
                } catch {
                    // Catch any errors
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    
   
    
    
     
    
    func fetchFiles(completion : @escaping(_ success : Bool, _ urls : [[String : Any]]) -> ()){
        var AssetURLs = [[String : Any]]()
        _ = self.extensionContext?.inputItems.map {
            let content = $0 as! NSExtensionItem
           // var  contentType = kUTTypeImage as String
            var  contentType = ""
            
            if #available(iOSApplicationExtension 14.0, *) {
                  contentType = UTType.image.identifier
            } else {
                // Fallback on earlier versions
                contentType = kUTTypeImage as String
            }
            
            //let contentTypeMovie = kUTTypeMovie as String
            // let contentTypeVideo = kUTTypeVideo as String
            // let contentTypeUrl = kUTTypeURL as String
            
            var contentTypeMovie = ""
            var contentTypeVideo = ""
            var contentTypeQuickTimeMovie = ""
            var contentTypeMpeg = ""
            var contenttypeMpeg2Video = ""
            
            var contentTypeText = ""
            var  contentTypeUrl = ""
            if #available(iOSApplicationExtension 15.0, *) {
                contentTypeMovie = UTType.movie.identifier
                contentTypeVideo = UTType.video.identifier
                contentTypeQuickTimeMovie = UTType.quickTimeMovie.identifier
                contentTypeMpeg = UTType.mpeg.identifier
                contenttypeMpeg2Video = UTType.mpeg2Video.identifier
                
                contentTypeText = UTType.text.identifier
                contentTypeUrl = UTType.url.identifier
            }else {
                contentTypeMovie = kUTTypeMovie as String
                contentTypeVideo = kUTTypeVideo as String
                contentTypeQuickTimeMovie = kUTTypeQuickTimeMovie as String
                contentTypeMpeg = kUTTypeMPEG as String
                contenttypeMpeg2Video = kUTTypeMPEG2Video as String
                
                contentTypeText = kUTTypeText as String
                contentTypeUrl = kUTTypeURL as String
            }
            
           
            
            
            
            
            
            
            let contentTypeFile = kUTTypeFileURL as String
            let contentTypeAudio = kUTTypeMP3 as String
           
            
            for attachment in content.attachments as! [NSItemProvider] {
                var index = 0
                if let array = content.attachments as NSArray? {
                    index = array.index(of: attachment)
                }
                if attachment.hasItemConformingToTypeIdentifier(contentType) {
                    
                    attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in
                       
                        
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "1"] as [String : Any]
                                AssetURLs.append(dict)
                                self.urlSelectedItemsArray.append(url.path)
                                
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                            else if let image = data as? UIImage {
                                let dict = ["url" : image, "type" : "1"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                }
                else if attachment.hasItemConformingToTypeIdentifier(contentTypeMovie)  {
                    attachment.loadItem(forTypeIdentifier: contentTypeMovie, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                self.urlSelectedItemsArray.append(url.path)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
            
                }else if  attachment.hasItemConformingToTypeIdentifier(contentTypeVideo) {
                    attachment.loadItem(forTypeIdentifier: contentTypeVideo, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                self.urlSelectedItemsArray.append(url.path)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                    
                }else if  attachment.hasItemConformingToTypeIdentifier(contentTypeQuickTimeMovie) {
                    attachment.loadItem(forTypeIdentifier: contentTypeQuickTimeMovie, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                self.urlSelectedItemsArray.append(url.path)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                    
                }else if  attachment.hasItemConformingToTypeIdentifier(contentTypeMpeg) {
                    attachment.loadItem(forTypeIdentifier: contentTypeMpeg, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                self.urlSelectedItemsArray.append(url.path)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                    
                }else if  attachment.hasItemConformingToTypeIdentifier(contenttypeMpeg2Video) {
                    attachment.loadItem(forTypeIdentifier: contenttypeMpeg2Video, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                self.urlSelectedItemsArray.append(url.path)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                    
                } else if  attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                    attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil) { data, error in
                        if error == nil {
                            if let text = data as? String {
                                let dict = ["url" : "", "type" : ""] as [String : Any]
                                AssetURLs.append(dict)
                                self.sharedText = text
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                    
                }else if  attachment.hasItemConformingToTypeIdentifier(contentTypeUrl) {
                    attachment.loadItem(forTypeIdentifier: contentTypeUrl, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                self.sharedText = url.absoluteString
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                               
                            }
                        }
                    }
                    
                }
                else {
                    //self.inValid()
                    
                   
                    
                    completion(false, [])
                }
            }
        }
    }
    
    
    
   
    
    
    
    
    //MARK:- UICollectionview delegate and datasource
    
    
    
    
   
    
   

//MARK: UITextview Delegate

func textViewDidEndEditing(_ textView: UITextView) {
    
    
    
}

func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
   
    return true
}

}




public func checkMediaTypes(strUrl:String)->Int{
    
    let imageExtension = ["png","gif","jpg","jpeg","raw","tiff","bmp","webp","heif","jfif"]
    let documentExtension = ["pdf","doc","docx","xls","xlsx","txt","html","htm","psd","ppt","pptx","odp","data"]
    let videoExtension = ["mp4","avi","mov","flv","avchd","webm"]
    let audioExtension = ["m4a","wav","mp3"]
    let svgaExtension = ["svg","svga"]
    
    if let objUrl = strUrl as? NSString{
        
        if imageExtension.contains(objUrl.pathExtension.lowercased()){
            //Image
            return 1
        }else if documentExtension.contains(objUrl.pathExtension.lowercased()){
            //Document
            return 2
        }else if videoExtension.contains(objUrl.pathExtension.lowercased()){
            //video
            return 3
        }else if audioExtension.contains(objUrl.pathExtension.lowercased()){
            //Audio
            return 4
        }else if svgaExtension.contains(objUrl.pathExtension.lowercased()){
            //SVG
            return 5
        }
    }
    return 0
}
