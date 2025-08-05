//
//  Model.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import Foundation

struct Room {
    
    var key: String
    var title: String
    
    init(dict: [String: AnyObject]) {
        title = dict["title"] as! String
        key = dict["key"] as! String
    }
    
    func toDict() -> [String: AnyObject] {
        return [
            "title": title as AnyObject,
            "key": key as AnyObject
        ]
    }
}


struct Comment {
    
    var text: String
    var Name: String?
    var Image: String?
    init(dict: [String: AnyObject]) {
        text = dict["text"] as! String
        Name = dict["Name"] as? String
        Image = dict["Image"] as? String
    }
}


struct User {
    
    var id = Int(arc4random())
    
    static let currentUser = User()
}


class GiftEvent: NSObject {
    
    var senderId: Int
    
    var giftId: Int
    
    var giftCount: Int
    
    init(dict: [String: AnyObject]) {
        senderId = dict["senderId"] as! Int
        giftId = dict["giftId"] as! Int
        giftCount = dict["giftCount"] as! Int
    }
    
    func shouldComboWith(_ event: GiftEvent) -> Bool {
        return senderId == event.senderId && giftId == event.giftId
    }
    
}

struct JoinedUser{
    
    var coverPic = ""
    var name = ""
    var pickzonId = ""
    var profilePic = ""
    var userId = ""
    var celebrity = 0
    var livePKId = ""
    var isLivePK = 0
    var isLive = 0
    var PKRoomId = ""
    var coins = 0
    var joinUserCount = ""
    var avatar = ""
    
    init(respDict:Dictionary<String,Any>){
        self.name = respDict["name"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.profilePic = respDict["profilePic"] as? String ?? ""
        self.userId = respDict["userId"] as? String ?? ""
        self.celebrity = respDict["celebrity"] as? Int ?? 0
        self.livePKId = respDict["livePKId"] as? String ?? ""
        self.isLivePK = respDict["isLivePK"] as? Int ?? 0 //"isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
        self.coverPic =  respDict["coverImageCdnCompress"] as? String ?? ""
        self.PKRoomId = respDict["PKRoomId"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
        self.joinUserCount = respDict["joinUserCount"] as? String ?? ""
        self.isLive = respDict["isLive"] as? Int ?? 0 
        self.avatar = respDict["avatar"] as? String ?? ""


    }
}


struct GoLiveUser{
    
    var liveUsers = [JoinedUser]()
    
    init(respArr: Array<Dictionary<String,Any>>){
        
        for dict in  respArr {
            liveUsers.append(JoinedUser(respDict: dict))
        }
    }
}


struct LiveUser{
    
    var coverPic = ""
    var name = ""
    var pickzonId = ""
    var profilePic = ""
    var userId = ""
    var celebrity = 0
    var livePKId = ""
    var isLivePK = 0
    var PKRoomId = ""
    var coins = 0
    var joinUserCount = ""
   // var topGiftersArr = [Gifters]()
    var avatarSVGA = ""
    var topGifterObj = Gifters(respDict:[:])
    
    init(respDict:Dictionary<String,Any>){
        self.name = respDict["name"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.profilePic = respDict["profilePic"] as? String ?? ""
        self.userId = respDict["userId"] as? String ?? ""
        self.celebrity = respDict["celebrity"] as? Int ?? 0
        self.livePKId = respDict["livePKId"] as? String ?? ""
        self.isLivePK = respDict["isLivePK"] as? Int ?? 0 //"isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
        self.coverPic =  respDict["coverImageCdnCompress"] as? String ?? ""
        self.PKRoomId = respDict["PKRoomId"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
        self.joinUserCount = respDict["joinUserCount"] as? String ?? ""
        self.avatarSVGA = respDict["avatarSVGA"]  as? String ?? ""

//        if  let gifters  = respDict["gifters"] as? Array<Dictionary<String,Any>>{
//            for dict in gifters{
//                self.topGiftersArr.append(Gifters(respDict: dict))
//            }
//        }
        
        if  let gifters  = respDict["gifters"] as? Dictionary<String,Any>{
            self.topGifterObj = Gifters(respDict: gifters)
        }


    }
}

struct Gifters{
    
    var profilePic = ""
    var userId = ""
    var pickzonId = ""
    var avatar = ""
    var celebrity = 0
    var avatarSVGA = ""
    
    init(respDict:Dictionary<String,Any>){
        self.profilePic = respDict["profilePic"] as? String ?? ""
        self.userId = respDict["userId"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.avatar = respDict["avatar"] as? String ?? ""
        self.celebrity = respDict["celebrity"] as? Int ?? 0
        self.avatarSVGA = respDict["avatarSVGA"] as? String ?? ""

    }
}



struct AgencyPkModel{
    
    var coverPic = ""
    var name = ""
    var pickzonId = ""
    var profilePic = ""
    var avatar = ""
    var userId = ""
    var celebrity = 0
    var livePKId = ""
    var isLivePK = 0
    var PKRoomId = ""
    var coins = 0
    var joinUserCount = ""
    var isLive = 0

    var coverPicRight = ""
    var nameRight = ""
    var pickzonIdRight = ""
    var profilePicRight = ""
    var avatarRight = ""
    var userIdRight = ""
    var celebrityRight = 0
    var livePKIdRight = ""
    var isLivePKRight = 0
    var PKRoomIdRight = ""
    var coinsRight = 0
    var joinUserCountRight = ""
    var isLiveRight = 0

    var duration = ""
    var startTime = ""
    var status = ""
    var result = 0
    var winnerId = ""
    var giftersLeftArray = [Gifters]()
    var giftersRightArray = [Gifters]()

    //var topGiftersArr = [Gifters]()

    var agencyScheduledPkStatus = 0

    
    init(respDict:Dictionary<String,Any>){
        
        self.duration = respDict["duration"] as? String ?? ""
        self.startTime = respDict["startDateTime"] as? String ?? ""
        self.winnerId = respDict["winnerId"] as? String ?? ""
        self.result = respDict["result"] as? Int ?? 0
      
        self.agencyScheduledPkStatus = respDict["status"] as? Int ?? 0

        if let userInfo = respDict["userInfo1"] as? Dictionary<String,Any>{
            
            self.name = userInfo["name"] as? String ?? ""
            self.pickzonId = userInfo["pickzonId"] as? String ?? ""
            self.profilePic = userInfo["profilePic"] as? String ?? ""
            self.avatar = userInfo["avatar"] as? String ?? ""
            self.userId = userInfo["userId"] as? String ?? ""
            self.celebrity = userInfo["celebrity"] as? Int ?? 0
            self.livePKId = userInfo["livePKId"] as? String ?? ""
            self.isLivePK = userInfo["isLivePK"] as? Int ?? 0 //"isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
            self.coverPic =  userInfo["coverImageCdnCompress"] as? String ?? ""
            self.PKRoomId = userInfo["PKRoomId"] as? String ?? ""
            self.coins = userInfo["coins"] as? Int ?? 0
            self.joinUserCount = userInfo["joinUserCount"] as? String ?? ""
            self.isLive = userInfo["isLive"] as? Int ?? 0
            
            if  let gifters  = userInfo["gifters"] as? Array<Dictionary<String,Any>>{
                for dict in gifters{
                    self.giftersLeftArray.append(Gifters(respDict: dict))
                }
            }

        }
        
        
        if let userInfo = respDict["userInfo2"] as? Dictionary<String,Any>{
            
            self.nameRight = userInfo["name"] as? String ?? ""
            self.pickzonIdRight  = userInfo["pickzonId"] as? String ?? ""
            self.profilePicRight  = userInfo["profilePic"] as? String ?? ""
            self.avatarRight  = userInfo["avatar"] as? String ?? ""
            self.userIdRight  = userInfo["userId"] as? String ?? ""
            self.celebrityRight  = userInfo["celebrity"] as? Int ?? 0
            self.livePKIdRight  = userInfo["livePKId"] as? String ?? ""
            self.isLivePKRight  = userInfo["isLivePK"] as? Int ?? 0 //"isLivePK": 0, // 0= is not playing PK, 1= is Playing PK
            self.coverPicRight  =  userInfo["coverImageCdnCompress"] as? String ?? ""
            self.PKRoomIdRight  = userInfo["PKRoomId"] as? String ?? ""
            self.coinsRight  = userInfo["coins"] as? Int ?? 0
            self.joinUserCountRight  = userInfo["joinUserCount"] as? String ?? ""
            self.isLiveRight = userInfo["isLive"] as? Int ?? 0
            
            if  let gifters  = userInfo["gifters"] as? Array<Dictionary<String,Any>>{
                for dict in gifters{
                    self.giftersRightArray.append(Gifters(respDict: dict))
                }
            }
        }
    }
}
