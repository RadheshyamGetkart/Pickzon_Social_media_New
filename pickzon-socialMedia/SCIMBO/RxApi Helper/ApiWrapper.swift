//
//  ApiWrapper.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation

extension String {

    mutating func appendParams(values: Dictionary<String,Any>)->String{

        for (index,value) in values.enumerated(){
            if(index==0){ self.append("?") }
            else { self.append("&") }

            self.append("\(value.key)=\(value.value)")
        }
        return self
    }

}
