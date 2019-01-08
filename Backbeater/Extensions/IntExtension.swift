//
//  IntExtension.swift
//
//  Created by Alina Khgolcheva on 10/11/14.
//


extension Int {
    func normalized(min minValue:Int, max maxValue:Int) -> Int {
        return  Swift.max(minValue, Swift.min(maxValue, self))
    }
}
