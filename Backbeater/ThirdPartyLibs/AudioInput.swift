//
//  AudioInput.swift
//

import AVFoundation

typealias AudioInputCallback = (
    _ timeStamp: Double,
    _ numberOfFrames: Int,
    _ samples: [Float]
    ) -> Void

/// AudioInput sets up an audio input session and notifies when new buffer data is available.
@objc class AudioInput: NSObject {
    
    private(set) var audioUnit: AudioUnit? = nil
    let audioSession : AVAudioSession = AVAudioSession.sharedInstance()
    private(set) var sampleRate: Float
    private(set) var numberOfChannels: Int
    
    /// When true, performs DC offset rejection on the incoming buffer before invoking the audioInputCallback.
    var shouldPerformDCOffsetRejection: Bool = false
    
    private let outputBus: UInt32 = 0
    private let inputBus: UInt32 = 1
    private var audioInputCallback: AudioInputCallback!
    
    /// Instantiate a AudioInput.
    /// - Parameter audioInputCallback: Invoked when audio data is available.
    /// - Parameter sampleRate: The sample rate to set up the audio session with.
    /// - Parameter numberOfChannels: The number of channels to set up the audio session with.
    @objc public init(audioInputCallback callback: @escaping AudioInputCallback, sampleRate: Float = 44100.0, numberOfChannels: Int = 2) {
        
        self.sampleRate = sampleRate
        self.numberOfChannels = numberOfChannels
        audioInputCallback = callback
    }
    
    /// Start recording. Prompts for access to microphone if necessary.
    @objc public func startRecording() {
        do {
            
            if self.audioUnit == nil {
                setupAudioSession()
                setupAudioUnit()
            }
            
            try self.audioSession.setActive(true)
            var osErr: OSStatus = 0
            
            osErr = AudioUnitInitialize(self.audioUnit!)
         //??   assert(osErr == noErr, "*** AudioUnitInitialize err \(osErr)")
            osErr = AudioOutputUnitStart(self.audioUnit!)
         //??   assert(osErr == noErr, "*** AudioOutputUnitStart err \(osErr)")
        } catch {
            print("*** startRecording error: \(error)")
        }
    }
    
    /// Stop recording.
    @objc public func stopRecording() {
        do {
            if self.audioUnit != nil {
                var osErr: OSStatus = 0
                
                AudioOutputUnitStop(self.audioUnit!)
                
                osErr = AudioUnitUninitialize(self.audioUnit!)
                assert(osErr == noErr, "*** AudioUnitUninitialize err \(osErr)")
            }
            try self.audioSession.setActive(false)
        } catch {
            print("*** error: \(error)")
        }
    }
    
    private let recordingCallback: AURenderCallback = { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
        
        let audioInput = unsafeBitCast(inRefCon, to: AudioInput.self)
        var osErr: OSStatus = 0
        
        // We've asked CoreAudio to allocate buffers for us, so just set mData to nil and it will be populated on AudioUnitRender().
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: UInt32(audioInput.numberOfChannels),
                mDataByteSize: 4,
                mData: nil))
        
        osErr = AudioUnitRender(audioInput.audioUnit!,
            ioActionFlags,
            inTimeStamp,
            inBusNumber,
            inNumberFrames,
            &bufferList)
        assert(osErr == noErr, "*** AudioUnitRender err \(osErr)")
        
        // Move samples from mData into our native [Float] format.
        // (There's probably an better way to do this using UnsafeBufferPointer but I couldn't make it work.)
        var monoSamples = [Float]()
        let ptr = bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self)
        monoSamples.append(contentsOf: UnsafeBufferPointer(start: ptr, count: Int(inNumberFrames)))
        
        if audioInput.shouldPerformDCOffsetRejection {
            DCRejectionFilterProcessInPlace(audioData: &monoSamples, count: Int(inNumberFrames))
        }

        audioInput.audioInputCallback(inTimeStamp.pointee.mSampleTime / Double(audioInput.sampleRate), Int(inNumberFrames), monoSamples)
        
        return 0
    }
    
    private func setupAudioSession() {
        
        if !audioSession.availableCategories.contains(AVAudioSession.Category.playAndRecord) {
            print("can't record! bailing.")
            return
        }
        
        do {
            try audioSession.setCategory(.playAndRecord, options: [.mixWithOthers, .allowBluetoothA2DP, .allowAirPlay])
            
            // "Appropriate for applications that wish to minimize the effect of system-supplied signal processing for input and/or output audio signals."
            // NB: This turns off the high-pass filter that CoreAudio normally applies.
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            
            try audioSession.setPreferredSampleRate(Double(sampleRate))
            
            // This will have an impact on CPU usage. .01 gives 512 samples per frame on iPhone. (Probably .01 * 44100 rounded up.)
            try audioSession.setPreferredIOBufferDuration(0.01)
            
            audioSession.requestRecordPermission { (granted) -> Void in
                if !granted {
                    print("*** record permission denied")
                }
            }
        } catch {
            print("*** audioSession error: \(error)")
        }
    }
    
    private func setupAudioUnit() {
        
        var componentDesc:AudioComponentDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO), // Always this for iOS.
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var osErr: OSStatus = 0
        
        // Get an audio component matching our description.
        let component: AudioComponent = AudioComponentFindNext(nil, &componentDesc)!
        //assert(component != nil, "Couldn't find a default component")
        
        // Create an instance of the AudioUnit
        osErr = AudioComponentInstanceNew(component, &audioUnit)
        assert(osErr == noErr, "*** AudioComponentInstanceNew err \(osErr)")
        
        // Enable I/O for input.
        var one:UInt32 = 1
        
        osErr = AudioUnitSetProperty(audioUnit!,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        osErr = AudioUnitSetProperty(audioUnit!,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Output,
            outputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Set format to 32 bit, floating point, linear PCM
        var streamFormatDesc:AudioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate:        Double(sampleRate),
            mFormatID:          kAudioFormatLinearPCM,
            mFormatFlags:       kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved, // floating point data - docs say this is fastest
            mBytesPerPacket:    4,
            mFramesPerPacket:   1,
            mBytesPerFrame:     4,
            mChannelsPerFrame:  UInt32(self.numberOfChannels),
            mBitsPerChannel:    4 * 8,
            mReserved: 0
        )
        
        // Set format for input and output busses
        osErr = AudioUnitSetProperty(audioUnit!,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input, outputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        osErr = AudioUnitSetProperty(audioUnit!,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            inputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Set up our callback.
        var inputCallbackStruct = AURenderCallbackStruct(inputProc: recordingCallback, inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        osErr = AudioUnitSetProperty(audioUnit!,
            AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
            AudioUnitScope(kAudioUnitScope_Global),
            inputBus,
            &inputCallbackStruct,
            UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Ask CoreAudio to allocate buffers for us on render. (This is true by default but just to be explicit about it...)
        osErr = AudioUnitSetProperty(audioUnit!,
            AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
            AudioUnitScope(kAudioUnitScope_Output),
            inputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
    }
}

private func DCRejectionFilterProcessInPlace( audioData: inout [Float], count: Int) {
    
    let defaultPoleDist: Float = 0.975
    var mX1: Float = 0
    var mY1: Float = 0
    
    for i in 0..<count {
        let xCurr: Float = audioData[i]
        audioData[i] = audioData[i] - mX1 + (defaultPoleDist * mY1)
        mX1 = xCurr
        mY1 = audioData[i]
    }
}
