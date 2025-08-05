//
//  VideoRepo.swift
//  SCIMBO
//
//  Created by SachTech on 22/12/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

protocol VideoRepo: AnyObject {
    func getVideoDownloadLink(_ req: VideoRequest) -> Single<VideoResponse>
}
