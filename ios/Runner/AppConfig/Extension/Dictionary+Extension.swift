//
//  Dictionr.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import Foundation

extension Dictionary {
    @inlinable public static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        var dic = lhs
        for (k,v) in rhs {
            dic[k] = v
        }
        return dic
    }
    
    @inlinable public static func += (lhs: inout Dictionary, rhs: Dictionary) {
        for (k,v) in rhs {
            lhs[k] = v
        }
    }
}
