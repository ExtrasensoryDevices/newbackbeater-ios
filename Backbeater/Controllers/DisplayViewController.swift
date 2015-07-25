//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//

import UIKit


class DisplayViewController: UIViewController, SongListViewControllerDelegate, CentralRingDelegate {

    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var logButton: UIButton!
    
    
    @IBOutlet weak var centralRing: CentralRing!
    
    @IBOutlet weak var songListView: UIView!
    
    @IBOutlet weak var getSensorView: UILabel!
    @IBOutlet weak var setTempoView: UIView!
    
    @IBOutlet weak var tempoView: NumericStepper!
    
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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tempoView.value = Settings.sharedInstance().metronomeTempo

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
        
        tempoView.font = Font.FuturaBook.get(33)
        tempoView.bgrColor = ColorPalette.Black.color()

        getSensorView.drawBorder()
        getSensorView.clipsToBounds = true
        getSensorView.backgroundColor = ColorPalette.Pink.color()
        getSensorView.font = Font.FuturaDemi.get(14)
        getSensorView.textColor = ColorPalette.Black.color()
        
        centralRing.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        logButton.selected = false
        logView.hidden = true
    }
    
    
    func registerForNotifications() {
        let settings = Settings.sharedInstance()
        settings.addObserver(self, forKeyPath: "sensorIn", options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "strikesWindowSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "timeSignatureSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "metronomeSoundSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
    }
    
    deinit {
        let settings = Settings.sharedInstance()
        settings.removeObserver(self, forKeyPath: "sensorIn")
        settings.removeObserver(self, forKeyPath: "strikesWindowSelectedIndex")
        settings.removeObserver(self, forKeyPath: "timeSignatureSelectedIndex")
        settings.removeObserver(self, forKeyPath: "metronomeSoundSelectedIndex")
    }
    
    
    // TODO: remove
    @IBAction func didTapShowLog(sender: UIButton) {
        
        if sender.selected {
            sender.selected = false
            logView.hidden = true
        } else {
            sender.selected = true
            logView.hidden = false
        }
    }
    
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "sensorIn":
            logView.text = logView.text + "\nsensorIn: \(Settings.sharedInstance().sensorIn)"
            updateSensorView()
        case "strikesWindowSelectedIndex":
            logView.text = logView.text + "\nwindow: \(Settings.sharedInstance().strikesWindow)"
            strikesWindowQueue.capacity = Settings.sharedInstance().strikesWindow
        case "timeSignatureSelectedIndex":
            logView.text = logView.text + "\ntimeSignature: \(Settings.sharedInstance().timeSignature)"
        case "metronomeSoundSelectedIndex":
            // TODO:switch metronome sound
            logView.text = logView.text + "\nmetronomeSound: \(Settings.sharedInstance().metronomeSound)"
        default:
            break
            
        }
        logView.scrollRangeToVisible(NSMakeRange(count(logView.text)-1, 1))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let songListVC = segue.destinationViewController as? SongListViewController {
            songListVC.delegate = self
            
            //TODO: remove default song list
            songListVC.setSongList(songList ?? [SongTempo(songName:"Song #1", tempoValue: 120),
                SongTempo(songName:"Song #2", tempoValue: 60),
                SongTempo(songName:"Song #3", tempoValue: 90),
                SongTempo(songName:"Song #4", tempoValue: 120),
                SongTempo(songName:"Song #5", tempoValue: 60)])
        } else if let webVC = segue.destinationViewController as? WebViewController {
            webVC.url = BUY_SENSOR_URL
        }
    }
    
    @IBAction func metronomeTempoValueChanged(sender: NumericStepper) {
//        centralRing.metronomeTempo = tempoView.value
        Settings.sharedInstance().metronomeTempo = tempoView.value
    }
    
    @IBAction func metronomeTempoPressed(sender: NumericStepper) {
        Settings.sharedInstance().metronomeIsOn = sender.isOn
    }
    
    
    
    
   // MARK: - BPM processing
    
    
    
    func centralRingFoundTapBPM(bpm: Float64) {
        processBPM(bpm)
    }
    
    func processBPM(bpm: Float64){
        let tempo = Int(bpm * Float64(Settings.sharedInstance().timeSignature))
        
        let cpt = strikesWindowQueue.enqueue(tempo).average
        
        centralRing.displayCpt(cpt, bpm: Int(bpm))
    }
    
    
    
    // MARK: - Song list
    
    func updateSongListView() {
        
        var hideButtons = true
        var hideLabel = true
        if let count = songList?.count where count > 0 { // show
            hideButtons = count <= 1
            hideLabel = count < 1
            tempoView.value = songList![selectedIndex].tempoValue
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
        centralRing.listenToTaps(!sensorIn)
    }
    

    @IBAction func didTapPrevButton(sender: AnyObject) {
        println("didTapPrevButton")
        selectedIndex  = selectedIndex >= 1 ? selectedIndex-1 : songList!.count-1
    }

    @IBAction func didTapNextButton(sender: AnyObject) {
        println("didTapNextButton")
        selectedIndex  = selectedIndex < songList!.count-1 ? selectedIndex+1 : 0
    }
    
    func songListViewControllerDidReturnSongList(songList: [SongTempo]?, updated: Bool) {
        if updated {
            self.songList = songList
            selectedIndex = 0
        }
    }
    
    
    
}
