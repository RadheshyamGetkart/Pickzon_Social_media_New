//
//  ApiHandler.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/10/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation
import Alamofire



class ApiHandler:NSObject{
    
    static let sharedInstance:ApiHandler = {
        let apiHandler = ApiHandler()
//        apiHandler.ImageCache.countLimit = 1000
//        apiHandler.ImageCache.totalCostLimit = 1024 * 1024 * 512 //500 MB
        return apiHandler
    }()
    var dictionary:NSDictionary!=NSDictionary()
    
   
    func isConnectedToNetwork() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    

    func makePostGenericData<T:Decodable>(url:String,param:NSDictionary?,isToShowLoader:Bool=true,completion:@escaping(T)-> ()){
        
        
        DispatchQueue.main.async {
            if isToShowLoader {
                Themes.sharedInstance.activityView(View:  AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
            }
        }
        
        if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
            AppDelegate.sharedInstance.Logout()
            return
        }
        
      //  let headers = [ "authToken" : Themes.sharedInstance.getAuthToken(), "appVersion":"\(Themes.sharedInstance.getAppVersion())", "OS":"ios",  "Content-Type" : "application/json"]
//        let httpHeader = HTTPHeaders.init(headers)
        
        let httpHeader = URLhandler.sharedinstance.getHeaderFields()

        if ISDEBUG == true{
            print("URL: ",url)
            print("Param: ",param as Any)
            print("headers: ",httpHeader)
        }
        
        AF.request(url, method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: httpHeader)
            .responseJSON { response in
              
                DispatchQueue.main.async {
                   
                    Themes.sharedInstance.RemoveactivityView(View:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                                    }
                
                switch response.result{
                    
                case .success( _):
                    do {
                        self.dictionary = try JSONSerialization.jsonObject(
                            with: response.data!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true{
                            print("Response received: ",self.dictionary ?? [:])
                        }
                        
                        
                        guard let data = response.data else {
                            return
                        }
                        
                        do{
                            
                            let obj = try JSONDecoder().decode(T.self, from: data)
                            completion(obj)
                        }
                        
                    }
                    catch let error{
                        print("A JSON parsing error occurred, here are the details:\n \(error)")
                        self.dictionary=nil
                       // completion()
                    }
             
                case .failure(let error):
                   // completion()
                    print(error.localizedDescription)
                }
            }
        
    }
    
    
    func makeGetGenericData<T:Decodable>(isToShowLoader:Bool, url:String,completion:@escaping(T)-> ()){
        
      
        DispatchQueue.main.async {
            if isToShowLoader == true {
                Themes.sharedInstance.activityView(View:  AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
            }
        }
        if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
            
            AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
            AppDelegate.sharedInstance.Logout()
            return
        }
        
        let httpHeader = URLhandler.sharedinstance.getHeaderFields()
        
        if ISDEBUG == true{
            print("URL: ",url)
            print("headers: ",httpHeader)
        }
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: httpHeader)
            .responseJSON { response in
                
                DispatchQueue.main.async {
                    if isToShowLoader == true {

                    Themes.sharedInstance.RemoveactivityView(View:AppDelegate.sharedInstance.navigationController?.topViewController?.view ?? UIView())
                    }
                }
                
                switch response.result{
                    
                case .success( _):
                    do {
                        self.dictionary = try JSONSerialization.jsonObject(
                            with: response.data!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                        ) as? NSDictionary
                        
                        if ISDEBUG == true{
                            print("Response received: ",self.dictionary ?? [:])
                        }
                        
                        
                        guard let data = response.data else {
                            return
                        }
                        
                        do{
                            
                            let obj = try JSONDecoder().decode(T.self, from: data)
                            completion(obj)
                        }
                        
                    }
                    catch let error{
                        print("A JSON parsing error occurred, here are the details:\n \(error)")
                        self.dictionary=nil
                        // completion()
                    }
                    
                case .failure(let error):
                    // completion()
                    print(error.localizedDescription)
                }
            }
        
    }
}
