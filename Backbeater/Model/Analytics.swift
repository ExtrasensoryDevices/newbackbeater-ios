//
//  Analytics.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-08.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK


let FLURRY_API_KEY = "DPF2V399HZKGGTKSG5Q2"

enum FlurryEvent: String {
    case appOpened = "app_opened"
    case appClosed = "app_closed"
    
    case tempoListCreated = "tempo_list_created"
    
    case metronomeStateChanged      = "metronome_state_changed"
    case sensitivityValueChanged    = "sensitivity_value_changed"
    case strikesWindowValueChanged  = "strikes_window_value_changed"
    case timeSignatureValueChanged  = "time_signature_value_changed"
    case metronomeTempoValueChanged = "metronome_tempo_value_changed"
}

extension Flurry {
    
    static func logEvent(_ event: FlurryEvent) {
        Flurry.logEvent(event.rawValue)
    }
    
    static func logEvent(_ event: FlurryEvent, value: Int) {
        Flurry.logEvent(event.rawValue, withParameters: ["value" : value])
    }
    
    static func logEvent(_ event: FlurryEvent, params:[String: Any]) {
        Flurry.logEvent(event.rawValue, withParameters: params)
    }
    
}

