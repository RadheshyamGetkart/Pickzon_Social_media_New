//
//  BlockVideoRepoImp.swift
//  SCIMBO
//
//  Created by Getkart on 27/05/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import RxSwift

class BlockVideoRepoImp: BlockVideoRepo{
    
    private var rxApi:RxApi
    
    init(rxApi:RxApi) {
        self.rxApi = rxApi
    }
    
    func blockVideo(_ req: BlockVideoRequest) -> Single<ListingOperationsResponse>{

        return rxApi.post(path: "/blockvideo", value: req).asSingle()
    }
}
