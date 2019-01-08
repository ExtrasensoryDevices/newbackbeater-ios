//
//  Settings.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import Foundation
import ObjectiveC


extension BBSetting {
   
    
    private struct AssociatedKey {
        static var strikesFilter = "strikesFilterNum"
        static var timeSignature = "timeSignatureNum"
    }
    
    private struct AssociatedValueDefault {
        static var strikesFilter = 2
        static var timeSignature = 2
    }
    
    
    var strikesFilter: Int {
        get {
            if let val = objc_getAssociatedObject(self, &AssociatedKey.strikesFilter) as? NSNumber {
                return val.integerValue
            } else {
                return AssociatedValueDefault.strikesFilter
            }
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.strikesFilter, NSNumber(integer: newValue), UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    var timeSignature: Int {
        get {
            if let val = objc_getAssociatedObject(self, &AssociatedKey.timeSignature) as? NSNumber {
                return val.integerValue
            } else {
                return AssociatedValueDefault.timeSignature
            }
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.timeSignature, NSNumber(integer: newValue), UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
}
