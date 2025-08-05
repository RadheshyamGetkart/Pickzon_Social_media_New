//
//  CountryVM.swift
//  Susen Dating App
//
//  Created by Sachtech on 06/11/19.
//  Copyright © 2019 Sachtech. All rights reserved.
//

import Foundation
import RxSwift

class CountryVM:ViewModel<CountryResponse>{
    
    private var repository:CountryRepo
    
    init(repository:CountryRepo) {
        self.repository = repository
    }
    
    func getCountries() -> Single<CountryResponse>{
      
       return repository.getCountries()
       
    }
}
