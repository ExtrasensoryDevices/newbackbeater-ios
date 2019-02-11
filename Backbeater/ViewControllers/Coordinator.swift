//
//  Coordinator.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-08.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation
import AVFoundation
import Flurry_iOS_SDK

// MARK: - Constants

struct Tempo {
    static let min:Int       =  20
    static let max:Int       = 200
    static let `default`:Int = 120

    static func normalized(value: Int) -> Int {
        return value.normalized(min: Tempo.min, max: Tempo.max)
    }
}

struct Sensitivity {
    static let min:Int       =   0
    static let max:Int       = 100
    static let `default`:Int = 100
    
    static func normalized(value: Int) -> Int {
        return value.normalized(min: Sensitivity.min, max: Sensitivity.max)
    }
}


// MARK: - Protocols


protocol WebPagePresenter: class {
    func showWebPage(url: String)
}

protocol CoordinatorDelegate: class {
    func setupView(lastPlayedTempo: Int, metronomeTempo: Int, sensorDetected: Bool, sound: URL)
    func stopMetronome()
    func stopAnimation()
    func updateMetronomeState(metronomeState: MetronomeState)
    func updateSensorState(sensorDetected:Bool)
    func setSound(url:URL)
    func display(cpt:Int, timeSignature: Int, metronomeState:MetronomeState)
    func handleFirstStrike()
    func showMicrophonePermissionAlert()
}


// MARK: - Structs and Enums


enum MetronomeState {
    case on(tempo:Int)
    case off(tempo:Int)
    
    var tempo: Int {
        switch self {
            case .on (let tempo): return tempo
            case .off(let tempo): return tempo
        }
    }
    
    var isOn:Bool {
        switch self {
            case .on:  return true
            case .off: return false
        }
    }
}


// MARK: - Coordinator


class Coordinator {

    private weak var webPagePresenter:WebPagePresenter?
    private weak var output: CoordinatorDelegate?
    
    struct Constants {
        static let strikesWindowValues = [2, 3, 4, 5]
        static let timeSignatureValues = [1, 2, 3, 4]
        static let soundFiles = ["sideStick.wav", "stick.wav", "metronome.wav", "surprise.wav"]
        static let idleTimeout:Double = 10.0
    }
    
    // side selected bar
    private var sensitivity: Int {  // [0..100]
        didSet {
            if sensitivity != oldValue {
                soundProcessor?.setSensivity(sensitivity)
                UserDefaults.set(integer: sensitivity, for: .sensitivity)
                Flurry.logEvent(.sensitivityValueChanged, value: sensitivity)
            }
        }
    }
    
    private var strikesWindowIdx: Int {  // [0..3]
        didSet {
            if strikesWindowIdx != oldValue {
                strikesWindowQueue.capacity = strikesWindow
                UserDefaults.set(integer: strikesWindowIdx, for: .strikesWindowIndex)
                Flurry.logEvent(.strikesWindowValueChanged, value: strikesWindow)
            }
        }
    }
    
    private var timeSignatureIdx: Int {  // [0..3]
        didSet {
            if timeSignatureIdx != oldValue {
                UserDefaults.set(integer: timeSignatureIdx, for: .timeSignatureIndex)
                Flurry.logEvent(.timeSignatureValueChanged, value: timeSignature)
            }
        }
    }
    
    private var metronomeSoundIdx: Int {   // [0..3]
        didSet {
            if metronomeSoundIdx != oldValue {
                output?.setSound(url: soundUrl)
                UserDefaults.set(integer: metronomeSoundIdx, for: .metronomeSoundIndex)
            }
        }
    }

    private var strikesWindow: Int {
        return Constants.strikesWindowValues[strikesWindowIdx]
    }
    
    private var timeSignature: Int {
        return Constants.timeSignatureValues[timeSignatureIdx]
    }
    
    private var soundUrl:URL {
        let path = Bundle.main.path(forResource: Constants.soundFiles[metronomeSoundIdx], ofType: nil)!
        return URL(fileURLWithPath: path)
    }

    
    
    // current state / user input
    private var sensorDetected:Bool = false
    
    
    private var metronomeState: MetronomeState {
        didSet {
            switch (metronomeState, oldValue) {
            case (.on(let newTempo), .on(let oldTempo)):
                if newTempo != oldTempo {
                    Flurry.logEvent(.metronomeTempoValueChanged, value: newTempo)
                }
            case (.off, .off):
                break
            case (.on, .off):
                Flurry.logEvent(.metronomeStateChanged, value: 1 ) // is ON
            case (.off, .on):
                Flurry.logEvent(.metronomeStateChanged, value: 0 ) // is OFF
            }
            
            if (metronomeState.tempo !=  oldValue.tempo) {
                UserDefaults.set(integer: metronomeState.tempo , for: .metronomeTempo)
            }
        }
    }

    var lastPlayedTempo: Int {
        get { return UserDefaults.integer(for: .lastPlayedTempo) ?? Tempo.default }
        set { UserDefaults.set(integer: newValue, for: .lastPlayedTempo) }
    }
    
    init(webPagePresenter:WebPagePresenter, output: CoordinatorDelegate) {
        
        // init form saved values
        sensitivity = UserDefaults.integer(for: .sensitivity) ?? Sensitivity.default
        strikesWindowIdx  = UserDefaults.integer(for: .strikesWindowIndex)  ?? Constants.strikesWindowValues.count-1
        timeSignatureIdx  = UserDefaults.integer(for: .timeSignatureIndex)  ?? 0
        metronomeSoundIdx = UserDefaults.integer(for: .metronomeSoundIndex) ?? 0

        let metronomeTempo = UserDefaults.integer(for: .metronomeTempo) ?? Tempo.default
        metronomeState = .off(tempo: metronomeTempo)
        
        // Sound
        soundProcessor = SoundProcessor(idleTimeout: Constants.idleTimeout)
        soundProcessor.delegate = self;
        strikesWindowQueue = WindowQueue(capacity: strikesWindow)
        
        // protocols
        self.webPagePresenter = webPagePresenter
        self.output = output
        
        registerForNotifications()
    }
    
    
    // MARK: - NotificationCenter observers
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name:UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name:UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        output?.stopMetronome()
    }
    
    @objc func applicationDidEnterBackground() {
        // turn off metronome
        let tempo = metronomeState.tempo
        metronomeState = .off(tempo:tempo)
        output?.stopMetronome()
    }
    

    // MARK: - Sound Processing
    
    private var strikesWindowQueue:WindowQueue!
    private var soundProcessor: SoundProcessor!
    private var lastStrikeTime:UInt64 = 0;

    var currentTempo = 0 {
        didSet {
            lastPlayedTempo = currentTempo
        }
    }
    
    private func processBPM(_ bpm: Float64){
        let timeSignature = self.timeSignature
        let multiplier = metronomeState.isOn ? 1 :  Float64(timeSignature)
        let instantTempo:Float64 = bpm * multiplier
        
        currentTempo = strikesWindowQueue.enqueue(instantTempo).average
        
        output?.display(cpt: currentTempo, timeSignature: timeSignature, metronomeState: metronomeState)
        
        if !metronomeState.isOn {
            delay(Constants.idleTimeout, callback: { [weak self] () -> () in
                guard let self = self else { return }
                
                let now:UInt64 = PublicUtilityWrapper.caHostTimeBase_GetCurrentTime()
                let timeElapsedNs:UInt64 = PublicUtilityWrapper.caHostTimeBase_AbsoluteHostDelta(toNanos: now, oldTapTime: self.lastStrikeTime)
                
                let delayFator:Float64 = 0.1
                
                let timeElapsedInSec:Float64 = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
                if timeElapsedInSec > Constants.idleTimeout {
                    if !self.metronomeState.isOn {
                        self.strikesWindowQueue.clear()
                        self.output?.stopAnimation()
                    }
                }
            })
        }
        lastStrikeTime = PublicUtilityWrapper.caHostTimeBase_GetCurrentTime()
    }
    
    
    // MARK: - Permissions
    private func checkMicrophonePermission() {
        // ww know that sensor is plugged in
        let audioSession = AVAudioSession.sharedInstance()
        
        switch audioSession.recordPermission {
        case .denied:
            output?.showMicrophonePermissionAlert()
        case .granted:
            startAudioSession()
        case .undetermined :
            audioSession.requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.startAudioSession()
                    }
                }
            }
        }
    }
    
    private func startAudioSession() {
        // after permission granted
        sensorDetected = true
        output?.updateSensorState(sensorDetected: true)
        try? soundProcessor.start(sensitivity)
    }
    
    
}



// MARK: - DisplayViewControllerDelegate

extension Coordinator: DisplayViewControllerDelegate {
    func readyToRender() {
        output?.setupView(lastPlayedTempo: lastPlayedTempo,
                          metronomeTempo: metronomeState.tempo,
                          sensorDetected: sensorDetected,
                          sound: soundUrl)
    }
    
    
    func foundTap(bpm: Float64) {
        processBPM(bpm)
    }
    
    func metronomeStateChanged(_ newValue: MetronomeState) {
        let newTempo = newValue.tempo
        guard (Tempo.min...Tempo.max).contains(newTempo) else {
            return
        }
        metronomeState = newValue
        output?.updateMetronomeState(metronomeState: metronomeState)
    }
    
    func startMetronomeWithCurrentTempo() {
        if case let .on(metronomeTempo) = metronomeState, currentTempo == metronomeTempo {
            // do nothing
        } else {
            metronomeState = .on(tempo: currentTempo)
            output?.updateMetronomeState(metronomeState: metronomeState)
        }
        
    }
    
    func didDetectFirstTap() {
        output?.handleFirstStrike()
    }
    
}


// MARK: - SoundProcessorDelegate

extension Coordinator: SoundProcessorDelegate {
    
    func soundProcessorDidDetectSensor(in sensorIn: Bool) {
        
        if sensorIn {
            checkMicrophonePermission()
        } else {
            sensorDetected = false
            output?.updateSensorState(sensorDetected: false)
            try? soundProcessor.stop()
        }
    }
    
    func soundProcessorDidDetectFirstStrike() {
        output?.handleFirstStrike()
    }
    
    func soundProcessorDidFindBPM(_ bpm: Float64) {
        processBPM(bpm)
    }
}


// MARK: - SidebarDelegate

extension Coordinator: SidebarDelegate {
    
    func readyToRender(_ sidebar: Sidebar) {
        sidebar.setupOptions(strikesWindowValues: Constants.strikesWindowValues,
                             timeSignatureValues: Constants.timeSignatureValues)
        
        sidebar.displayValuesFromLastSession(sensitivity:    sensitivity,
                                             metronomeSoundIdx: metronomeSoundIdx,
                                             strikesWindowIdx:  strikesWindowIdx,
                                             timeSignatureIdx:  timeSignatureIdx)
    }
    
    func helpRequested() {
        webPagePresenter?.showWebPage(url: HELP_URL)
    }
    
    func sensitivityChanged(newValue: Int) {
        guard newValue > 0 && newValue < 100 else {
            return
        }
        sensitivity = newValue
        soundProcessor?.setSensivity(sensitivity)
    }
    
    func metronomeSoundChanged(newIndex: Int) {
        guard Constants.soundFiles.isSafe(index: newIndex) else {
            return
        }
        metronomeSoundIdx = newIndex
    }
    
    func strikesWindowChanged(newIndex: Int) {
        guard Constants.strikesWindowValues.isSafe(index: newIndex) else {
            return
        }
        strikesWindowIdx = newIndex
    }
    
    func timeSignatureChanged(newIndex: Int) {
        guard Constants.timeSignatureValues.isSafe(index: newIndex) else {
            return
        }
        timeSignatureIdx = newIndex
    }
}

