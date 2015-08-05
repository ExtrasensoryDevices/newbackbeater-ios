//
//  SongListViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-15.
//

import UIKit

protocol SongListViewControllerDelegate: class {
    func songListViewControllerDidReturnSongList(songList: [SongTempo]?, updated:Bool)
}

class SongListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    weak var delegate:SongListViewControllerDelegate?
    
    @IBOutlet weak var empyView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var inputTextField:UITextField!
    
    var selectedIndexPath: NSIndexPath? {
        didSet {
            if oldValue != nil {
                tableView.deselectRowAtIndexPath(oldValue!, animated: false)
            }
            if selectedIndexPath != nil {
                tableView.selectRowAtIndexPath(selectedIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }

    
    
    var keyboardToolbar:UIToolbar!
    var nextButton: UIBarButtonItem!
    var prevButton: UIBarButtonItem!

    let SONG_NAME_TEXT_FIELD_TAG = 1
    let TEMPO_VALUE_TEXT_FIELD_TAG = 2
    let ADD_SONG_BUTTON_TAG = 3
    
    private var oldSongList:[SongTempo] = []
    private var newSongList:[SongTempo] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorPalette.Black.color()
        tableView.backgroundColor = ColorPalette.Black.color()
        tableView.backgroundView = nil
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "didLongPressTableViewCell:"))
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapTableViewCell:"))
        
        setupKeyboardAceessory()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateEmptyState()
        
    }
    
   
    func setupKeyboardAceessory() {
        // create toolbar with "DONE" button
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var submitButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapDoneButton")
        nextButton = UIBarButtonItem(title: "❯", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapNextButton")
        prevButton = UIBarButtonItem(title: "❮", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapPrevButton")
        
        let frame = CGRectMake(0, 0, self.view.frame.size.width, 51)
        
        keyboardToolbar = UIToolbar(frame: frame)
        keyboardToolbar.barTintColor = ColorPalette.KeyboardBg.color()
        keyboardToolbar.items = [prevButton, nextButton, flexibleSpace, submitButton]
        
        // create bottom line
        let borderView = UIView(frame: CGRectMake(0, 50, frame.size.width, 1))
        borderView.backgroundColor = ColorPalette.KeyboardBorder.color()
        borderView.userInteractionEnabled = false
        borderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        keyboardToolbar.addSubview(borderView)
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[borderView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[borderView(==1)]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.layoutIfNeeded()
    }
    
    
    func setupInputTextField() {
        if inputTextField == nil {
            inputTextField = UITextField()
        }
        inputTextField.inputAccessoryView = keyboardToolbar
        inputTextField.backgroundColor = ColorPalette.Black.color()
        
        inputTextField.autocapitalizationType = .AllCharacters
        
        inputTextField.delegate = self
    }
    
    
    
    func updateEmptyState() {
        empyView?.hidden = !newSongList.isEmpty
    }
    
    
    func setSongList(list:[SongTempo]?) {
        oldSongList = list ?? []
        newSongList = list ?? []
        updateEmptyState()
    }
    


    @IBAction func didTapClose(sender: AnyObject) {
        let listToReturn:[SongTempo]? = newSongList.isEmpty ? nil : newSongList
        delegate?.songListViewControllerDidReturnSongList(listToReturn, updated: isUpdated())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isUpdated() -> Bool {
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
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSongList.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let SongListCellReuseID = "SongListCellReuseID"
        let AddSongCellReuseID = "AddSongCellReuseID"
        
        let cell:UITableViewCell
        if indexPath.row < newSongList.count {
            let songListCell = tableView.dequeueReusableCellWithIdentifier(SongListCellReuseID, forIndexPath: indexPath) as! SongListCell
            songListCell.songNameLabel.text = newSongList[indexPath.row].songName.uppercaseString
            songListCell.tempoValueLabel.text = "\(newSongList[indexPath.row].tempoValue)"
            songListCell.songNameLabel.tag = SONG_NAME_TEXT_FIELD_TAG
            songListCell.tempoValueLabel.tag = TEMPO_VALUE_TEXT_FIELD_TAG
            
            songListCell.deleteButton.addTarget(self, action: "didTapDeleteButton:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell = songListCell
        } else {
            let addSongCell = tableView.dequeueReusableCellWithIdentifier(AddSongCellReuseID, forIndexPath: indexPath) as! UITableViewCell
            if let addButton = addSongCell.viewWithTag(ADD_SONG_BUTTON_TAG) as? UIButton {
                addButton.addTarget(self, action: "didTapAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                println("addButton not found")
            }
            println("\(addSongCell.viewWithTag(ADD_SONG_BUTTON_TAG) as? UIButton)")
            
            cell = addSongCell
        }
        
        cell.backgroundColor = ColorPalette.Black.color()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    
    func didLongPressTableViewCell(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(p) {
            
            // reorder cells
            
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SongListCell {
                let pointInCell = cell.convertPoint(p, fromView:self.tableView)
//
//                if CGRectContainsPoint(cell.songNameLabel.frame, pointInCell) {
//                    println("longpress in song name")
//                } else if CGRectContainsPoint(cell.tempoValueLabel.frame, pointInCell) {
//                    println("longpress in tempo value")
//                }
            }
        }
    }
    
    
    func didTapTableViewCell(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(p) {
            
            // start editing
            
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SongListCell {
                let pointInCell = cell.contentView.convertPoint(p, fromView:self.tableView)
                if CGRectContainsPoint(cell.songNameLabel.frame, pointInCell) {
                    editTextWithTag(SONG_NAME_TEXT_FIELD_TAG, inCell: cell, atIndexPath: indexPath)
                } else if CGRectContainsPoint(cell.tempoValueLabel.frame, pointInCell) {
                    editTextWithTag(TEMPO_VALUE_TEXT_FIELD_TAG, inCell: cell, atIndexPath: indexPath)
                }
            }
        }
    }
    
    
    func editTextWithTag(tag:Int, inCell cell:SongListCell, atIndexPath indexPath:NSIndexPath) {

        if inputTextField == nil {
            setupInputTextField()
        }
        
        if tag == SONG_NAME_TEXT_FIELD_TAG {
            inputTextField.frame = cell.songNameLabel.frame
            inputTextField.font = Font.FuturaDemi.get(13)
            inputTextField.minimumFontSize = 13
            inputTextField.keyboardType = UIKeyboardType.Default
            inputTextField.textAlignment = .Left
            inputTextField.tag = SONG_NAME_TEXT_FIELD_TAG
            inputTextField.removeBorder()
            inputTextField.text = cell.songNameLabel.text
            
        } else if tag == TEMPO_VALUE_TEXT_FIELD_TAG {
            inputTextField.frame = cell.tempoValueLabel.frame
            inputTextField.font = Font.FuturaBook.get(14)
            inputTextField.minimumFontSize = 14
            inputTextField.keyboardType = UIKeyboardType.DecimalPad
            inputTextField.textAlignment = .Center
            inputTextField.tag = TEMPO_VALUE_TEXT_FIELD_TAG
            inputTextField.drawBorder()
            inputTextField.text = cell.tempoValueLabel.text
        } else {
            return
        }
        
        selectedIndexPath = indexPath
        
        cell.contentView.addSubview(inputTextField)
        inputTextField.becomeFirstResponder()
        updateKeyboardToolbar()
    }

    
    
    func getIndexPathForCellWithView(aView:UIView) -> NSIndexPath? {
        return tableView.indexPathForRowAtPoint(tableView.convertPoint(aView.center, fromView: aView.superview))
    }
    
    
    func didTapDeleteButton(button: UIButton) {
        if let path = getIndexPathForCellWithView(button) {
            
            inputTextField?.resignFirstResponder()
            
            let alert = UIAlertController(title: nil, message: "Delete \(newSongList[path.row].songName)?", preferredStyle: UIAlertControllerStyle.Alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){ (action) in
                self.newSongList.removeAtIndex(path.row)
                self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.updateEmptyState()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func didTapAddButton(button: UIButton) {
        inputTextField?.resignFirstResponder()
        
        
        let indexPath = NSIndexPath(forRow: newSongList.count, inSection: 0)
        
        newSongList.append(SongTempo(songName:"Song #\(indexPath.row+1)", tempoValue:SoundConstant.DEFAULT_TEMPO()))
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SongListCell {
            editTextWithTag(SONG_NAME_TEXT_FIELD_TAG, inCell: cell, atIndexPath: indexPath)
            inputTextField.textRangeFromPosition(inputTextField.beginningOfDocument, toPosition: inputTextField.endOfDocument)
            updateEmptyState()
        }
    }
    
    
    // MARK: - Keyboard
    
    func didTapDoneButton() {
        inputTextField?.resignFirstResponder()
    }
    
    func didTapNextButton() {
        if inputTextField.tag == SONG_NAME_TEXT_FIELD_TAG {
            if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath!) as? SongListCell {
                editTextWithTag(TEMPO_VALUE_TEXT_FIELD_TAG, inCell: cell, atIndexPath: selectedIndexPath!)
            }
        } else {
            let newIndexPath = NSIndexPath(forRow: selectedIndexPath!.row+1, inSection: selectedIndexPath!.section)
            if let cell = tableView.cellForRowAtIndexPath(newIndexPath)  as? SongListCell {
                editTextWithTag(SONG_NAME_TEXT_FIELD_TAG, inCell: cell, atIndexPath: newIndexPath)
            }
        }
    }
    
    func didTapPrevButton() {
        if inputTextField.tag == TEMPO_VALUE_TEXT_FIELD_TAG {
            if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath!) as? SongListCell {
                editTextWithTag(SONG_NAME_TEXT_FIELD_TAG, inCell: cell, atIndexPath: selectedIndexPath!)
            }
        } else {
            let newIndexPath = NSIndexPath(forRow: selectedIndexPath!.row-1, inSection: selectedIndexPath!.section)
            if let cell = tableView.cellForRowAtIndexPath(newIndexPath)  as? SongListCell {
                editTextWithTag(TEMPO_VALUE_TEXT_FIELD_TAG, inCell: cell, atIndexPath: newIndexPath)
            }
        }
    }
    
    
    func updateKeyboardToolbar() {
        if selectedIndexPath != nil && inputTextField != nil {
            nextButton.enabled = selectedIndexPath!.row < newSongList.count-1 || inputTextField.tag != TEMPO_VALUE_TEXT_FIELD_TAG
            prevButton.enabled = selectedIndexPath!.row > 0 || inputTextField.tag != SONG_NAME_TEXT_FIELD_TAG
        }
    }
    

    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let cellIndexPath = getIndexPathForCellWithView(textField) {
            selectedIndexPath = cellIndexPath
            updateKeyboardToolbar()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var songTempo = newSongList[selectedIndexPath!.row]
        if textField.tag == SONG_NAME_TEXT_FIELD_TAG {
            var value = textField.text.trim()
            songTempo.songName = value == "" ? "Song #\(selectedIndexPath!.row+1)" : value
            textField.text = songTempo.songName
        } else {
            if let value = textField.text.trim().toInt() where value >= 0 {
                
                songTempo.tempoValue = value.inBounds(minValue: SoundConstant.MIN_TEMPO(), maxValue: SoundConstant.MAX_TEMPO())
            } else {
                songTempo.tempoValue = SoundConstant.DEFAULT_TEMPO()
            }
            textField.text = "\(songTempo.tempoValue)"
        }
        newSongList[selectedIndexPath!.row] = songTempo
        tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        selectedIndexPath = nil
        textField.removeFromSuperview()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func keyboardWillHide(notification: NSNotification!) {
        adjustViewForKeyboardNotification(false, notification: notification)
    }
    
    func keyboardWillShow(notification: NSNotification!) {
        adjustViewForKeyboardNotification(true, notification: notification)
    }
    
    func adjustViewForKeyboardNotification(hide: Bool, notification: NSNotification!) {
        var userInfo = notification.userInfo!
        
        var kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        var durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        var animationDuration = durationValue.doubleValue
        var curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        var animationCurve = curveValue.integerValue
        
        let window = UIApplication.sharedApplication().keyWindow!
        let keyboardTop = CGPoint(x: 0, y: window.bounds.height - kbSize.height)
        let keyboardTopInView = window.convertPoint(keyboardTop, toView: self.view)
        let keyboardHeightInView = self.view.frame.height - keyboardTopInView.y
        
        let constant = (hide ? keyboardHeightInView : 0)
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions(UInt(animationCurve << 16)), animations: {
            self.bottomConstraint.constant = constant
            self.view.layoutIfNeeded()
        }){ (completed:Bool) in
            if let selectedRow = self.tableView.indexPathForSelectedRow() {
                self.tableView.scrollToRowAtIndexPath(selectedRow, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            } else {
                println("no row selected")
            }
        }
    }


}
