//
//  DownloadHandler.swift
//
//
//  Created by MV Anand Casp iOS on 21/06/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Photos

class DownloadHandler: NSObject,URLhandlerDelegate {
   
    static let sharedinstance=DownloadHandler()
    var downloadArr = [[String : Any]]() {
        didSet {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.download), object: nil)
            self.perform(#selector(self.download), with: nil, afterDelay: 2.0)
        }
    }
    
    
    func StartDownload(id: String, Str:String,type:String, completionHandler: (() -> Swift.Void)? = nil)
    {
        print(Str)
        let download_status:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: id, returnStr: "download_status")
        if(download_status == "0")
        {
            let param:NSDictionary = ["download_status":"1"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: id, attribute: "upload_data_id", UpdationElements: param)
            URLhandler.sharedinstance.Delegate = self
            URLhandler.sharedinstance.DownloadFile(id: id, url: Str,type:type, param: nil) { (ResponseDict, error) in
                DispatchQueue.main.async {
                    
                    if(error == nil)
                    {
                        if(ResponseDict != nil)
                        {
                            let UrlStr:String =  (ResponseDict!.request?.url?.absoluteString)!
                            
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
                            let DestURL:String =  "\(FolderPath)/"+(ResponseDict!.fileURL?.lastPathComponent)!
                            let documentsDirectoryURL = CommondocumentDirectory()
                            _ = documentsDirectoryURL.appendingPathComponent(DestURL)
                            let to_id:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: id, returnStr: "to_id")
                            let download_status:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: id, returnStr: "download_status")
                            
                            
                            print("the url is >>>>>>><<<??\(UrlStr)")
                            let param:NSDictionary = ["download_status":"2","upload_Path":DestURL]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: id, attribute: "upload_data_id", UpdationElements: param)
                            let UploadArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: id, SortDescriptor: nil) as! NSArray
                            
                            if(UploadArr.count > 0)
                            {
                                let upload_data_id:String = (UploadArr[0] as! NSManagedObject).value(forKey: "upload_data_id") as! String
                                let upload_byte_count:String = (UploadArr[0] as! NSManagedObject).value(forKey: "upload_byte_count") as! String
                                let total_byte_count:String = (UploadArr[0] as! NSManagedObject).value(forKey: "total_byte_count") as! String
                                
                                let File_status_dict:[String: String] = ["upload_status": "0","type":type,"status":"0", "total_byte_count" : total_byte_count,  "upload_byte_count" : upload_byte_count]
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: upload_data_id , userInfo: File_status_dict)
                            }
                            
                        }
                    }
                    else
                    {
                        self.ChangeStatusonFailed(id: id);
                    }
                    if(completionHandler != nil)
                    {
                        completionHandler!()
                    }
                }
            }
        }
        else {
            if(completionHandler != nil)
            {
                completionHandler!()
            }
        }
    }
    
    func ChangeStatusonFailed(id: String)
    {
        let download_status:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: id, returnStr: "download_status")
       
        if(download_status != "2")
        {
            let param:NSDictionary = ["download_status":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: id, attribute: "upload_data_id", UpdationElements: param)
        }
    }
    
    func ReturnDownloadProgress(id: String, Dict: NSDictionary, status:String)
    {
        if(Dict.count > 0)
        {
            if(status == "1")
            {
                let completed_progress:String = Dict.object(forKey: "completed_progress") as! String
                var TotalProgress:String = Dict.object(forKey: "total_progress") as! String
                if(TotalProgress == "-1")
                {
                    TotalProgress = completed_progress
                }
                let CheckMedia = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: id)
                
                let download_status:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: id, returnStr: "download_status")
                if(download_status != "2")
                {
                    if(CheckMedia)
                    {
                        let param:NSDictionary = ["upload_byte_count":"\(completed_progress)","total_byte_count":"\(TotalProgress)","download_status":"1"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: id, attribute: "upload_data_id", UpdationElements: param)
                        let UploadArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: id, SortDescriptor: nil) as! NSArray
                        if(UploadArr.count > 0)
                        {
                            let upload_data_id:String = (UploadArr[0] as! NSManagedObject).value(forKey: "upload_data_id") as! String
                            let type:String = (UploadArr[0] as! NSManagedObject).value(forKey: "upload_type") as! String
                            let File_status_dict:[String: String] = ["upload_status": "1","type":type,"status":"0", "total_byte_count" : TotalProgress, "upload_byte_count" : completed_progress]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: upload_data_id , userInfo: File_status_dict)
                        }
                    }
                    
                }
                else
                {
                    let param:NSDictionary = ["upload_byte_count":"\(completed_progress)","total_byte_count":"\(TotalProgress)","download_status":"2"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: id, attribute: "upload_data_id", UpdationElements: param)
                    
                    let UploadArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: id, SortDescriptor: nil) as! NSArray
                    
                    if(UploadArr.count > 0)
                    {
                        let upload_data_id:String = (UploadArr[0] as! NSManagedObject).value(forKey: "upload_data_id") as! String
                        let type:String = (UploadArr[0] as! NSManagedObject).value(forKey: "upload_type") as! String
                        
                        let File_status_dict:[String: String] = ["upload_status": "1","type":type,"status":"0", "total_byte_count" : TotalProgress, "upload_byte_count" : completed_progress]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: upload_data_id , userInfo: File_status_dict)
                    }
                }
            }
                
            else
            {
                self.ChangeStatusonFailed(id : id)
            }
        }
    }
    
    func ReturnuploadDetails(pathid:String,upload_detail:String)->Any?
    {
        
        let UploadArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: pathid, SortDescriptor: nil) as! NSArray
        var ReturnUploadDetail:String?
        if(UploadArr.count > 0)
        {
            for i in 0..<UploadArr.count
            {
                let ReponseDict:NSManagedObject = UploadArr[i] as! NSManagedObject
                
                if(upload_detail == "upload_Path")
                {
                    let documentsDirectoryURL = CommondocumentDirectory()
                    let fileURL = documentsDirectoryURL.appendingPathComponent((ReponseDict.value(forKey: upload_detail) as! String?)!)
                    ReturnUploadDetail = fileURL.path;
                }
                else if(upload_detail == "video_thumbnail")
                {
                    return ReponseDict.value(forKey: upload_detail)
                }
                else
                {
                    ReturnUploadDetail = Themes.sharedInstance.CheckNullvalue(Passed_value: (ReponseDict.value(forKey: upload_detail) as! String?)!)
                }
                
            }
            
        }
        return ReturnUploadDetail
    }
    
    func handleDownLoad(_ ismanual : Bool)
    {
        DispatchQueue.main.async {
            let p1 = NSPredicate(format: "download_status == %@", "0")
            let p2 = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            
            let UploadDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Upload_Details, SortDescriptor: nil, predicate: predicate, Limit: 0) as! [Upload_Details]
            
            _ = UploadDetailArr.map {
                let ReponseDict = $0
                let to_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.to_id)
                
                
                if(to_id != Themes.sharedInstance.Getuser_id())
                {
                    let download_status = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.download_status)
                    let serverpath = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.serverpath)
                    let upload_data_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_data_id)
                    let upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_type)
                    
                    
                    var autodownload  = true
                    
                    var _ : String = String()
                    if(upload_type == "1")
                    {
                        autodownload = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
                    }
                    else if(upload_type == "2")
                    {
                        autodownload = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "videos", download_status: download_status)
                    }
                    else if(upload_type == "3")
                    {
                        autodownload = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "audio", download_status: download_status)
                    }
                        
                    else if(upload_type == "6" || upload_type == "20")
                    {
                        autodownload = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "documents", download_status: download_status)
                    }
                    
                    if (autodownload || ismanual), (serverpath != ""), (download_status == "0")
                    {
                        if !self.downloadArr.contains(where: { Themes.sharedInstance.CheckNullvalue(Passed_value: $0["serverpath"]) == serverpath})
                        {
                            self.downloadArr.append(["serverpath" : serverpath, "upload_type" : upload_type, "upload_data_id" : upload_data_id])
                        }
                    }
                }
                
            }
            
        }
    }
    
    @objc func download()
    {
        if let file = downloadArr.first {
            self.StartDownload(id: Themes.sharedInstance.CheckNullvalue(Passed_value: file["upload_data_id"]), Str: Themes.sharedInstance.CheckNullvalue(Passed_value: file["serverpath"]), type: Themes.sharedInstance.CheckNullvalue(Passed_value: file["upload_type"])) {
                DispatchQueue.main.async {
                    if(self.downloadArr.count > 0)
                    {
                        self.downloadArr.remove(at: 0)
                        self.download()
                    }
                }
            }
        }
    }
    
    
    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
        {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

            if FileManager().fileExists(atPath: destinationUrl.path)
            {
                print("File already exists [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = session.dataTask(with: request, completionHandler:
                {
                    data, response, error in
                    if error == nil
                    {
                        if let response = response as? HTTPURLResponse
                        {
                            if response.statusCode == 200
                            {
                                if let data = data
                                {
                                    if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                    {
                                        completion(destinationUrl.path, error)
                                    }
                                    else
                                    {
                                        completion(destinationUrl.path, error)
                                    }
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                        }
                    }
                    else
                    {
                        completion(destinationUrl.path, error)
                    }
                })
                task.resume()
            }
        }
    
}
