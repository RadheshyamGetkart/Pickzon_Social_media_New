//
//  Schedulers.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation
import RxSwift

protocol Schedulers  {

    func io() -> ImmediateSchedulerType

    func main() -> ImmediateSchedulerType
}


class SchedulersImp : Schedulers {
    func io() -> ImmediateSchedulerType {
        return ConcurrentDispatchQueueScheduler(qos: .background)
    }

    func main() -> ImmediateSchedulerType {
        return MainScheduler.instance
    }
}
