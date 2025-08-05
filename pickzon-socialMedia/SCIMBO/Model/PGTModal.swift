//
//  PGTModal.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import Foundation


struct PGTModel{
    var  title = ""
    var  date = ""
    var  totalViews:UInt = 0
    var  clipsArray = [WallPostModel]()
    var  winnersClipsArray = [WallPostModel]()
    
    init(respDict:Dictionary<String,Any>){
        
        self.title = respDict["title"] as? String ?? ""
        self.date = respDict["date"] as? String ?? ""
        self.totalViews = respDict["totalViews"] as? UInt ?? 0
        
        if let  clips = respDict["clips"] as? Array<Dictionary<String,Any>>{
            
            for dict in clips{
                
                self.clipsArray.append(WallPostModel(dict: dict as NSDictionary))
            }
        }
        
        if let  winnersClips = respDict["winnersClips"] as? Array<Dictionary<String,Any>>{
            
            for dict in winnersClips{
                self.winnersClipsArray.append(WallPostModel(dict: dict as NSDictionary))
            }
        }
    }
    
}
