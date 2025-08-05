//
//  ImageUploadVM.swift
//  SCIMBO
//
//  Created by Sachtech on 03/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import RxSwift

class ImageUploadVM: ViewModel<ImageUploadResponse> {
    
    private var repository:ImageUploadRepo
    
    init(repository:ImageUploadRepo) {
        self.repository = repository
    }
    
    func imageUpload(_ request: ImageUploadRequest){
        isLoading.onNext(true)
        repository.imageUpload(request)
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
