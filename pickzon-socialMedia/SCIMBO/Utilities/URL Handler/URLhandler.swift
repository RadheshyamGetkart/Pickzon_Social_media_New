
//
//  URLhandler.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SystemConfiguration
import SwiftyJSON
import AVKit

protocol URLhandlerDelegate : AnyObject {
    func ReturnDownloadProgress(id: String, Dict: NSDictionary, status: String)
}


class URLhandler: NSObject
{
    
    weak var Delegate:URLhandlerDelegate?
    static let sharedinstance:URLhandler = {
        let urlhandler = URLhandler()
        urlhandler.ImageCache.countLimit = 1000
        urlhandler.ImageCache.totalCostLimit = 1024 * 1024 * 512 //500 MB
        AF.sessionConfiguration.timeoutIntervalForRequest = 700 // 300
        AF.sessionConfiguration.timeoutIntervalForResource = 700
        

        return urlhandler
    }()
    
    var Dictionary:NSDictionary!=NSDictionary()
    var RetryValue:NSInteger!=3
    var ImageCache = NSCache<AnyObject, AnyObject>()
    var queue = OperationQueue()
    var isUploadingNewPost = false
    func isConnectedToNetwork() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    
    private func getHeaders() -> HTTPHeaders {
        let userName = "AC5146d45b8c2dd1a1395a0fc077b5327d"
        let password = "b8cd524960073ffc8b03e5dccba7b1f7"
        return HTTPHeaders.init([HTTPHeader.authorization(username: userName, password: password)])
    }
    
    
    func MakeOTPCall(_ OTP: String,To:String, completion: ((_ response: JSON?, _ error: Error?) -> Void)?) {
        let ACCOUNT_SID = "AC5146d45b8c2dd1a1395a0fc077b5327d"
        let AUTH_TOKEN = "b8cd524960073ffc8b03e5dccba7b1f7"
        let request =  "https://\(ACCOUNT_SID):\(AUTH_TOKEN)@api.twilio.com/2010-04-01/Accounts/\(ACCOUNT_SID)/SMS/Messages"
        let url = "https://api.twilio.com/2010-04-01/Accounts/\(ACCOUNT_SID)/Messages"
        var parameters = [String:String]()
        parameters =  ["To": To,
                       "From" : "+15713483621",
                       "Body" : "Your PickZon OTP is :\(OTP)"
        ]
        if ISDEBUG == true{
            print("Url: ", url)
            print("Param: ",parameters)
        }
        
        
        
        AF.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: getHeaders())
            .responseJSON { (response) in
                
                switch response.result {
                case .success( _):
                    print(response.request ?? "request")  // original URL request
                    print(response.response ?? "") // URL response
                    print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    
                    let json = JSON(response.data ?? Data())
                    
                    DispatchQueue.main.async {
                        completion?(json, nil)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion?(nil,error)
                    }
                }
            }
    }
    
    
    func makeCall(url: String,param:NSDictionary,methodType: HTTPMethod = .post, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
            AppDelegate.sharedInstance.Logout()
            return
        }
        
        if ISDEBUG == true{
            print("Url: ", url)
            print("Param: ",param)
        }
        
        if isConnectedToNetwork() == true {
            
            AF.request("\(url)", method: methodType, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: self.getHeaderFields())
                
                .responseJSON { response in
                    
                    self.Dictionary = [:]
                    switch response.result {
                    case .success(_):
                        self.Dictionary = response.value as? NSDictionary
                        if ISDEBUG == true{
                            print("\(url) Response received: ",self.Dictionary)
                        }
                        completionHandler(self.Dictionary as NSDictionary?, nil)
                        
                    case .failure(let error):
                        
                        if ISDEBUG == true {
                        print(response)
                        }
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                    }
                }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
    }
    
    func updateMobileNo(url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        if ISDEBUG == true{
            print("Url:", url)
            print("Param",param)
        }
        if isConnectedToNetwork() == true {
            AF.request("\(url)", method: .post, parameters: param as? Parameters, encoding: URLEncoding(destination: .queryString), headers: self.getHeaderFields())
                .responseJSON { response in
                    switch response.result {
                    case .success( _):
                        do {
                            
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                            if ISDEBUG == true{
                                print("\(url) Response received: ",self.Dictionary)
                            }
                            completionHandler(self.Dictionary as NSDictionary?, nil)
                        }
                        catch let error as NSError {
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error )
                        }
                    case .failure(let error):
                       
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                    }
                }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
    }
    
    
    
    func makeGetCallRootUser(url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ())
    {
        
        if isConnectedToNetwork() == true {
            
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
            
            let timeZone = TimeZone.current.identifier
            var headers = ["passcode" : "[8, 5, 12, 5, 3, 2, 3, 40, 34]", "Content-Type":"application/json","timezone":"\(timeZone)", "appVersion":"\(Themes.sharedInstance.getAppVersion())", "OS":"ios"]
            
            if  Themes.sharedInstance.getAuthToken().length > 0 {
                headers["authToken"] = Themes.sharedInstance.getAuthToken()
            }else {
                headers["authToken"] = ""
            }
         
            let httpHeader = HTTPHeaders.init(headers)

            if ISDEBUG == true{
                print("Url:", url)
                print("Param:",param)
                print("Headers:",headers)
            }
            
            AF.request("\(url)", method: .get,headers:httpHeader).responseJSON { response in
                
                switch response.result {
                case .success( _):
                    do {
                        
                        self.Dictionary = try JSONSerialization.jsonObject(
                            with: response.data!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        if ISDEBUG == true{
                            print("\(url) Response received: ",self.Dictionary)
                        }
                      
                        completionHandler(self.Dictionary as NSDictionary?, nil)
                    }
                    catch let error as NSError {
                        print("A JSON parsing error occurred, here are the details:\n \(error)")
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error )
                    }
                case .failure(let error):
                    if ISDEBUG == true {
                    print(response)
                    }
                    
                    self.Dictionary=nil
                    completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                    print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                }
                
                
            }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
    }
    
    func getHeaderFields(isFormData:Bool=false)->HTTPHeaders {
        
       let timeZone = TimeZone.current.identifier
        
        var headers = [ "Content-Type":"application/json", "appVersion":"\(Themes.sharedInstance.getAppVersion())", "OS":"ios","timezone":"\(timeZone)"
        ]
        if isFormData{
            headers = [ "Content-Type":"multipart/form-data","Content-Disposition" : "form-data", "appVersion":"\(Themes.sharedInstance.getAppVersion())", "OS":"ios","timezone":"\(timeZone)"
            ]
        }
        
        if  Themes.sharedInstance.getAuthToken().length > 0 {
            headers["authToken"] = Themes.sharedInstance.getAuthToken()
        }
        
        if  Themes.sharedInstance.getSecurityAuthToken().length > 0 {
            headers["securityAuthToken"] = Themes.sharedInstance.getSecurityAuthToken()
        }
        
        headers["Keep-Alive"] = "Connection"

        
        if  Themes.sharedInstance.getBasicAuthorizationUserName().length > 0 {
            let loginString = "\(Themes.sharedInstance.getBasicAuthorizationUserName()):\(Themes.sharedInstance.getBasicAuthorizationPassword())"
            if  let loginData = loginString.data(using: String.Encoding.utf8)  {
                let base64LoginString = loginData.base64EncodedString()
                headers["Authorization"] = "Basic \(base64LoginString)"
            }
            
        }
        
        if  Themes.sharedInstance.getSpotifyToken().length > 0 {
            headers["token"] = Themes.sharedInstance.getSpotifyToken()
        }
        
        //New for coins security by vishwajeet
        headers["cookie"] = Themes.sharedInstance.Getuser_id()



        if ISDEBUG == true {
            print(headers)
        }
        
        return HTTPHeaders.init(headers)
    }
    
    
    func makeGetCall(url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ())
    {
        if ISDEBUG == true{
            print("Url:", url)
            print("Param",param)
        }
        
        if isConnectedToNetwork() == true {
            
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
            
            
            AF.request("\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  ?? "")", method: .get,headers:self.getHeaderFields()).responseJSON { response in
                
                switch response.result {
                case .success( _):
                    do {
                        
                        self.Dictionary = try JSONSerialization.jsonObject(
                            with: response.data!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        if ISDEBUG == true{
                            print("\(url) Response received: ",self.Dictionary)
                        }
                    
                        completionHandler(self.Dictionary as NSDictionary?, nil)
                    }
                    catch let error as NSError {
                        print("A JSON parsing error occurred, here are the details:\n \(error)")
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error )
                    }
                case .failure(let error):
                    if ISDEBUG == true {
                    print(response)
                    }
                   
                    self.Dictionary=nil
                    completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                    print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                }
                
                
            }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
    }
    
    func DownloadFile(id: String, url: String,type:String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: AFDownloadResponse<Data>?, _ error:NSError?  ) -> ())
    {
        
        if ISDEBUG == true{
            print("DOWNLOAD URL ===== \n", url)
            print("Url:", url)
            print("Param",param)
        }
        
        DispatchQueue.main.async {
            
            if self.isConnectedToNetwork() == true {
                let Url:URL? = URL(string:url)
                
                if(Url != nil)
                {
                    Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
                    Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
                    Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
                    Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
                    Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
                    Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
                    
                    var FolderPath:String = String()
                    if(type == "1")
                    {
                        FolderPath = Constant.sharedinstance.photopath
                    }
                    else if(type == "2")
                    {
                        FolderPath = Constant.sharedinstance.videopathpath
                    }
                    else if(type == "3")
                    {
                        FolderPath = Constant.sharedinstance.voicepath
                    }
                    
                    else if(type == "6" || type == "20")
                    {
                        FolderPath = Constant.sharedinstance.docpath
                    }
                    
                    print(url)
                    var documentsURL = CommondocumentDirectory()
                    // documentsURL.appendPathComponent("\(FolderPath)/\(Themes.sharedInstance.CheckNullvalue(Passed_value: Url?.lastPathComponent))/\(Date.timeStamp)")
                    
                    documentsURL.appendPathComponent("\(FolderPath)/\(Themes.sharedInstance.CheckNullvalue(Passed_value: Url?.lastPathComponent))")
                    
                    if !FileManager.default.fileExists(atPath: documentsURL.absoluteString)
                    {
                        let destination: DownloadRequest.Destination = { _, _ in
                            return (documentsURL, [.removePreviousFile])
                        }
                        
                        
                        if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
                            AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
                            AppDelegate.sharedInstance.Logout()
                            return
                        }
                        
                        print("Destintion ==\(String(describing: destination))")
                        let headers = ["authorization" : Themes.sharedInstance.getToken(), "userid" : Themes.sharedInstance.Getuser_id(), "requesttype" : "site", "referer" : ImgUrl]
                        
                        let httpHeader = HTTPHeaders(headers)
                        
                        AF.download("\(url)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) {
                            (progress) in
                            // print("Completed Progress: \(progress.fractionCompleted)")
                            //print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                            if(self.Delegate !=  nil)
                            {
                                DispatchQueue.main.async {
                                    let Dict:NSDictionary = ["url":"\(url)","completed_progress":"\(progress.completedUnitCount)","total_progress":"\(progress.totalUnitCount)"]
                                    
                                    self.Delegate?.ReturnDownloadProgress(id: id, Dict: Dict,status: "1")
                                    
                                }
                            }
                            
                        }.validate().responseData { ( response ) in
                            DispatchQueue.main.async {
                                switch response.result {
                                
                                case .success(_):
                                    completionHandler(response ,nil)
                                    
                                case let .failure(error):
                                    completionHandler(nil, error as NSError)
                                }
                            }
                        }
                    }
                    else
                    {
                        completionHandler(nil, nil)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                    }
                }
                
            }
            
            else {
                DispatchQueue.main.async {
                    self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                }
            }
        }
    }
    
   
    
    
    func DownloadStatusFile(id: String, url: String,type:String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: AFDownloadResponse<Data>?,_ error:NSError?  ) -> ())
    {
        if ISDEBUG == true{
            print("Url:", url)
            print("Param",param)
        }
        
        if isConnectedToNetwork() == true {
            let Url:URL? = URL(string:url)
            if(Url != nil)
            {
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
                
                //            let destination = DownloadRequest.suggestedDownloadDestination()
                var FolderPath:String = String()
                if(type == "1" || type == "2")
                {
                    FolderPath = Constant.sharedinstance.statuspath
                }
                
                var documentsURL = CommondocumentDirectory()
                documentsURL.appendPathComponent("\(FolderPath)/\(Themes.sharedInstance.CheckNullvalue(Passed_value: Url?.lastPathComponent))")
                if !FileManager.default.fileExists(atPath: documentsURL.absoluteString)
                {
                    let destination: DownloadRequest.Destination = { _, _ in
                        return (documentsURL, [.removePreviousFile])
                    }
                    
                    
                    if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
                        AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
                        AppDelegate.sharedInstance.Logout()
                        return
                    }
                    let headers = [
                        "authorization" : Themes.sharedInstance.getToken(),
                        "userid" : Themes.sharedInstance.Getuser_id(),
                        "requesttype" : "site",
                        "referer" : ImgUrl
                    ]
                    
                    let httpHeader = HTTPHeaders.init(headers)
                    
                    
                    AF.download("\(url)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: httpHeader, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) { (progress) in
                        //print("Completed Progress: \(progress.fractionCompleted)")
                        //print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                        if(self.Delegate !=  nil)
                        {
                            DispatchQueue.main.async {
                                
                                let Dict:NSDictionary = ["url":"\(url)","completed_progress":"\(progress.completedUnitCount)","total_progress":"\(progress.totalUnitCount)"]
                                
                                self.Delegate?.ReturnDownloadProgress(id: id, Dict: Dict,status: "1")
                            }
                        }
                        
                    } .validate().responseData { ( response ) in
                        
                        DispatchQueue.main.async {
                            switch response.result {
                            case .success(_):
                                
                                completionHandler(response ,nil)
                            case let .failure(error):
                                completionHandler(nil, error as NSError)
                            }
                        }
                    }
                }
                else
                {
                    completionHandler(nil, nil)
                }
            }
            else{
                DispatchQueue.main.async {
                    self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
            }
        }
    }
    
    deinit {
    }
    
    
    func uploadAudio(fileName : String,file : URL, url:String, completion:@escaping (String,String,String)->Void)
    {
        if ISDEBUG == true{
            print("fileName: ", fileName)
            print("file: ",file)
            print("url: ", url)
        }
        
        let param = [String:AnyObject]()
        
        
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "song")
            //  multipartFormData.append(file, withName: "song", fileName: fileName, mimeType: "audio/m4a")
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
            let myDict = ["progress": progress.fractionCompleted]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadProgress"), object: myDict)
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    print("\(url) Response received: ",self.Dictionary)
                    let value = self.Dictionary
                    let status = value?["errNum"] as? String ?? ""
                    let message = value?["message"] as? String ?? ""
                    completion(message,status,message)
                }catch let error{
                    completion("\(error.localizedDescription)","false","")
                }
            }else{
                completion("\(response.error?.localizedDescription ?? "")","false","")
            }
        }
    }
    
    
    func uploadMedia(fileName : String,  param : [String:AnyObject] , file : URL, url:String, mimeType:String, completion:@escaping (String,String,String,String,String)->Void)
    {
        
        if ISDEBUG == true {
            print("URL:\n ",url,param)
            print("file:\n ",file)

        }
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "media", fileName: fileName, mimeType: "\(mimeType)")
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
            let myDict = ["progress": progress.fractionCompleted]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadProgress"), object: myDict)
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary)
                    }
                    
                    let status = self.Dictionary["status"] as? Int16 ?? 0
                    if status == 1 {
                        let value = self.Dictionary
                        var payload = value?["payload"] as? Dictionary<String, Any> ?? [:]
                        let dictReward = payload["rewards"] as? Dictionary ?? [:]
                        let msg = value?["message"] as? String ?? ""
                        let s3VideoUrl = payload["media"] as? String ?? ""
                        let url = payload["url"] as? String ?? ""
                        let thumbUrl = payload["thumbUrl"] as? String ?? ""
                        let duration = payload["duration"] as? String ?? ""

                        if url.count  > 0 && thumbUrl.count > 0 {
                            completion(msg,"\(status)",url,thumbUrl,duration)
                        }else{
                            completion(msg,"\(status)",url,thumbUrl,duration)
                        }
                    }else {
                        completion("File could not be uploaded","0","","","")
                    }
                    
                    
                         
                }catch let error{
                    completion("\(error.localizedDescription)","false","","","")
                }
            }else{
                completion("\(response.error?.localizedDescription ?? "")","false","","","")
            }
        }
    }
    
    func uploadWallStatus(fileName : String,  param : [String:AnyObject] , file : URL, url:String, mimeType:String, completion:@escaping (String,String,String,String)->Void)
    {
       // let param = [String:AnyObject]()
        
        
        
        if ISDEBUG == true {
            print("URL:\n ",url,param)
            print("file:\n ",file)

        }
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "picture", fileName: fileName, mimeType: "\(mimeType)")
           
            for (key, value) in param {
                
                if let arr = value as? Array<String>{
                    
                    let count : Int  = arr.count
                    
                    for i in 0  ..< count
                    {
                        let valueObj = arr[i]
                        let keyObj = key + "[" + String(i) + "]"
                        multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                    }
                    
                }else{
                     multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                 }
            }
            
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
//            let myDict = ["progress": progress.fractionCompleted]
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadProgress"), object: myDict)
//            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary)
                    }
                    
                    let status = self.Dictionary["status"] as? Int16 ?? 0
                    if status == 1 {
                        let value = self.Dictionary
                        var payload = value?["payload"] as? Dictionary<String, Any> ?? [:]
                        let dictReward = payload["rewards"] as? Dictionary ?? [:]
                        let msg = value?["message"] as? String ?? ""
                        let s3VideoUrl = payload["media"] as? String ?? ""
                        let url = payload["url"] as? String ?? ""
                        let thumbUrl = payload["thumbUrl"] as? String ?? ""
                        
                        if url.count  > 0 && thumbUrl.count > 0 {
                            completion(msg,"\(status)",url,thumbUrl)
                        }else{
                            completion(msg,"\(status)",msg,"")
                        }
                    }else {
                        completion("File could not be uploaded","0","","")
                    }
                    
                    
                         
                }catch let error{
                    completion("\(error.localizedDescription)","false","","")
                }
            }else{
                completion("\(response.error?.localizedDescription ?? "")","false","","")
            }
        }
    }
    
    
    
    
    func uploadVideoFeeds(fileName : String, file : URL, url:String, mimeType:String, completion:@escaping (String,String,String,String, Int16, Int16, String)->Void)
    {
        
        
        let param = [String:AnyObject]()
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "picture", fileName: fileName, mimeType: "\(mimeType)")
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
            let myDict = ["progress": progress.fractionCompleted]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadProgress"), object: myDict)
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary)
                    }
                  
                    let value = self.Dictionary
                    
                    /* let status = value?["errNum"] as? String ?? ""
                     let msg = value?["msg"] as? String ?? ""
                     
                     let messageDict = value?["message"] as? Dictionary<String,String>
                     let videourl = messageDict?["video_url"] ?? ""
                     let s3VideoUrl = messageDict?["s3VideoUrl"] ?? ""
                     */
                    
                    let msg = value?["msg"] as? String ?? ""
                    let status = value?["errNum"] as? String ?? ""
                    let videourl = value?["message"] as? String ?? ""
                    let s3VideoUrl = value?["message"] as? String ?? ""
                    let height =  value?["height"] as? Int16 ?? 0
                    let width =  value?["width"] as? Int16 ?? 0
                    let thumbUrl =  value?["thumbUrl"] as? String ?? ""

                    
                    completion(msg,status,videourl,s3VideoUrl, height, width,thumbUrl)
                }catch let error{
                    completion("\(error.localizedDescription)","false","","",0,0,"")
                }
            }else{
                completion("\(response.error?.localizedDescription ?? "")","false","","",0,0,"")
            }
        }
    }
    
    
    
    func uploadVideo(fileName : String, file : URL, url:String, completion:@escaping (String,String,String,String,String)->Void)
    {
        
        
        let param = [String:AnyObject]()
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "video", fileName: fileName, mimeType: "video/*")
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
            let myDict = ["progress": progress.fractionCompleted]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadProgress"), object: myDict)
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                  
                    let value = self.Dictionary
                    let status = value?["errNum"] as? String ?? ""
                    let msg = value?["msg"] as? String ?? ""
                    
                    let messageDict = value?["message"] as? Dictionary<String,String>
                    let videourl = messageDict?["video_url"] ?? ""
                    let s3VideoUrl = messageDict?["s3VideoUrl"] ?? ""
                    let thumbUrl = messageDict?["thumbUrl"] ?? ""
                    completion(msg,status,videourl,s3VideoUrl,thumbUrl)
                }catch let error{
                    completion("\(error.localizedDescription)","false","","","")
                }
            }else{
                completion("\(response.error?.localizedDescription ?? "")","false","","","")
            }
        }
    }
    
    func makeGetAPICall(url: String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        
        
        if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
            AppDelegate.sharedInstance.Logout()
            return
        }
        
        if ISDEBUG == true{
            print("URL: ",url)
            print("Param: ",param as Any)
        }
        if isConnectedToNetwork() == true {
            AF.request("\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  ?? "")", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getHeaderFields())
                .responseJSON { response in
               
                    switch response.result{
                    
                    case .success( _):
                        do {
                            
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                            if ISDEBUG == true{
                                
                                /*if let jsonString = String(data: response.data!, encoding: .utf8) {
                                  print("JSON: ",jsonString)
                                }*/
                                
                                print("\(url) Response received: ",self.Dictionary)
                            }
                            
                            //Check User
                           // self.checkValidationCode(respDict: self.Dictionary ?? [:])
                            
                            completionHandler(self.Dictionary as NSDictionary?, nil)
                        }
                        catch let error{
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error as NSError )
                        }
                    case .failure(let error):
                        if ISDEBUG == true {
                        print(response)
                        }
                       
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                        if response.data != nil {
                            if let jsonString = String(data: response.data!, encoding: .utf8) {
                                print("JSON: ",jsonString)
                            }
                        }
                    }
                }
        }else{
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
    }
    
    
    func makePostAPICallWithTwoHeaders(url: String,hashCode:String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        
        if isConnectedToNetwork() == true {

            let timeZone = TimeZone.current.identifier
            
            var headers = [ "authToken" : Themes.sharedInstance.getAuthToken(), "appVersion":"\(Themes.sharedInstance.getAppVersion())", "OS":"ios", "hash":hashCode,"timezone":"\(timeZone)"]
            
            if  Themes.sharedInstance.getBasicAuthorizationUserName().length > 0 {
                let loginString = "\(Themes.sharedInstance.getBasicAuthorizationUserName()):\(Themes.sharedInstance.getBasicAuthorizationPassword())"
                if let loginData = loginString.data(using: String.Encoding.utf8)  {
                    let base64LoginString = loginData.base64EncodedString()
                    headers["Authorization"] = "Basic \(base64LoginString)"
                }
              
                
            }
            
            let httpHeader = HTTPHeaders.init(headers)
            
            if ISDEBUG == true{
                print("URL: ",url)
                print("Param: ",param as Any)
                print("headers: ",headers)
            }
            
            AF.request("\(url)", method: .post, parameters: param as! Parameters, encoding: JSONEncoding.default, headers: httpHeader)
                .responseJSON { response in
                   
                    switch response.result{
                    
                    case .success( _):
                        do {
                            
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                            if ISDEBUG == true{
                                print("\(url) Response received: ",self.Dictionary)
                            }
                          
                            completionHandler(self.Dictionary as NSDictionary?, nil)
                        }
                        catch let error{
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error as NSError )
                        }
                    case .failure(let error):
                        if ISDEBUG == true {
                        print(response)
                        }
                       
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                    }
                }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
        
    }
    
    
    func makePostAPICall(url: String,param:NSDictionary?,isToCheckUserId:Bool = true,methodType:HTTPMethod = .post, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?) -> ()?)
    {
        
        if isConnectedToNetwork() == true {
            
            if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0 && isToCheckUserId{
                AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
                AppDelegate.sharedInstance.Logout()
                return
            }
            
            
            
            if ISDEBUG == true{
                print("URL: ",url)
                print("Param: ",param as Any)
            }
            
            AF.request(url, method: methodType, parameters: param as! Parameters, encoding: JSONEncoding.default, headers: self.getHeaderFields())
                .responseJSON { response in
                   
                    switch response.result{
                    
                    case .success( _):
                        do {
                            
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                            if ISDEBUG == true{
                                print("\(url) Response received: ",self.Dictionary)
                            }
                          
                            completionHandler(self.Dictionary as NSDictionary?, nil)
                        }
                        catch let error{
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error as NSError )
                        }
                    case .failure(let error):
                        if ISDEBUG == true {
                        print(response)
                        }
                       
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                    }
                }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
        
    }
    
    
    
    func makeDeleteAPICall(url: String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        
        if isConnectedToNetwork() == true {
            
            if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
                AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
                AppDelegate.sharedInstance.Logout()
                return
            }
                        
            if ISDEBUG == true{
                print("URL: ",url)
                print("Param: ",param as Any)
            }
            
            AF.request("\(url)", method: .delete, parameters: param as! Parameters, encoding: JSONEncoding.default, headers: self.getHeaderFields())
                .responseJSON { response in
                   
                    switch response.result{
                    
                    case .success( _):
                        do {
                            
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                            if ISDEBUG == true{
                                print("\(url) Response received: ",self.Dictionary)
                            }
                          
                            completionHandler(self.Dictionary as NSDictionary?, nil)
                        }
                        catch let error{
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error as NSError )
                        }
                    case .failure(let error):
                        if ISDEBUG == true {
                        print(response)
                        }
                       
                        self.Dictionary=nil
                        completionHandler(self.Dictionary as NSDictionary?, error as NSError)
                        print("A JSON parsing error occurred, here are the details:\n \(error.errorDescription ?? "")")
                    }
                }
        }else {
            
            let dict:NSDictionary = ["errNum":"1000", "message" : "No Network Connection"]
            completionHandler(dict, nil)
        }
        
    }
    
    func getImageFromUrl(imageUrl:String, imageView:UIImageView, placeholderImage: UIImage){
        
        let urlString = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        imageView.image = placeholderImage
        
        let image  = ImageCache.object(forKey: imageUrl as AnyObject)
        if image != nil{
            imageView.image = image as? UIImage
        }else{
            if  URL(string:urlString!) != nil{
                DispatchQueue.global(qos: .background).async {
                    let operation = BlockOperation(block: {
                        let fullurl = imageUrl.replacingOccurrences(of: " ", with: "%20")
                        let url =  URL(string:fullurl)
                        let data = try? Data(contentsOf: url!)
                        if data != nil{
                            if let img = UIImage(data: data!){
                                OperationQueue.main.addOperation({
                                    imageView.image = img
                                    self.ImageCache.setObject(img, forKey: imageUrl as AnyObject)
                                })
                            }
                        }
                    })
                    self.queue.addOperation(operation)
                }
            }
        }
    }
    
    
    
    
    func getThumbnailImageFromVideoUrl(videoUrlString: String , imageView:UIImageView, placeholderImage: UIImage){
        let urlString = videoUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        imageView.image = placeholderImage
        
        let image  = ImageCache.object(forKey: videoUrlString as AnyObject)
        if image != nil{
            imageView.image = image as? UIImage
        }else{
            if  URL(string:urlString!) != nil{
                
                DispatchQueue.global().async { //1
                    let fullurl = videoUrlString.replacingOccurrences(of: " ", with: "%20")
                    let url =  URL(string:fullurl)
                    let asset = AVAsset(url: url!) //2
                    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
                    avAssetImageGenerator.appliesPreferredTrackTransform = true //4
                    let thumnailTime = CMTimeMake(value: 0, timescale: 1) //5
                    do {
                        let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                        let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                        
                        OperationQueue.main.addOperation({
                            imageView.image = thumbNailImage
                            self.ImageCache.setObject(thumbNailImage, forKey: videoUrlString as AnyObject)
                        })
                        
                    } catch {
                        print(error.localizedDescription) //10
                        
                    }
                }
                
            }
        }
    }
    ////
    func getThumbnailImageFromLocalVideoUrl(videoUrlString: String , imageView:UIImageView, placeholderImage: UIImage){
        //let urlString = videoUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        imageView.image = placeholderImage
        
        let image  = ImageCache.object(forKey: videoUrlString as AnyObject)
        if image != nil{
            imageView.image = image as? UIImage
        }else{
            if  URL(fileURLWithPath: videoUrlString) != nil{
                
                DispatchQueue.global().async { //1
                    let url =  URL(fileURLWithPath: videoUrlString)
                    let asset = AVAsset(url: url) //2
                    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
                    avAssetImageGenerator.appliesPreferredTrackTransform = true //4
                    let thumnailTime = CMTimeMake(value: 0, timescale: 1) //5
                    do {
                        let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                        let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                        
                        OperationQueue.main.addOperation({
                            imageView.image = thumbNailImage
                            self.ImageCache.setObject(thumbNailImage, forKey: videoUrlString as AnyObject)
                        })
                        
                    } catch {
                        print(error.localizedDescription) //10
                        
                    }
                }
                
            }
        }
    }
    func getThumbnailImageFromLocalVideoUrlCallBack(videoUrlString: String , imageView:UIImageView, placeholderImage: UIImage, completion:@escaping ( _ success:Bool)->Void){
        //let urlString = videoUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        imageView.image = placeholderImage
        
        let image  = ImageCache.object(forKey: videoUrlString as AnyObject)
        if image != nil{
            imageView.image = image as? UIImage
            completion(true)
        }else{
            if  URL(fileURLWithPath: videoUrlString) != nil{
                
                DispatchQueue.global().async { //1
                    let url =  URL(fileURLWithPath: videoUrlString)
                    let asset = AVAsset(url: url) //2
                    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
                    avAssetImageGenerator.appliesPreferredTrackTransform = true //4
                    let thumnailTime = CMTimeMake(value: 0, timescale: 1) //5
                    do {
                        let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                        let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                        
                        OperationQueue.main.addOperation({
                            imageView.image = thumbNailImage
                            self.ImageCache.setObject(thumbNailImage, forKey: videoUrlString as AnyObject)
                            completion(true)
                        })
                        
                        
                    } catch {
                        print(error.localizedDescription) //10
                        completion(false)
                        
                    }
                }
                
            }else {
                completion(false)
            }
        }
    }
    
    func getThumbnailImageFromVideoUrlToButton(videoUrlString: String , btn:UIButton, placeholderImage: UIImage){
        let urlString = videoUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        btn.setBackgroundImage(placeholderImage, for: .normal)
        let image  = ImageCache.object(forKey: videoUrlString as AnyObject)
        if image != nil{
            btn.setBackgroundImage(image as? UIImage, for: .normal)
        }else{
            if  URL(string:urlString!) != nil{
                
                DispatchQueue.global().async { //1
                    let fullurl = videoUrlString.replacingOccurrences(of: " ", with: "%20")
                    let url =  URL(string:fullurl)
                    let asset = AVAsset(url: url!) //2
                    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
                    avAssetImageGenerator.appliesPreferredTrackTransform = true //4
                    let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
                    do {
                        let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                        let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                        
                        OperationQueue.main.addOperation({
                            
                            btn.setImage(thumbNailImage, for: .normal)
                            
                            self.ImageCache.setObject(thumbNailImage, forKey: videoUrlString as AnyObject)
                        })
                        
                    } catch {
                        print(error.localizedDescription) //10
                        
                    }
                }
                
            }
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    
    
    
    
  
    func uploadVerificationDocuments(profileImg : UIImage, documentImg : UIImage, url:String, params:[String:Any], completion:@escaping (String,Int)->Void)
    {
        
        if ISDEBUG{
            print(params)
        }
        //let param = [String:AnyObject]()
        AF.upload(multipartFormData: { (multipartFormData) in
          
            multipartFormData.append(documentImg.jpegData(compressionQuality: 0.3) ?? Data(), withName: "document", fileName: "document.jpeg", mimeType: "image/jpeg")
        
            multipartFormData.append(profileImg.jpegData(compressionQuality: 0.3) ?? Data(), withName: "document", fileName: "profile.jpeg", mimeType: "image/jpeg")

            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
           
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary)
                    }
                    
                 
                    let value = self.Dictionary
                    
                    /* let status = value?["errNum"] as? String ?? ""
                     let msg = value?["msg"] as? String ?? ""
                     
                     let messageDict = value?["message"] as? Dictionary<String,String>
                     let videourl = messageDict?["video_url"] ?? ""
                     let s3VideoUrl = messageDict?["s3VideoUrl"] ?? ""
                     */
                    
                    let msg = value?["message"] as? String ?? ""
                    let status = value?["status"] as? Int ?? 0
                   // let videourl = value?["message"] as? String ?? ""
//                    let s3VideoUrl = value?["message"] as? String ?? ""
//                    let height =  value?["height"] as? Int16 ?? 0
//                    let width =  value?["width"] as? Int16 ?? 0
//                    let thumbUrl =  value?["thumbUrl"] as? String ?? ""

                    completion(msg,status)
                }catch let error{
                    completion("\(error.localizedDescription)",0)
                }
            }else{
                completion("\(response.error?.localizedDescription ?? "")",0)
            }
        }
    }
    

  
    
    
    func uploadImageWithParameters(profileImg : UIImage,imageName:String, url:String, params:[String:Any], completion:@escaping (NSDictionary)->Void)
    {
        
        if ISDEBUG{
            print(url)
            print(params)
        }
        //let param = [String:AnyObject]()
        AF.upload(multipartFormData: { (multipartFormData) in
            
            if let data = profileImg.jpegData(compressionQuality: 0.3) {
                
                multipartFormData.append(data, withName: imageName, fileName: "\(imageName).jpeg", mimeType: "image/jpeg")
            }else {
                
            }
            

            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            print("\nmultipartFormData= \(multipartFormData)")
        
        },to: url, usingThreshold: UInt64.init(), method: .post, headers: self.getHeaderFields())
        .uploadProgress(queue: .main, closure: { (progress) in
           
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary)
                    }
                 
                    let value = self.Dictionary
                
                  


                    completion(self.Dictionary)
                }catch let error{
                    completion([:])
                }
            }else{
                
                completion([:])
            }
        }
    }
    
    
    
   
    
func uploadArrayOfMediaWithParameters(thumbUrlArray:Array<Any>,mediaArray : [URL],mediaName:String, url:String, params:NSMutableDictionary,method:HTTPMethod = .post, isToCallProgress:Bool = true, retriesCount:Int = 3, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
{
        
        if ISDEBUG{
            print(url)
            print(params)
        }
    self.isUploadingNewPost = true

    // Create a custom Session with the configuration
//    let session =   Session.default
//    session.sessionConfiguration.timeoutIntervalForRequest = 700
//    session.sessionConfiguration.timeoutIntervalForResource = 700
//    
    AF.upload(multipartFormData: { (multipartFormData) in
            
            for data in mediaArray{
                
                let strURL = data.absoluteString as NSString
                
                if strURL.pathExtension == "jpeg" || strURL.pathExtension == "png" || strURL.pathExtension == "jpg"{
                    multipartFormData.append(data, withName: mediaName, fileName: "\(mediaName).jpeg", mimeType: "image/jpeg")
                }else{
                    multipartFormData.append(data, withName:mediaName, fileName: "\(mediaName).mp4", mimeType: "video/*")
                }
            }
            
            
            for (key, value) in params {
                
                if value is Array<Dictionary<String,String>> {
                    
                    if let array = value as? Array<Dictionary<String,String>> {
                        var index = 0
                        for item in array {
                            
                            if let dimDict = item as? NSDictionary {
                                let height = dimDict["height"] as? String ?? "0"
                                let width = dimDict["width"] as? String ?? "0"
                                
                                multipartFormData.append(height.data(using: String.Encoding.utf8)!, withName: "\(key)[\(index)][height]")
                                multipartFormData.append(width.data(using: String.Encoding.utf8)!, withName: "\(key)[\(index)][width]")
                            }
                            index = index + 1
                        }
                    }
                    
                }else if let arr = value as? Array<String>{
                    
                    let count : Int  = arr.count
                    
                    for i in 0  ..< count
                    {
                        let valueObj = arr[i] as! String
                        let keyObj = key as! String + "[" + String(i) + "]"
                        multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                    }
                    
                }else if let dict = value as? Dictionary<String,Any>{
               
                    
                    print("dict==\(dict)")
                    print("dict.values==\(dict.values)")
                    print("dict.keys==\(dict.keys)")

                    let mainKey = key
                    for (key, value) in dict 
                    {
                        
                            
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: "\(mainKey)[\(key)]")
                        
                    }

                    
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as! String)
                }
                
            }
            
        },to: url, usingThreshold: UInt64.init(), method: method, headers: self.getHeaderFields(isFormData:true))
        .uploadProgress(queue: .main, closure: { (progress) in
            
            if Int(progress.fractionCompleted * 100) % 2 == 0  && isToCallProgress == true{
                let myDict = ["progress": progress.fractionCompleted,"url":thumbUrlArray] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: noti_UploadProgress), object: myDict)
                //   print("Upload Progress: \(progress.fractionCompleted)")
                //  print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
                //
            }
        })
        .response{ response in
            self.isUploadingNewPost = false
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary ?? [:])
                    }
                    
                    
                    completionHandler(self.Dictionary as NSDictionary?, response.error as NSError? )
                    if  isToCallProgress == true{
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: noti_UploadProgress), object: self.Dictionary)
                    }
                    
                }catch let error{
                    completionHandler(self.Dictionary as NSDictionary?, error as NSError? )
                    if  isToCallProgress == true{
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: noti_UploadProgress), object: self.Dictionary)
                    }
                    
                }

            }else{
                
                completionHandler(self.Dictionary as NSDictionary?, response.error as NSError?)
                if  isToCallProgress == true{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: noti_UploadProgress), object: NSDictionary())
                }
            }
        }
    }
   
    
    
    func uploadTwoMediaWithParameters(img1:URL?,img1Name:String,img2:URL?,img2Name:String, url:String, params:NSMutableDictionary,method:HTTPMethod = .post, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        
        if ISDEBUG{
            print(url)
            print(params)
        }
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            if let uploadImg = img1{
                multipartFormData.append(uploadImg, withName: img1Name, fileName: "\(img1Name).jpeg", mimeType: "image/jpeg")
            }
            
            if let uploadImg = img2{
                
                multipartFormData.append(uploadImg, withName: img2Name, fileName: "\(img2Name).jpeg", mimeType: "image/jpeg")
            }
            
            
            for (key, value) in params {
                
                if let arr = value as? Array<String>{
                
                    let count : Int  = arr.count
                    
                    for i in 0  ..< count
                    {
                        let valueObj = arr[i]
                        
                        let keyObj = key as! String + "[" + String(i) + "]"
                        
                        multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                    }
                    
                }else{
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as! String)
                }
            }
            
        
            
        },to: url, usingThreshold: UInt64.init(), method: method, headers: self.getHeaderFields(isFormData:false))
        .uploadProgress(queue: .main, closure: { (progress) in
            
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary ?? [:])
                    }
               
                    completionHandler(self.Dictionary as NSDictionary?, response.error as NSError? )
                }catch let error{
                    completionHandler(self.Dictionary as NSDictionary?, error as NSError? )
                    
                }
            }else{
                completionHandler(self.Dictionary as NSDictionary?, response.error as NSError? )
                
            }
        }
    }
   
    
    
    func uploadPdfMediaWithParameters(img1:URL?,img1Name:String, url:String, params:NSMutableDictionary,method:HTTPMethod = .post, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        
        if ISDEBUG{
            print(url)
            print(params)
        }
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            if let uploadImg = img1{
                multipartFormData.append(uploadImg, withName: img1Name, fileName: "\(img1Name).pdf", mimeType: "application/pdf")
            }
            
            
            for (key, value) in params {
                
                if let arr = value as? Array<String>{
                
                    let count : Int  = arr.count
                    
                    for i in 0  ..< count
                    {
                        let valueObj = arr[i]
                        
                        let keyObj = key as! String + "[" + String(i) + "]"
                        
                        multipartFormData.append(valueObj.data(using: String.Encoding.utf8)!, withName: keyObj)
                    }
                    
                }else{
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as! String)
                }
            }
            
        
            
        },to: url, usingThreshold: UInt64.init(), method: method, headers: self.getHeaderFields(isFormData:true))
        .uploadProgress(queue: .main, closure: { (progress) in
            
        })
        .response{ response in
            if response.error == nil{
                do{
                    self.Dictionary = try JSONSerialization.jsonObject(
                        with: response.value!!,
                        options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as? NSDictionary
                    
                    if ISDEBUG == true {
                        print("\(url) Response received: ",self.Dictionary ?? [:])
                    }
                  
                    completionHandler(self.Dictionary as NSDictionary?, response.error as NSError? )
                }catch let error{
                    completionHandler(self.Dictionary as NSDictionary?, error as NSError? )
                    
                }
            }else{
                completionHandler(self.Dictionary as NSDictionary?, response.error as NSError? )
                
            }
        }
    }
   
    
}
                    
                    
                    
                    
                    
                    
                   
        




