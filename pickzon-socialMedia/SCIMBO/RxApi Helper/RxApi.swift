//
//  RxApi.swift
//  Coravidao
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//
import Foundation
import RxAlamofire
import RxSwift
import Alamofire

class RxApi {
    
    private let url = BaseUrl
    
    
   // private let httpHeaders: HTTPHeaders = [HTTPHeader.authorization(bearerToken: "")]
    

    
   /* private let httpHeaders: HTTPHeaders = HTTPHeaders.init([
        "authToken" : Themes.sharedInstance.getAuthToken(),
        "appVersion" : "\(Themes.sharedInstance.getAppVersion())",
        "OS":"ios",
        "bearerToken" : "",
        
    ])*/
    
    
    
    func getHeaderFields()->HTTPHeaders {
        // "Content-Type":"application/json",
        var headers = ["appVersion":"\(Themes.sharedInstance.getAppVersion())", "OS":"ios","bearerToken" : ""]
        
        if  Themes.sharedInstance.getAuthToken().length > 0 {
            headers["authToken"] = Themes.sharedInstance.getAuthToken()
        }
        
        if  Themes.sharedInstance.getBasicAuthorizationUserName().length > 0 {
            let loginString = "\(Themes.sharedInstance.getBasicAuthorizationUserName()):\(Themes.sharedInstance.getBasicAuthorizationPassword())"
            if let loginData = loginString.data(using: String.Encoding.utf8) {
                let base64LoginString = loginData.base64EncodedString()
                headers["Authorization"] = "Basic \(base64LoginString)"
            }
        }
        
        
        return HTTPHeaders.init(headers)
    }
    
   // private let httpHeaders: HTTPHeaders = URLhandler.sharedinstance.getHeaderFields()


    
    func get<T>(path: String, value: JsonSerilizer) -> Observable<T> where T:JsonDeserilizer{
        
    
        return execute(method: .get, path: path, values: value.serilize())
    }
    
    func post<T>(path: String, value: JsonSerilizer) -> Observable<T> where T:JsonDeserilizer {
        return execute(method: .post, path: path, values: value.serilize())
    }
    
    func put<T>(path: String, value: JsonSerilizer) -> Observable<T> where T:JsonDeserilizer {
        return execute(method: .put, path: path, values: value.serilize())
    }
    
    func postUpload<T>(path: String, value: JsonSerilizer) -> Observable<T> where T:JsonDeserilizer {
        
        if value is FileSerilizer {
            
            let fullUrl = url + path
            
            return  startUploading(url: fullUrl, data: (value as! FileSerilizer).file(), values: value.serilize())
                .map { (response) -> T in
                    
                    var instance = T.init()
                    let responseConverted = response as? [String:Any]
                    
                    instance.deserilize(values:responseConverted)
                    return instance
            }
            
        }else{
            return post(path: path, value: value)
        }
    }
    
    private func startUploading(url: String, data: (String,Data), values: Dictionary<String,Any>) -> Observable<Any> {
        
        return  Observable.create{ (observer) -> Disposable in
            
            AF.upload(multipartFormData: { (multipartFormData) in
                
                //multipartFormData.append(data.1, withName: data.0, fileName: data.0, mimeType: "image/jpeg")
                multipartFormData.append(data.1, withName: data.0, fileName: "abc.jpg", mimeType: "image/jpeg")

                for (key, value) in values {
                    multipartFormData.append((value as AnyObject).data!(using: String.Encoding.utf8.rawValue)!, withName: key)
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
                            if let jsonData = response.data{
                                let parsedData = try JSONSerialization.jsonObject(with: jsonData)
                                if ISDEBUG == true {
                                print(parsedData)
                                }
                                observer.onNext(parsedData)
                                observer.onCompleted()
                            
                            }
                        }catch{
                            observer.onNext("Error")
                        }
                    }else{
                        observer.onError(response.error!)
                    }
                }
            return Disposables.create {
            }
        }
    }

    private func execute<T>(method: Alamofire.HTTPMethod ,path: String,values: Dictionary<String,Any>,encoding:ParameterEncoding = JSONEncoding.default,header:[String:String]? = [:])-> Observable<T> where T:JsonDeserilizer{
        
        let pathUrl = path.contains("http") ? path : url+path
        
        if ISDEBUG == true{
            print("URL: ",pathUrl)
            print("Params : ",values)
            print("header : ",getHeaderFields())
        }
        
        return  RxAlamofire.requestJSON(method, pathUrl, parameters: values, headers: self.getHeaderFields())
            .debug()
            .map {(arg) -> T in
                return self.populateData(arg)
            }
    }

    private func populateData<T>(_ arg : (HTTPURLResponse,Any)) -> T where T:JsonDeserilizer{
        let (_, json) = arg
        var instance = T.init()
        let responseConverted = json as? [String:Any] ?? [:]
        
        let errNo = responseConverted["errNum"] as? String ?? ""
        let message = responseConverted["message"] as? String ?? ""
        
        if  errNo == "105" {
            DispatchQueue.main.async {
                AlertView.sharedManager.displayMessageWithAlert(title: "Pickzon!", msg: message)
                
                AppDelegate.sharedInstance.Logout()
                return
                
            }
        }
        
        

        instance.deserilize(values:responseConverted)
        return instance
    }

    private func create<T>() -> T  where T:JsonDeserilizer {
        return T.init()
    }
}


