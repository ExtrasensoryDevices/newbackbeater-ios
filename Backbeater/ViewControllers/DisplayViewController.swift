//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-10.
//

import UIKit


protocol DisplayViewControllerDelegate:class {
    func readyToRender()
    func foundTap(bpm:Float64)
    func didDetectFirstTap()
    func metronomeStateChanged(_ newValue:MetronomeState)
    func startMetronomeWithCurrentTempo()
}


class DisplayViewController: UIViewController, SongListViewControllerDelegate, CentralRingDelegate, CoordinatorDelegate {
    @IBOutlet weak var hamButton: UIButton!
    
    @IBOutlet weak var centerRing: CenterRing!
    
    @IBOutlet weak var centralRing: CentralRing!
    @IBOutlet weak var centralRingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var centralRingBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var getSensorBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var getSensorView: UILabel!
    @IBOutlet weak var setTempoView: UIView!
    
    @IBOutlet weak var metronomeTempoView: NumericStepper!
    
    @IBOutlet weak var songListView: UIView!
    @IBOutlet weak var prevSongButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songListBottomLayoutConstraint: NSLayoutConstraint!
    
    weak var delegate: DisplayViewControllerDelegate?
    
    
    private var songList:[SongTempo]? {
        didSet {
            let doShow = (songList?.count ?? 0) > 0
            showSongView(doShow)
        }
    }
    private var selectedSongIndex:Int = -1 {
        didSet {
            if selectedSongIndex != -1 {
                updateSongListView()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        centralRing.delegate = self
        centerRing.delegate = self
        
        let image = UIImage(named:"tempo_list")!.withRenderingMode(.alwaysTemplate)
        hamButton.setImage(image, for: UIControl.State())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.readyToRender()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        view.backgroundColor = ColorPalette.black.color
        
        setTempoView.drawBorder()
        setTempoView.backgroundColor = ColorPalette.black.color
        setTempoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DisplayViewController.didTapSetTempoButton)))
        
        metronomeTempoView.font = Font.FuturaBook.get(33)
        metronomeTempoView.bgrColor = ColorPalette.black.color

        getSensorView.drawBorder()
        getSensorView.clipsToBounds = true
        getSensorView.backgroundColor = ColorPalette.pink.color
        getSensorView.font = Font.FuturaDemi.get(14)
        getSensorView.textColor = ColorPalette.black.color
        
        centralRing.translatesAutoresizingMaskIntoConstraints = false
        
        if ScreenUtil.screenSizeClass == .xsmall {
            centralRingTopConstraint.constant = 0
            centralRingBottomConstraint.constant = 0
        }
    }
    
    
    // MARK: - CoordinatorDelegate
    
    func setupView(lastPlayedTempo:Int,
                   metronomeTempo: Int,
                   sensitivity: Int,
                   sensorDetected: Bool,
                   sound: URL) {
        centerRing.setLastPlayedTempo(lastPlayedTempo)
        centerRing.setTempo(metronomeTempo)
        centerRing.setSound(url: sound)
//        centralRing.setLastPlayedTempo(tempo: lastPlayedTempo)
//        centralRing.setSound(url: sound)
        metronomeTempoView.value = metronomeTempo
        metronomeTempoView.isOn = false
        
        updateSensorState(sensorDetected: sensorDetected)
        
        songList = SongTempo.deserialize(data: UserDefaults.data(for: .songList) as? Data)
        if let count = songList?.count, count > 0 {
            selectedSongIndex = 0
        }
    }
    
    
    func stopMetronome() {
//        centralRing.stopMetronome()
        metronomeTempoView.isOn = false
    }
    
    func stopAnimation() {
//        centralRing.stopAnimation()
    }
    
    
    func updateMetronomeState(metronomeState: MetronomeState) {
        switch metronomeState {
        case .on(let tempo):
            metronomeTempoView.value = tempo
            metronomeTempoView.isOn = true
        case .off(let tempo):
            metronomeTempoView.value = tempo
            metronomeTempoView.isOn = false
        }
//        centralRing.handleMetronomeState(metronomeState)
        centerRing.handleMetronomeState(metronomeState)
    }
    
    func updateSensorState(sensorDetected:Bool) {
        getSensorView.isHidden = sensorDetected
        setTempoView.isHidden = !sensorDetected
    }
    
    
    func setSound(url:URL) {
//        centralRing.setSound(url: url)
        centerRing.setSound(url: url)
    }
    
    func display(cpt:Int, timeSignature: Int, metronomeState:MetronomeState) {
//        centralRing.display(cpt: cpt, timeSignature: timeSignature, metronomeState: metronomeState)
        centerRing.display(cpt: cpt, timeSignature: timeSignature, metronomeState: metronomeState)
    }

    func handleFirstStrike() {
//        centralRing.runPulseAnimation()
    }
    
    func showMicrophonePermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone permission required",
            message: "Mic permissions are required in order to connect to the sensor.",
            preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { [weak self] (action) in
            self?.openSettings()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    

    //MARK: - User interaction
    
    @IBAction func didTapGetSensorButton(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: BUY_SENSOR_URL)!, options: [:], completionHandler: nil)
    }
    
    @objc func didTapSetTempoButton() {
        delegate?.startMetronomeWithCurrentTempo()
    }
    
    @IBAction func didTapSongName(_ sender: AnyObject) {
        if let tempo  = songList?[safe: selectedSongIndex]?.tempoValue {
            reportMetronomeState(isOn: metronomeTempoView.isOn, tempo: tempo)
        }
    }
    
    //MARK: - NumericStepper delegate
    
    @IBAction func metronomeTempoValueChanged(_ sender: NumericStepper) {
        reportMetronomeState(isOn: sender.isOn, tempo: sender.value)
    }
    
    @IBAction func metronomeTempoPressed(_ sender: NumericStepper) {
        reportMetronomeState(isOn: sender.isOn, tempo: sender.value)
    }
    
    private func reportMetronomeState(isOn: Bool, tempo: Int) {
        let newState:MetronomeState  =  isOn ? .on(tempo: tempo) : .off(tempo: tempo)
        delegate?.metronomeStateChanged(newState)
        centerRing.setTempo(tempo)
    }

    
    
    
    // MARK: - CentralRingDelegate
    func centralRingFoundTap(bpm: Float64) {
        delegate?.foundTap(bpm: bpm)
    }
    
    func centralRingDidDetectFirstTap() {
         delegate?.didDetectFirstTap()
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
    
    private func showSongView(_ doShow: Bool) {
        prevSongButton.isHidden = !doShow
        nextSongButton.isHidden = !doShow
        songNameLabel.isHidden  = !doShow
        if doShow {
            songListBottomLayoutConstraint.constant = 0
            hamButton.tintColor = UIColor.white
        } else {
            songListBottomLayoutConstraint.constant = -songListView.bounds.height / 2
            hamButton.tintColor = ColorPalette.grey.color
        }
    }
    
    private func updateSongListView() {
        guard let songList = songList, songList.count > 0 else {
            assertionFailure("SongList is nil or empty")
            return
        }
        
        guard let song = songList[safe: selectedSongIndex] else {
            assertionFailure("SelectedSongIndex out of range")
            return
        }
        
        let hideButtons = songList.count == 1
        
        songNameLabel.text = song.songName
        
        prevSongButton.isHidden = hideButtons
        nextSongButton.isHidden = hideButtons
        songNameLabel.isHidden = false
        reportMetronomeState(isOn: metronomeTempoView.isOn, tempo: song.tempoValue)
    }
    
    
    @IBAction func didTapPrevButton(_ sender: AnyObject) {
        guard let songList = songList else {
            assertionFailure("SongList is nil")
            return
        }
        selectedSongIndex  = selectedSongIndex >= 1 ? selectedSongIndex-1 : songList.count-1
    }

    @IBAction func didTapNextButton(_ sender: AnyObject) {
        guard let songList = songList else {
            assertionFailure("SongList is nil")
            return
        }
        selectedSongIndex  = selectedSongIndex < songList.count-1 ? selectedSongIndex+1 : 0
    }
    
    func songListViewControllerDidReturnSongList(_ newSongList: [SongTempo]?, updated: Bool) {
        if updated {
            self.songList = newSongList
            self.selectedSongIndex = (newSongList == nil) ? -1 : 0
        }
    }
}
