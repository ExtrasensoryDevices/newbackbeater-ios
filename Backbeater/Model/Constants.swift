//
//  Constants.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-04.
//

import UIKit


@objcMembers
public class Constants: NSObject {
    //public static let DEFAULT_SENSITIVITY:Int = 100
    public static let DEFAULT_TEMPO:Int       = 120
    
    public static let MAX_TEMPO:Int           = 200
    public static let MIN_TEMPO:Int           =  20
    
    public static let IDLE_TIMEOUT:Double     =  10.0
}

public var appVersion:String {
    let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    let buldNumber    = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? ""
    return "\(versionNumber) (\(buldNumber))"
}


// urls
let HELP_URL = "http://backbeater.com/apphelp/?app=ios"
let BUY_SENSOR_URL = "http://backbeater.com/appbuy/?app=ios"
