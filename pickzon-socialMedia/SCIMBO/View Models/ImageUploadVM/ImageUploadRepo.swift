//
//  ImageUploadRepo.swift
//  SCIMBO
//
//  Created by Sachtech on 03/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

protocol ImageUploadRepo: AnyObject {
    func imageUpload(_ request: ImageUploadRequest) -> Single<ImageUploadResponse>
}
