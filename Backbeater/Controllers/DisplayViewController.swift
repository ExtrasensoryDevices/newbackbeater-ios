//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
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
    
    var strikesWindowQueue:WindowQueue!
    
    var soundProcessor: SoundProcessor!
    
    var currentTempo = 0

    
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
        println("metronomeIsOn: \(Settings.sharedInstance().metronomeIsOn)")
        metronomeTempoView.isOn = Settings.sharedInstance().metronomeIsOn
        
        
        let image = UIImage(named:"tempo_list")!.imageWithRenderingMode(.AlwaysTemplate)
        hamButton.setImage(image, forState: .Normal)
        
        songList = restoreSongTempoList(Settings.sharedInstance().songList as? [NSDictionary])
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSensorView()
        updateSongListView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        view.backgroundColor = ColorPalette.Black.color()
        
        setTempoView.drawBorder()
        setTempoView.backgroundColor = ColorPalette.Black.color()
        setTempoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapSetTempoButton"))
        
        metronomeTempoView.font = Font.FuturaBook.get(33)
        metronomeTempoView.bgrColor = ColorPalette.Black.color()

        getSensorView.drawBorder()
        getSensorView.clipsToBounds = true
        getSensorView.backgroundColor = ColorPalette.Pink.color()
        getSensorView.font = Font.FuturaDemi.get(14)
        getSensorView.textColor = ColorPalette.Black.color()
        
        centralRing.setTranslatesAutoresizingMaskIntoConstraints(false)
        
    }
    
    func applicationWillEnterForeground() {
//        metronomeTempoView.isOn = Settings.sharedInstance().metronomeIsOn
    }
    
    func applicationDidBecomeActive() {
        centralRing.handleMetronomeState()
    }
    
    func applicationWillResignActive() {
//        Settings.sharedInstance().metronomeIsOn = false
//        Settings.sharedInstance().saveState()
    }
    
    func applicationDidEnterBackground() {
        Settings.sharedInstance().metronomeIsOn = false
        metronomeTempoView.isOn = false
        Settings.sharedInstance().saveState()
    }
    
    
    
    func registerForNotifications() {
        let settings = Settings.sharedInstance()
        settings.addObserver(self, forKeyPath: "strikesWindowSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name:UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name:UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name:UIApplicationDidEnterBackgroundNotification, object: nil)

    }
    
    deinit {
        let settings = Settings.sharedInstance()
        settings.removeObserver(self, forKeyPath: "strikesWindowSelectedIndex")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "strikesWindowSelectedIndex":
            strikesWindowQueue.capacity = Settings.sharedInstance().strikesWindow
        default:
            break
            
        }
    }
    
    @IBAction func didTapGetSensorButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: BUY_SENSOR_URL)!)
    }
    
    func didTapSetTempoButton() {
        metronomeTempoView.value = currentTempo
        Settings.sharedInstance().metronomeIsOn = true
        metronomeTempoView.isOn = true
    }
    
    
    //MARK: - NumericStepper delegate
    
    @IBAction func metronomeTempoValueChanged(sender: NumericStepper) {
        let newValue = metronomeTempoView.value
        Settings.sharedInstance().metronomeTempo = newValue
        if songList != nil {
            songList![selectedSongIndex].tempoValue = newValue
        }
    }
    
    @IBAction func metronomeTempoPressed(sender: NumericStepper) {
        if Settings.sharedInstance().metronomeTempo != metronomeTempoView.value {
            Settings.sharedInstance().metronomeTempo = metronomeTempoView.value
        }
        Settings.sharedInstance().metronomeIsOn = sender.isOn
    }
    
    
    
    
   // MARK: - BPM processing
    
    
    
    func centralRingFoundTapBPM(bpm: Float64) {
        processBPM(bpm)
    }
    
    func processBPM(bpm: Float64){
        let multiplier = Settings.sharedInstance().metronomeIsOn ? 1 : Float64(Settings.sharedInstance().timeSignature)
        
        let tempo = Int(bpm * multiplier)
        
        currentTempo = strikesWindowQueue.enqueue(tempo).average
        Settings.sharedInstance().lastPlayedTempo = currentTempo
        centralRing.displayCPT(currentTempo, instantTempo: Int(tempo))
    }
    
    // MARK: - SoundProcessorDelegate
    
    func soundProcessorDidDetectSensorIn(sensorIn: Bool) {
        Settings.sharedInstance().sensorIn = sensorIn
        updateSensorView()
        
        if sensorIn {
            soundProcessor.start(nil)
        } else {
            soundProcessor.stop(nil)
        }
    }
    
    func soundProcessorDidDetectFirstStrike() {
        centralRing.runPulseAnimationOnly()
    }
    
    func soundProcessorDidFindBPM(bpm: Float64) {
        processBPM(bpm)
    }
    
    // MARK: - Song list
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let songListVC = segue.destinationViewController as? SongListViewController {
            songListVC.delegate = self
            songListVC.setSongList(songList)
        } else if let webVC = segue.destinationViewController as? WebViewController {
            webVC.url = BUY_SENSOR_URL
        }
    }
    
    func updateSongListView() {
        
        var hideButtons = true
        var hideLabel = true
        if let count = songList?.count where count > 0 { // show
            hideButtons = count <= 1
            hideLabel = count < 1
            metronomeTempoView.value = songList![selectedSongIndex].tempoValue
            songListBottomLayoutConstraint.constant = 0
            hamButton.tintColor = UIColor.whiteColor()
        } else {   // hide
            songListBottomLayoutConstraint.constant = -songListView.bounds.height / 2
            hamButton.tintColor = ColorPalette.Grey.color()
        }
        songNameLabel.text = songList?[selectedSongIndex].songName ?? ""
        
        prevSongButton.hidden = hideButtons
        nextSongButton.hidden = hideButtons
        songNameLabel.hidden = hideLabel
        
    }
    
    func updateSensorView() {
        let sensorIn = Settings.sharedInstance().sensorIn
        getSensorView.hidden = sensorIn
        setTempoView.hidden = !sensorIn
        centralRing.listenToTaps = !sensorIn
    }
    

    @IBAction func didTapPrevButton(sender: AnyObject) {
        selectedSongIndex  = selectedSongIndex >= 1 ? selectedSongIndex-1 : songList!.count-1
    }

    @IBAction func didTapNextButton(sender: AnyObject) {
        selectedSongIndex  = selectedSongIndex < songList!.count-1 ? selectedSongIndex+1 : 0
    }
    
    func songListViewControllerDidReturnSongList(songList: [SongTempo]?, updated: Bool) {
        if updated {
            self.songList = songList
            selectedSongIndex = 0
        }
    }
    
    
    
}
