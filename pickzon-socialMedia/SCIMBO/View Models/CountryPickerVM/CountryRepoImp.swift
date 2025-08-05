//
//  CountryRepoImp.swift
//  Susen Dating App
//
//  Created by Sachtech on 06/11/19.
//  Copyright © 2019 Sachtech. All rights reserved.
//

import Foundation
import RxSwift

class CountryRepoImp:CountryRepo{
    
    private var rxApi:RxApi
    
    init(rxApi:RxApi) {
        self.rxApi = rxApi
    }
    func getCountries() -> Single<CountryResponse>{
        let request = CountryRequest(apiKey: "healthapp@123_*")
        return rxApi.post(path: "http://stsmentor.com/health_app/api/Country/getCountry", value: request).asSingle()
    }
}
