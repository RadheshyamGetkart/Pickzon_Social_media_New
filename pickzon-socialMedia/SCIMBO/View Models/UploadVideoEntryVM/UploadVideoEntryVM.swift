//
//  UploadVideoEntryVM.swift
//  SCIMBO
//
//  Created by Sachtech on 30/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

class UploadVideoEntryVM: ViewModel<ListingsResponse>{

    private var repository: UploadVideoEntryRepo

    init(repository: UploadVideoEntryRepo) {
        self.repository = repository
    }

    func uploadVideoEntry(_ req: UploadVideoEntryRequest){
        isLoading.onNext(true)
        repository.uploadVideoEntry(req)
            .subscribe(onSuccess: { (response) in
                self.response.onNext(response)
                self.isLoading.onNext(false)
            }) { (error) in
                self.error.onNext(error.localizedDescription)
                self.isLoading.onNext(false)
            }
            .disposed(by: super.disposeBag)
    }
}
