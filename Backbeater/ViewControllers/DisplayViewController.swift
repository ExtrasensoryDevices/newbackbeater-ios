//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-10.
//

import UIKit


class DisplayViewController: UIViewController, SongListViewControllerDelegate, CentralRingDelegate, SoundProcessorDelegate {

    @IBOutlet weak var centralRing: CentralRing!
    
    @IBOutlet weak var songListView: UIView!
    
    @IBOutlet weak var getSensorView: UILabel!
    @IBOutlet weak var setTempoView: UIView!
    
    @IBOutlet weak var metronomeTempoView: NumericStepper!
    
    @IBOutlet weak var prevSongButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var hamButton: UIButton!
    @IBOutlet weak var songListBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var centralRingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var centralRingBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var getSensorBottomConstraint: NSLayoutConstraint!
    
    
    var strikesWindowQueue:WindowQueue!
    
    var soundProcessor: SoundProcessor!
    
    var currentTempo = 0 {
        didSet {
            Settings.sharedInstance().lastPlayedTempo = currentTempo
        }
    }

    
    var songList:[SongTempo]?
    var selectedSongIndex:Int = 0 {
        didSet {
            updateSongListView()
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()

        registerForNotifications()
        
        
        soundProcessor = SoundProcessor.sharedInstance()
        soundProcessor.delegate = self;
        Settings.sharedInstance().sensorIn = soundProcessor.sensorIn
        
        strikesWindowQueue = WindowQueue(capacity:Settings.sharedInstance().strikesWindow)
        centralRing.delegate = self
        
        metronomeTempoView.value = Settings.sharedInstance().metronomeTempo
        metronomeTempoView.isOn = Settings.sharedInstance().metronomeIsOn
        
        
        let image = UIImage(named:"tempo_list")!.withRenderingMode(.alwaysTemplate)
        hamButton.setImage(image, for: UIControl.State())
        
        songList = restoreSongTempoList(Settings.sharedInstance().songList as? [NSDictionary])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSensorView()
        updateSongListView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        view.backgroundColor = ColorPalette.black.color()
        
        setTempoView.drawBorder()
        setTempoView.backgroundColor = ColorPalette.black.color()
        setTempoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DisplayViewController.didTapSetTempoButton)))
        
        metronomeTempoView.font = Font.FuturaBook.get(33)
        metronomeTempoView.bgrColor = ColorPalette.black.color()

        getSensorView.drawBorder()
        getSensorView.clipsToBounds = true
        getSensorView.backgroundColor = ColorPalette.pink.color()
        getSensorView.font = Font.FuturaDemi.get(14)
        getSensorView.textColor = ColorPalette.black.color()
        
        centralRing.translatesAutoresizingMaskIntoConstraints = false
        
        if ScreenUtil.screenSizeClass == .xsmall {
            centralRingTopConstraint.constant = 0
            centralRingBottomConstraint.constant = 0
        }
        
        
    }
    
    @objc func applicationWillEnterForeground() {
//        metronomeTempoView.isOn = Settings.sharedInstance().metronomeIsOn
    }
    
    @objc func applicationDidBecomeActive() {
        centralRing.handleMetronomeState()
    }
    
    @objc func applicationWillResignActive() {
//        Settings.sharedInstance().metronomeIsOn = false
//        Settings.sharedInstance().saveState()
    }
    
    @objc func applicationDidEnterBackground() {
        Settings.sharedInstance().metronomeIsOn = false
        metronomeTempoView.isOn = false
        Settings.sharedInstance().saveState()
    }
    
    
    
    func registerForNotifications() {
        let settings = Settings.sharedInstance()
        settings?.addObserver(self, forKeyPath: "strikesWindowSelectedIndex", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DisplayViewController.applicationWillEnterForeground), name:UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DisplayViewController.applicationDidBecomeActive), name:UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DisplayViewController.applicationWillResignActive), name:UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DisplayViewController.applicationDidEnterBackground), name:UIApplication.didEnterBackgroundNotification, object: nil)

    }
    
    deinit {
        let settings = Settings.sharedInstance()
        settings?.removeObserver(self, forKeyPath: "strikesWindowSelectedIndex")
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    func observeValue(forKeyPath keyPath: String, of object: Any, change: [AnyHashable: Any], context: UnsafeMutableRawPointer) {
        switch keyPath {
        case "strikesWindowSelectedIndex":
            strikesWindowQueue.capacity = Settings.sharedInstance().strikesWindow
        default:
            break
            
        }
    }
    
    @IBAction func didTapGetSensorButton(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: BUY_SENSOR_URL)!)
    }
    
    @objc func didTapSetTempoButton() {
        metronomeTempoView.value = currentTempo
        metronomeTempoView.isOn = true
        Settings.sharedInstance().metronomeIsOn = true
    }
    
    @IBAction func didTapSongName(_ sender: AnyObject) {
        if let tempo  = songList?[selectedSongIndex].tempoValue {
            Settings.sharedInstance().metronomeTempo = tempo
            metronomeTempoView.value = tempo
        }
    }
    
    //MARK: - NumericStepper delegate
    
    @IBAction func metronomeTempoValueChanged(_ sender: NumericStepper) {
        let newValue = metronomeTempoView.value
        Settings.sharedInstance().metronomeTempo = newValue
    }
    
    @IBAction func metronomeTempoPressed(_ sender: NumericStepper) {
        if Settings.sharedInstance().metronomeTempo != metronomeTempoView.value {
            Settings.sharedInstance().metronomeTempo = metronomeTempoView.value
        }
        Settings.sharedInstance().metronomeIsOn = sender.isOn
    }
    
    
    
    
   // MARK: - BPM processing
    
    
    
    func centralRingFoundTapBPM(_ bpm: Float64) {
        processBPM(bpm)
    }
    
    
    
    var lastStrikeTime:UInt64 = 0;
    func processBPM(_ bpm: Float64){
        let multiplier = Settings.sharedInstance().metronomeIsOn ? 1 : Float64(Settings.sharedInstance().timeSignature)
        
        let tempo:Float64 = bpm * multiplier
        
        currentTempo = strikesWindowQueue.enqueue(tempo).average
        
        centralRing.displayCPT(currentTempo, instantTempo: Int(tempo))
        
        
        if !Settings.sharedInstance().metronomeIsOn {
            self.delay(Constants.IDLE_TIMEOUT, callback: { () -> () in
                let now:UInt64 = PublicUtilityWrapper.caHostTimeBase_GetCurrentTime()
                let timeElapsedNs:UInt64 = PublicUtilityWrapper.caHostTimeBase_AbsoluteHostDelta(toNanos: now, oldTapTime: self.lastStrikeTime)
                
                let delayFator:Float64 = 0.1
                
                let timeElapsedInSec:Float64 = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
                if timeElapsedInSec > Constants.IDLE_TIMEOUT {
                    if !Settings.sharedInstance().metronomeIsOn {
                        self.strikesWindowQueue.clear()
                        self.centralRing.clear()
                    }
                }
            })
        }
        lastStrikeTime = PublicUtilityWrapper.caHostTimeBase_GetCurrentTime()
        
    }
    
    // MARK: - SoundProcessorDelegate
    
    func soundProcessorDidDetectSensor(in sensorIn: Bool) {
        Settings.sharedInstance().sensorIn = sensorIn
        updateSensorView()
        
        //fixme try-catch
        do {
            if sensorIn {
                try soundProcessor.start()
            } else {
                try soundProcessor.stop()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func soundProcessorDidDetectFirstStrike() {
        centralRing.runPulseAnimationOnly()
    }
    
    func soundProcessorDidFindBPM(_ bpm: Float64) {
        processBPM(bpm)
    }
    
    
    func updateSensorView() {
        let sensorIn = Settings.sharedInstance().sensorIn
        getSensorView.isHidden = sensorIn
        setTempoView.isHidden = !sensorIn
    }
    
    

    
    // MARK: - Song list
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let songListVC = segue.destination as? SongListViewController {
            songListVC.delegate = self
            songListVC.setSongList(songList)
        } else if let webVC = segue.destination as? WebViewController {
            webVC.url = BUY_SENSOR_URL
        }
    }
    
    func updateSongListView() {
        
        var hideButtons = true
        var hideLabel = true
        if let count = songList?.count , count > 0 { // show
            hideButtons = count <= 1
            hideLabel = count < 1
            metronomeTempoView.value = songList![selectedSongIndex].tempoValue
            songListBottomLayoutConstraint.constant = 0
            hamButton.tintColor = UIColor.white
        } else {   // hide
            songListBottomLayoutConstraint.constant = -songListView.bounds.height / 2
            hamButton.tintColor = ColorPalette.grey.color()
        }
        songNameLabel.text = songList?[selectedSongIndex].songName ?? ""
        
        prevSongButton.isHidden = hideButtons
        nextSongButton.isHidden = hideButtons
        songNameLabel.isHidden = hideLabel
        
    }
    @IBAction func didTapPrevButton(_ sender: AnyObject) {
        selectedSongIndex  = selectedSongIndex >= 1 ? selectedSongIndex-1 : songList!.count-1
    }

    @IBAction func didTapNextButton(_ sender: AnyObject) {
        selectedSongIndex  = selectedSongIndex < songList!.count-1 ? selectedSongIndex+1 : 0
    }
    
    func songListViewControllerDidReturnSongList(_ songList: [SongTempo]?, updated: Bool) {
        if updated {
            self.songList = songList
            selectedSongIndex = 0
        }
    }
    
    
    
}
