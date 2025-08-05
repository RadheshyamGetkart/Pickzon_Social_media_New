//
//  BlockVideoVM.swift
//  SCIMBO
//
//  Created by Getkart on 27/05/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import RxSwift

 class BlockVideoVM: ViewModel<ListingOperationsResponse>{
    
    private var repository: BlockVideoRepo

    init(repository: BlockVideoRepo) {
        self.repository = repository
    }

    func blockVideo(_ req: BlockVideoRequest){
        isLoading.onNext(true)
        repository.blockVideo(req)
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
