//
//  VideoVM.swift
//  SCIMBO
//
//  Created by SachTech on 22/12/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

class VideoVM: ViewModel<VideoResponse>{

    private var repository: VideoRepo

    init(repository: VideoRepo) {
        self.repository = repository
    }

    func getVideoDownloadLink(_ req: VideoRequest) -> Single<VideoResponse>{
        return repository.getVideoDownloadLink(req)
    }
}
