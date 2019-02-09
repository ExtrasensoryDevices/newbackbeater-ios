//
//  Constants.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-04.
//

import UIKit

public var appVersion:String {
    let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    let buldNumber    = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? ""
    return "\(versionNumber) (\(buldNumber))"
}


// urls
let HELP_URL = "http://backbeater.com/apphelp/?app=ios"
let BUY_SENSOR_URL = "http://backbeater.com/appbuy/?app=ios"


func delay(_ delay:Double, callback:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: callback)
}
