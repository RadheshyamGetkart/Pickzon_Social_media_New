//
//  ImageUploadRepoImp.swift
//  SCIMBO
//
//  Created by Sachtech on 03/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

class ImageUploadRepoImp: ImageUploadRepo {
    private var rxApi:RxApi
    
    init(rxApi:RxApi) {
        self.rxApi = rxApi
    }
    func imageUpload(_ request: ImageUploadRequest) -> Single<ImageUploadResponse> {
        
        return rxApi.postUpload(path: "/picUpload", value: request).asSingle()
    }
}
