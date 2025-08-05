//
//  BaseViewModel.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel<T> {

    public let response = PublishSubject<T?>()
    public let error = PublishSubject<String>()

    public let isLoading = PublishSubject<Bool>()

    internal  var disposeBag = DisposeBag()
    internal var disposable = CompositeDisposable()

    func onCleared(){
        disposable.dispose()
    }

}
