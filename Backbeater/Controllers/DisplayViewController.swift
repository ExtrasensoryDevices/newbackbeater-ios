//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//

import UIKit


class DisplayViewController: UIViewController, SongListViewControllerDelegate {

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
        
        updateSensorView()
        
        updateSongListView()
        
        centralRing.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        logButton.selected = false
        logView.hidden = true
    }
    
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingsChanged:", name: "SettingsChanged", object: nil)
    }
    
    @IBAction func didTapShowLog(sender: UIButton) {
        
        if sender.selected {
            sender.selected = false
            logView.hidden = true
        } else {
            sender.selected = true
            logView.hidden = false
        }
    }
    
    
    
    func settingsChanged(notification: NSNotification) {
        println(notification.userInfo)
        let name = notification.userInfo?["name"] as! String
        let value: AnyObject? = notification.userInfo?["value"]
        logView.text = logView.text + "\n\(name): \(value)"
        logView.scrollRangeToVisible(NSMakeRange(count(logView.text)-1, 1))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let songListVC = segue.destinationViewController as? SongListViewController {
            songListVC.delegate = self
            songListVC.setSongList(songList ?? [SongTempo(songName:"Song #1", tempoValue: 120),
                SongTempo(songName:"Song #2", tempoValue: 60),
                SongTempo(songName:"Song #3", tempoValue: 90),
                SongTempo(songName:"Song #4", tempoValue: 120),
                SongTempo(songName:"Song #5", tempoValue: 60)])
        } else if let webVC = segue.destinationViewController as? WebViewController {
            webVC.url = BUY_SENSOR_URL
        }
    }
    
   
    
    
    
    // MARK: - Song list
    
    func updateSongListView() {
        
        var hideButtons = true
        var hideLabel = true
        if let count = songList?.count where count > 0 {
            hideButtons = count <= 1
            hideLabel = count < 1
            songListBottomLayoutConstraint.constant = 0
        } else {
            songListBottomLayoutConstraint.constant = -songListView.bounds.height / 2
        }
        prevSongButton.hidden = hideButtons
        nextSongButton.hidden = hideButtons
        songNameLabel.hidden = hideLabel
        
        songNameLabel.text = songList?[selectedIndex].songName ?? ""
        tempoView.value = songList?[selectedIndex].tempoValue ?? DEFAULT_TEMPO
    }
    
    func updateSensorView() {
        let sensorIn = Settings.sharedInstance().sensorIn
        getSensorView.hidden = sensorIn
        setTempoView.hidden = !sensorIn
        // TODO: uncomment    
//        centralRing.listenToTaps(!sensorIn)
        centralRing.listenToTaps(true)
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
