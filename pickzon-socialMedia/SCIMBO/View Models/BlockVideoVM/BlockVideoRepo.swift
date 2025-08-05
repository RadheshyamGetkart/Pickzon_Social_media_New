//
//  BlockVideoRepo.swift
//  SCIMBO
//
//  Created by Getkart on 27/05/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//


import Foundation
import RxSwift

protocol BlockVideoRepo {
    
    func blockVideo(_ req: BlockVideoRequest) -> Single<ListingOperationsResponse>
}
