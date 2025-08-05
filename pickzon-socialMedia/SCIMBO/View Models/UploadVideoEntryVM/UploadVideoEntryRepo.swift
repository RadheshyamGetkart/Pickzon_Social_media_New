//
//  UploadVideoEntryRepo.swift
//  SCIMBO
//
//  Created by Sachtech on 30/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

protocol UploadVideoEntryRepo: AnyObject {
    func uploadVideoEntry(_ req: UploadVideoEntryRequest) -> Single<ListingsResponse>
}
