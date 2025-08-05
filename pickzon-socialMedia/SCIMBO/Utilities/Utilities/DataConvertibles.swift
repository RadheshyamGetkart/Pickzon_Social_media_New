//
//  Cryptors.swift
//  Camo
//
//  Created by SachTech on 25/04/20.
//  Copyright © 2020 SachTech. All rights reserved.
//

import Foundation

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible where Self: ExpressibleByIntegerLiteral{

    init?(data: Data) {
        var value: Self = 0
        guard data.count == MemoryLayout.size(ofValue: value) else { return nil }
        _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
        self = value
    }

    var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
