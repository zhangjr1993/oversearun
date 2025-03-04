//
//  Bool.swift
//  AIRun
//
//  Created by AIRun on 20247/18.
//

import Foundation



extension Bool {
    var intValue: Int {
        if self {
            return 1
        }
        return 0
    }
}

extension Int {
    var boolValue: Bool {
        self != 0
    }
    var stringValue: String {
        String(self)
    }
}

extension Double {
    var stringValue: String {
        String(self)
    }
    
    var decimalsToW: String {
        if self >= 100000.0 {
            let intVal  = self / 10000.0
            let doubleVal = Int(self) % 10000
            let suffixValue = doubleVal / 1000
            if suffixValue == 0 {
                return "\(intVal)" + "w"
            }else {
                return "\(intVal)" + "." + "\(suffixValue)" + "w"
            }
        }
        return self.stringValue
    }
}

extension Int {
    var decimalsIntToW: String {
        if self >= 10000 {
            let floatValue = CGFloat(self) / 10000.0
            return "\(round(floatValue * 10.0) / 10.0)w"
        }
        return self.stringValue
    }
    
    var IM_cardID: Int {
        return self + 1000000000
    }

}

