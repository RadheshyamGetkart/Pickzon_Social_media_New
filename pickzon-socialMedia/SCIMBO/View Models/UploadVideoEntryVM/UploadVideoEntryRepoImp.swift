//
//  UploadVideoEntryRepoImp.swift
//  SCIMBO
//
//  Created by Sachtech on 30/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

class UploadVideoEntryRepoImp: UploadVideoEntryRepo{

    private var rxApi:RxApi
    
    init(rxApi:RxApi) {
        self.rxApi = rxApi
    }
    
    func uploadVideoEntry(_ req: UploadVideoEntryRequest) -> Single<ListingsResponse>{
        //return rxApi.post(path: "/UploadVideoEntry", value: req).asSingle()
        
        return rxApi.post(path: "/uploadReelEntry", value: req).asSingle()
    }
}
