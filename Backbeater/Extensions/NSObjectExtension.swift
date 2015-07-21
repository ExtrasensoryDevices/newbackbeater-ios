//
//  AnyObjectExtensions.swift
//
//  Created by Alina on 10/11/14.
//

extension NSObject {
    func delay(delay:Double, callback:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), callback)
    }
}