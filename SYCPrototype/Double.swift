//
//  Double.swift
//  SYCPrototype
//

import Foundation

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toPercents() -> Int {
        return Int((100*self).roundTo(places: 2))
    }
}
