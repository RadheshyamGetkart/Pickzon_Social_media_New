//
//  CountryRepo.swift
//  Susen Dating App
//
//  Created by Sachtech on 06/11/19.
//  Copyright © 2019 Sachtech. All rights reserved.
//

import Foundation
import RxSwift

protocol CountryRepo: AnyObject {
    func getCountries() -> Single<CountryResponse>
}
