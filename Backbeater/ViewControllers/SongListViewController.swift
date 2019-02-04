//
//  SongListViewController.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-15.
//

import UIKit
import Flurry_iOS_SDK

protocol SongListViewControllerDelegate: class {
    func songListViewControllerDidReturnSongList(_ songList: [SongTempo]?, updated:Bool)
}

class SongListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate {
    
    weak var delegate:SongListViewControllerDelegate?
    
    @IBOutlet weak var empyView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    private var inputTextField:UITextField!
    
    private var selectedIndexPath: IndexPath? {
        didSet {
            if oldValue != nil {
                tableView.deselectRow(at: oldValue!, animated: false)
            }
            if selectedIndexPath != nil {
                tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
            }
        }
    }
    
    private var keyboardToolbar:UIToolbar!
    private var nextButton: UIBarButtonItem!
    private var prevButton: UIBarButtonItem!

    private struct Tag {
        static let songName = 1
        static let tempo = 2
        static let add = 3
    }
    
    private var oldSongList:[SongTempo] = []
    private var newSongList:[SongTempo] = []
    
    func setSongList(_ list:[SongTempo]?) {
        oldSongList = list ?? []
        newSongList = list ?? []
        updateEmptyState()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorPalette.black.color
        tableView.backgroundColor = ColorPalette.black.color
        tableView.backgroundView = nil
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTableViewCell(_:))))
        
        setupKeyboardAceessory()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SongListViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SongListViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEmptyState()
        
    }
    
    private func updateEmptyState() {
        empyView?.isHidden = !newSongList.isEmpty
    }
    

    @IBAction func didTapClose(_ sender: AnyObject) {
        // log list created
        if oldSongList.isEmpty && !newSongList.isEmpty {
            Flurry.logEvent(.tempoListCreated)
        }
        let listToReturn:[SongTempo]? = newSongList.isEmpty ? nil : newSongList
        delegate?.songListViewControllerDidReturnSongList(listToReturn, updated: isUpdated())
        self.dismiss(animated: true, completion: nil)
    }
    
    private func isUpdated() -> Bool {
        if oldSongList.isEmpty && newSongList.isEmpty {
            return false
        }
        if oldSongList.count != newSongList.count {
            return true
        }
        let count = newSongList.count
        for i in 0..<count {
            if newSongList[i] != oldSongList[i] {
                return true
            }
        }
        return false
    }
    
    private func editTextWithTag(_ tag:Int, inCell cell:SongListCell, atIndexPath indexPath:IndexPath) {
        
        if inputTextField == nil {
            setupInputTextField()
        }
        
        updateCurrentSong()
        
        inputTextField.text = ""
        
        if tag == Tag.songName {
            inputTextField.frame = cell.songNameLabel.frame
            inputTextField.font = Font.FuturaDemi.get(13)
            inputTextField.minimumFontSize = 13
            inputTextField.keyboardType = UIKeyboardType.default
            inputTextField.textAlignment = .left
            inputTextField.tag = Tag.songName
            inputTextField.removeBorder()
            inputTextField.text = cell.songNameLabel.text
            
        } else if tag == Tag.tempo {
            inputTextField.frame = cell.tempoValueLabel.frame
            inputTextField.font = Font.FuturaBook.get(14)
            inputTextField.minimumFontSize = 14
            inputTextField.keyboardType = UIKeyboardType.decimalPad
            inputTextField.textAlignment = .center
            inputTextField.tag = Tag.tempo
            inputTextField.drawBorder()
            inputTextField.text = cell.tempoValueLabel.text
        } else {
            return
        }
        
        selectedIndexPath = indexPath
        
        if cell.contentView != inputTextField.superview {
            cell.contentView.addSubview(inputTextField)
        }
        inputTextField.reloadInputViews()
        inputTextField.becomeFirstResponder()
        updateKeyboardToolbar()
    }
    
    private func deleteSongAtIndex(_ index:Int) {
        newSongList.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.automatic)
        saveTempoList()
        updateEmptyState()
    }
    
    private func updateCurrentSong() {
        if selectedIndexPath == nil {
            return
        }
        let cell  = tableView.cellForRow(at: selectedIndexPath!) as! SongListCell
        var songTempo = newSongList[(selectedIndexPath! as NSIndexPath).row]
        if inputTextField.tag == Tag.songName {
            let value = inputTextField.text?.trim()
            songTempo.songName = value! == "" ? "Song #\(selectedIndexPath!.row+1)" : value!
            inputTextField.text = songTempo.songName
            cell.songNameLabel.text = inputTextField.text
            
        } else {
            let value:Int = Int(inputTextField.text?.trim() ?? "") ?? Tempo.default
            songTempo.tempoValue = Tempo.normalized(value: value)
            inputTextField.text = "\(songTempo.tempoValue)"
            cell.tempoValueLabel.text = inputTextField.text
        }
        newSongList[(selectedIndexPath! as NSIndexPath).row] = songTempo
    }
    
    private func saveTempoList() {
        UserDefaults.set(object: newSongList, for: .songList)
    }
    
    // MARK: - Actions
    
    @objc func didTapAddButton(_ button: UIButton) {
        inputTextField?.resignFirstResponder()
        
        
        let indexPath = IndexPath(row: newSongList.count, section: 0)
        
        newSongList.append(SongTempo(songName:"Song #\((indexPath as NSIndexPath).row+1)", tempoValue: Tempo.default))
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.bottom)
        tableView.endUpdates()
        
        if let cell = tableView.cellForRow(at: indexPath) as? SongListCell {
            editTextWithTag(Tag.songName, inCell: cell, atIndexPath: indexPath)
            inputTextField.textRange(from: inputTextField.beginningOfDocument, to: inputTextField.endOfDocument)
            updateEmptyState()
        }
    }
    
    
    @objc func didTapDeleteButton(_ button: UIButton) {
        if let path = getIndexPathForCellWithView(button) {
            
            inputTextField?.resignFirstResponder()
            
            let alert = UIAlertController(title: nil, message: "Delete \(newSongList[(path as NSIndexPath).row].songName)?", preferredStyle: UIAlertController.Style.alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive){ (action) in
                self.deleteSongAtIndex((path as NSIndexPath).row)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSongList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songListCellReuseID = "SongListCellReuseID"
        let addSongCellReuseID = "AddSongCellReuseID"
        
        let cell:UITableViewCell
        if (indexPath as NSIndexPath).row < newSongList.count {
            let songListCell = tableView.dequeueReusableCell(withIdentifier: songListCellReuseID, for: indexPath) as! SongListCell
            songListCell.songNameLabel.text = newSongList[(indexPath as NSIndexPath).row].songName.uppercased()
            songListCell.tempoValueLabel.text = "\(newSongList[(indexPath as NSIndexPath).row].tempoValue)"
            songListCell.songNameLabel.tag = Tag.songName
            songListCell.tempoValueLabel.tag = Tag.tempo
            
            songListCell.deleteButton.addTarget(self, action: #selector(SongListViewController.didTapDeleteButton(_:)), for: UIControl.Event.touchUpInside)
            
            cell = songListCell
        } else {
            let addSongCell = tableView.dequeueReusableCell(withIdentifier: addSongCellReuseID, for: indexPath)
            if let addButton = addSongCell.viewWithTag(Tag.add) as? UIButton {
                addButton.addTarget(self, action: #selector(SongListViewController.didTapAddButton(_:)), for: UIControl.Event.touchUpInside)
            }
            
            cell = addSongCell
        }
        
        cell.backgroundColor = ColorPalette.black.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
    
//    func didLongPressTableViewCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        let p = gestureRecognizer.location(in: self.tableView)
//        if let indexPath = self.tableView.indexPathForRow(at: p) {
//
//            // reorder cells
//
//            if let cell = self.tableView.cellForRow(at: indexPath) as? SongListCell {
////                let pointInCell = cell.convert(p, from:self.tableView)
////
////                if CGRectContainsPoint(cell.songNameLabel.frame, pointInCell) {
////                    println("longpress in song name")
////                } else if CGRectContainsPoint(cell.tempoValueLabel.frame, pointInCell) {
////                    println("longpress in tempo value")
////                }
//            }
//        }
//    }
    
    
    @objc func didTapTableViewCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: p) {
            
            // start editing
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? SongListCell {
                let pointInCell = cell.contentView.convert(p, from:self.tableView)
                if cell.songNameLabel.frame.contains(pointInCell) {
                    editTextWithTag(Tag.songName, inCell: cell, atIndexPath: indexPath)
                } else if cell.tempoValueLabel.frame.contains(pointInCell) {
                    editTextWithTag(Tag.tempo, inCell: cell, atIndexPath: indexPath)
                }
            }
        }
    }
    
    private func getIndexPathForCellWithView(_ aView:UIView) -> IndexPath? {
        return tableView.indexPathForRow(at: tableView.convert(aView.center, from: aView.superview))
    }
    
    
    // MARK: - Text Field
    
    private func setupInputTextField() {
        if inputTextField == nil {
            inputTextField = UITextField()
        }
        inputTextField.inputAccessoryView = keyboardToolbar
        inputTextField.backgroundColor = ColorPalette.black.color
        
        inputTextField.autocapitalizationType = .allCharacters
        
        inputTextField.delegate = self
    }
    
    private func textFieldDidBeginEditing(_ textField: UITextField) {
        if let cellIndexPath = getIndexPathForCellWithView(textField) {
            selectedIndexPath = cellIndexPath
            updateKeyboardToolbar()
        }
    }
    
    private func textFieldDidEndEditing(_ textField: UITextField) {
        updateCurrentSong()
        selectedIndexPath = nil
        textField.removeFromSuperview()
        
        saveTempoList()
    }
    
    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Keyboard
    
    private func setupKeyboardAceessory() {
        // create toolbar with "DONE" button
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let submitButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItem.Style.plain, target: self, action: #selector(SongListViewController.didTapDoneButton))
        nextButton = UIBarButtonItem(title: "❯", style: UIBarButtonItem.Style.plain, target: self, action: #selector(SongListViewController.didTapNextButton))
        prevButton = UIBarButtonItem(title: "❮", style: UIBarButtonItem.Style.plain, target: self, action: #selector(SongListViewController.didTapPrevButton))
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 51)
        
        keyboardToolbar = UIToolbar(frame: frame)
        keyboardToolbar.barTintColor = ColorPalette.keyboardBg.color
        keyboardToolbar.items = [prevButton, nextButton, flexibleSpace, submitButton]
        
        // create bottom line
        let borderView = UIView(frame: CGRect(x: 0, y: 50, width: frame.size.width, height: 1))
        borderView.backgroundColor = ColorPalette.keyboardBorder.color
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        keyboardToolbar.addSubview(borderView)
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[borderView]|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[borderView(==1)]|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.layoutIfNeeded()
    }
    
    
    @objc func didTapDoneButton() {
        inputTextField?.resignFirstResponder()
    }
    
    @objc func didTapNextButton() {
        if inputTextField.tag == Tag.songName {
            if let cell = tableView.cellForRow(at: selectedIndexPath!) as? SongListCell {
                editTextWithTag(Tag.tempo, inCell: cell, atIndexPath: selectedIndexPath!)
            }
        } else {
            let newIndexPath = IndexPath(row: (selectedIndexPath! as NSIndexPath).row+1, section: (selectedIndexPath! as NSIndexPath).section)
            if let cell = tableView.cellForRow(at: newIndexPath)  as? SongListCell {
                editTextWithTag(Tag.songName, inCell: cell, atIndexPath: newIndexPath)
            }
        }
    }
    
    @objc func didTapPrevButton() {
        if inputTextField.tag == Tag.tempo {
            if let cell = tableView.cellForRow(at: selectedIndexPath!) as? SongListCell {
                editTextWithTag(Tag.songName, inCell: cell, atIndexPath: selectedIndexPath!)
            }
        } else {
            let newIndexPath = IndexPath(row: (selectedIndexPath! as NSIndexPath).row-1, section: (selectedIndexPath! as NSIndexPath).section)
            if let cell = tableView.cellForRow(at: newIndexPath)  as? SongListCell {
                editTextWithTag(Tag.tempo, inCell: cell, atIndexPath: newIndexPath)
            }
        }
    }
    
    
    private func updateKeyboardToolbar() {
        if selectedIndexPath != nil && inputTextField != nil {
            nextButton.isEnabled = (selectedIndexPath! as NSIndexPath).row < newSongList.count-1 || inputTextField.tag != Tag.tempo
            prevButton.isEnabled = (selectedIndexPath! as NSIndexPath).row > 0 || inputTextField.tag != Tag.songName
        }
    }
    

    
    @objc func keyboardWillHide(_ notification: Notification!) {
        adjustViewForKeyboardNotification(false, notification: notification)
    }
    
    @objc func keyboardWillShow(_ notification: Notification!) {
        adjustViewForKeyboardNotification(true, notification: notification)
    }
    
    private func adjustViewForKeyboardNotification(_ hide: Bool, notification: Notification!) {
        var userInfo = notification.userInfo!
        
        let kbSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationDuration = durationValue.doubleValue
        let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber
        let animationCurve = curveValue.intValue
        
        let window = UIApplication.shared.keyWindow!
        let keyboardTop = CGPoint(x: 0, y: window.bounds.height - kbSize.height)
        let keyboardTopInView = window.convert(keyboardTop, to: self.view)
        let keyboardHeightInView = self.view.frame.height - keyboardTopInView.y
        
        let constant = (hide ? keyboardHeightInView : 0)
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)), animations: {
            self.bottomConstraint.constant = constant
            self.view.layoutIfNeeded()
        }){ (completed:Bool) in
            if let selectedRow = self.tableView.indexPathForSelectedRow {
                self.tableView.scrollToRow(at: selectedRow, at: UITableView.ScrollPosition.middle, animated: true)
            }
        }
    }


}
