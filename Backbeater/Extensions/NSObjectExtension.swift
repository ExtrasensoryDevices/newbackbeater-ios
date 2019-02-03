//
//  AnyObjectExtensions.swift
//
//  Created by Alina Kholcheva on 10/11/14.
//

extension NSObject {
    func delay(_ delay:Double, callback:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: callback)
    }
}
