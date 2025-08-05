//
//  VideoRepoImp.swift
//  SCIMBO
//
//  Created by SachTech on 22/12/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

import RxSwift

class VideoRepoImp: VideoRepo{

    private var rxApi:RxApi
    
    init(rxApi:RxApi) {
        self.rxApi = rxApi
    }
    
    func getVideoDownloadLink(_ req: VideoRequest) -> Single<VideoResponse>{
        return rxApi.get(path: "/GetDownloadUri", value: req).asSingle()
    }
}
