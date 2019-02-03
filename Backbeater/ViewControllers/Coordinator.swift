//
//  Coordinator.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-08.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

protocol HelpPresenter: class {
    func showHelp(url: String)
}

enum MetronomeState: Int {
    case on  = 1
    case off = 0
}


class Coordinator {
    // protocols
    private weak var helpPresenter:HelpPresenter?
    
    
    private struct LocalConstants { // TODO: rename
        static let strikesWindowValues = [2, 3, 4, 5]
        static let timeSignatureValues = [1, 2, 3, 4]
        static let soundFiles = ["sideStick.wav", "stick.wav", "metronome.wav", "surprise.wav"]
    }
    
    // side selected bar
    private var sensitivity: Int {  // [0..100]
        didSet {
            if sensitivity != oldValue {
                UserDefaults.set(integer: sensitivity, for: .sensitivity)
                Flurry.logEvent(.sensitivityValueChanged, value: sensitivity)
            }
        }
    }
    
    private var strikesWindowIdx: Int {  // [0..3]
        didSet {
            if strikesWindowIdx != oldValue {
                UserDefaults.set(integer: strikesWindowIdx, for: .strikesWindowIndex)
                Flurry.logEvent(.strikesWindowValueChanged,
                                value: LocalConstants.strikesWindowValues[strikesWindowIdx])
            }
        }
    }
    
    private var timeSignatureIdx: Int {  // [0..3]
        didSet {
            if timeSignatureIdx != oldValue {
                UserDefaults.set(integer: timeSignatureIdx, for: .timeSignatureIndex)
                Flurry.logEvent(.timeSignatureValueChanged,
                                value: LocalConstants.timeSignatureValues[timeSignatureIdx])
            }
        }
    }
    
    private var metronomeSoundIdx: Int {   // [0..3]
        didSet {
            if metronomeSoundIdx != oldValue {
                UserDefaults.set(integer: metronomeSoundIdx, for: .metronomeSoundIndex)
            }
        }
    }

    private var soundUrl:URL {
        return URL(fileURLWithPath: LocalConstants.soundFiles[metronomeSoundIdx])
    }

    
    
    // current state / user input
    private var sensorIn:Bool = false
    
    
    private var metronomeState: MetronomeState {
        didSet {
            if metronomeState != oldValue {
                Flurry.logEvent(.metronomeStateChanged, value: metronomeState.rawValue )
            }
        }
    }
    
    private var metronomeTempo:  Int {
        didSet {
            if metronomeTempo != oldValue {
                // TODO: add validation somewhere before assigning
                UserDefaults.set(integer: metronomeTempo, for: .metronomeTempo)
                Flurry.logEvent(.metronomeTempoValueChanged, value: metronomeTempo)
            }
        }
    }

    var lastPlayedTempo: Int {
        get {
            return UserDefaults.integer(for: .lastPlayedTempo) ?? Constants.DEFAULT_TEMPO
        }
        
        set {
            UserDefaults.set(integer: newValue, for: .lastPlayedTempo)
        }
    }
    
    private var songList: Array<SongTempo> = []

    
    
    init(helpPresenter:HelpPresenter) {
        
        metronomeState = .off
        
        // init form saved values
        sensitivity = UserDefaults.integer(for: .sensitivity) ?? 100
        strikesWindowIdx  = UserDefaults.integer(for: .strikesWindowIndex)  ?? 0
        timeSignatureIdx  = UserDefaults.integer(for: .timeSignatureIndex)  ?? 0
        metronomeSoundIdx = UserDefaults.integer(for: .metronomeSoundIndex) ?? 0

        metronomeTempo = UserDefaults.integer(for: .metronomeTempo) ?? Constants.DEFAULT_TEMPO
        
        //  TODO: Init songList from UserDefaults
        
        // protocols
        self.helpPresenter = helpPresenter
    }
}


extension Coordinator: SidebarDelegate {
    
    func readyToRender(_ sidebar: Sidebar) {
        sidebar.setupOptions(strikesWindowValues: LocalConstants.strikesWindowValues,
                             timeSignatureValues: LocalConstants.timeSignatureValues)
        
        sidebar.displayValuesFromLastSession(sensitivityIdx:    sensitivity,
                                             metronomeSoundIdx: metronomeSoundIdx,
                                             strikesWindowIdx:  strikesWindowIdx,
                                             timeSignatureIdx:  timeSignatureIdx)
    }
    
    func helpRequested() {
        // TODO
       // HelpPresenter.showHelp(url: HELP_URL)
    }
    
    func sensitivityChanged(newValue: Int) {
        guard newValue > 0 && newValue < 100 else {
            return
        }
        sensitivity = newValue
    }
    
    func metronomeSoundChanged(newIndex: Int) {
        guard LocalConstants.soundFiles.isSafe(index: newIndex) else {
            return
        }
        metronomeSoundIdx = newIndex
    }
    
    func strikesWindowChanged(newIndex: Int) {
        guard LocalConstants.strikesWindowValues.isSafe(index: newIndex) else {
            return
        }
        strikesWindowIdx = newIndex
    }
    
    func timeSignatureChanged(newIndex: Int) {
        guard LocalConstants.timeSignatureValues.isSafe(index: newIndex) else {
            return
        }
        timeSignatureIdx = newIndex
    }
    
    
}
