//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//

import UIKit


class DisplayViewController: UIViewController, SongListViewControllerDelegate, CentralRingDelegate {

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
    
    
    var songList:[SongTempo]?
    var selectedIndex:Int = 0 {
        didSet {
            updateSongListView()
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()

        registerForNotifications()
        
        strikesWindowQueue = WindowQueue(capacity:Settings.sharedInstance().strikesWindow)
        centralRing.delegate = self
        
        metronomeTempoView.value = Settings.sharedInstance().metronomeTempo
        println("metronomeIsOn: \(Settings.sharedInstance().metronomeIsOn)")
        metronomeTempoView.isOn = Settings.sharedInstance().metronomeIsOn
        
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
        metronomeTempoView.isOn = false
        centralRing.handleMetronomeState()
    }
    
    func applicationWillResignActive() {
        Settings.sharedInstance().metronomeIsOn = false
        Settings.sharedInstance().saveState()
    }
    
    
    
    func registerForNotifications() {
        let settings = Settings.sharedInstance()
        settings.addObserver(self, forKeyPath: "sensorIn", options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "strikesWindowSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "timeSignatureSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "metronomeSoundSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name:UIApplicationWillResignActiveNotification, object: nil)

    }
    
    deinit {
        let settings = Settings.sharedInstance()
        settings.removeObserver(self, forKeyPath: "sensorIn")
        settings.removeObserver(self, forKeyPath: "strikesWindowSelectedIndex")
        settings.removeObserver(self, forKeyPath: "timeSignatureSelectedIndex")
        settings.removeObserver(self, forKeyPath: "metronomeSoundSelectedIndex")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "sensorIn":
            println("\nsensorIn: \(Settings.sharedInstance().sensorIn)")
            updateSensorView()
        case "strikesWindowSelectedIndex":
            println("\nwindow: \(Settings.sharedInstance().strikesWindow)")
            strikesWindowQueue.capacity = Settings.sharedInstance().strikesWindow
        case "timeSignatureSelectedIndex":
            println("\ntimeSignature: \(Settings.sharedInstance().timeSignature)")
        case "metronomeSoundSelectedIndex":
            // TODO:switch metronome sound
//            println("\nmetronomeSound: \(Settings.sharedInstance().metronomeSound)")
            break
        default:
            break
            
        }
    }
    
    @IBAction func metronomeTempoValueChanged(sender: NumericStepper) {
        Settings.sharedInstance().metronomeTempo = metronomeTempoView.value
    }
    
    @IBAction func metronomeTempoPressed(sender: NumericStepper) {
        Settings.sharedInstance().metronomeIsOn = sender.isOn
    }
    
    
    
    
   // MARK: - BPM processing
    
    
    
    func centralRingFoundTapBPM(bpm: Float64) {
        processBPM(bpm)
    }
    
    func processBPM(bpm: Float64){
        let multiplier = Settings.sharedInstance().metronomeIsOn ? 1 : Float64(Settings.sharedInstance().timeSignature)
        
        let tempo = Int(bpm * multiplier)
        
        let cpt = strikesWindowQueue.enqueue(tempo).average
        
        centralRing.displayCPT(cpt, instantTempo: Int(tempo))
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
            metronomeTempoView.value = songList![selectedIndex].tempoValue
            songListBottomLayoutConstraint.constant = 0
        } else {   // hide
            songListBottomLayoutConstraint.constant = -songListView.bounds.height / 2
        }
        songNameLabel.text = songList?[selectedIndex].songName ?? ""
        
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
        selectedIndex  = selectedIndex >= 1 ? selectedIndex-1 : songList!.count-1
    }

    @IBAction func didTapNextButton(sender: AnyObject) {
        selectedIndex  = selectedIndex < songList!.count-1 ? selectedIndex+1 : 0
    }
    
    func songListViewControllerDidReturnSongList(songList: [SongTempo]?, updated: Bool) {
        if updated {
            self.songList = songList
            selectedIndex = 0
        }
    }
    
    
    
}
