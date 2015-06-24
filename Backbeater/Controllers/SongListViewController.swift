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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    weak var selectedTextField:UITextField?
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
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "tableViewLongPress:"))
        
        setupKeyboardAceessory()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
   
    func setupKeyboardAceessory() {
        // create toolbar with "DONE" button
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var submitButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapDoneButton")
        nextButton = UIBarButtonItem(title: "❯", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapNextButton")
        prevButton = UIBarButtonItem(title: "❮", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapPrevButton")
        
        let frame = CGRectMake(0, 0, 320, 50)
        
        keyboardToolbar = UIToolbar(frame: frame)
        keyboardToolbar.barTintColor = ColorPalette.KeyboardBg.color()
        keyboardToolbar.items = [prevButton, nextButton, flexibleSpace, submitButton]
        
        // create bottom line
        let borderView = UIView(frame: CGRectMake(0, 49, 320, 1))
        borderView.backgroundColor = ColorPalette.KeyboardBorder.color()
        borderView.userInteractionEnabled = false
        borderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        keyboardToolbar.addSubview(borderView)
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[borderView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[borderView(==1)]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.layoutIfNeeded()
    }
    
    
    func setSongList(list:[SongTempo]?) {
        if list != nil {
            oldSongList = list!
            newSongList = list!
        }
    }
    


    @IBAction func didTapClose(sender: AnyObject) {
        let listToReturn:[SongTempo]? = newSongList.count == 0 ? nil : newSongList
        delegate?.songListViewControllerDidReturnSongList(listToReturn, updated: isUpdated())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isUpdated() -> Bool {
        if oldSongList.count == 0 && newSongList.count == 0 {
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
            songListCell.songNameTextField.text = newSongList[indexPath.row].songName.uppercaseString
            songListCell.tempoValueTextField.text = "\(newSongList[indexPath.row].tempoValue)"
            songListCell.songNameTextField.inputAccessoryView = keyboardToolbar
            songListCell.tempoValueTextField.inputAccessoryView = keyboardToolbar
            songListCell.songNameTextField.tag = SONG_NAME_TEXT_FIELD_TAG
            songListCell.tempoValueTextField.tag = TEMPO_VALUE_TEXT_FIELD_TAG
            
            songListCell.deleteButton.addTarget(self, action: "didTapDeleteButton:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell = songListCell
        } else {
            let addSongCell = tableView.dequeueReusableCellWithIdentifier(AddSongCellReuseID, forIndexPath: indexPath) as! UITableViewCell
            if let addButton = addSongCell.viewWithTag(ADD_SONG_BUTTON_TAG) as? UIButton {
                println("addButton detected")
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
    
    
    
    func tableViewLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
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
    
    
    
    func getIndexPathForCellWithView(aView:UIView) -> NSIndexPath? {
        return tableView.indexPathForRowAtPoint(tableView.convertPoint(aView.center, fromView: aView.superview))
    }
    
    
    func didTapDeleteButton(button: UIButton) {
        println("didTapDeleteButton")
        if let path = getIndexPathForCellWithView(button) {
            
            selectedTextField?.resignFirstResponder()
            
            let alert = UIAlertController(title: nil, message: "Delete \(newSongList[path.row].songName)?", preferredStyle: UIAlertControllerStyle.Alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){ (action) in
                self.newSongList.removeAtIndex(path.row)
                self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func didTapAddButton(button: UIButton) {
        println("didTapAddButton")
        selectedTextField?.resignFirstResponder()
        newSongList.append(SongTempo(songName:"", tempoValue:DEFAULT_TEMPO))
        
        let indexPath = NSIndexPath(forRow: newSongList.count-1, inSection: 0)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SongListCell {
            cell.viewWithTag(SONG_NAME_TEXT_FIELD_TAG)?.becomeFirstResponder()
        }
    }
    
    
    // MARK: - Keyboard
    
    func didTapDoneButton() {
        selectedTextField?.resignFirstResponder()
        selectedTextField = nil
        selectedIndexPath = nil
    }
    
    func didTapNextButton() {
        println("didTapNextButton")
        if selectedTextField == nil || selectedIndexPath == nil {
            return
        }
        let selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
        if selectedTextField!.tag == SONG_NAME_TEXT_FIELD_TAG {
            let nextTextField = selectedCell!.viewWithTag(TEMPO_VALUE_TEXT_FIELD_TAG)!
            nextTextField.becomeFirstResponder()
        } else {
            let newIndexPath = NSIndexPath(forRow: selectedIndexPath!.row+1, inSection: selectedIndexPath!.section)
            let cell = tableView.cellForRowAtIndexPath(newIndexPath)
            if let tf = cell?.viewWithTag(SONG_NAME_TEXT_FIELD_TAG) as? UITextField {
                selectedTextField?.becomeFirstResponder()
            }
        }
    }
    
    func didTapPrevButton() {
        println("didTapPrevButton")
        if selectedTextField == nil || selectedIndexPath == nil {
            return
        }
        let selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
        if selectedTextField!.tag == TEMPO_VALUE_TEXT_FIELD_TAG {
            let prevTextField = selectedCell!.viewWithTag(SONG_NAME_TEXT_FIELD_TAG)!
            prevTextField.becomeFirstResponder()
        } else {
            let newIndexPath = NSIndexPath(forRow: selectedIndexPath!.row-1, inSection: selectedIndexPath!.section)
            let cell = tableView.cellForRowAtIndexPath(newIndexPath)
            if let tf = cell?.viewWithTag(TEMPO_VALUE_TEXT_FIELD_TAG) as? UITextField {
                selectedTextField?.becomeFirstResponder()
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        println("textFieldDidBeginEditing: \(textField.text)")
        selectedTextField = textField
        
        if let cellIndexPath = getIndexPathForCellWithView(textField) {
            selectedIndexPath = cellIndexPath
            nextButton.enabled = selectedIndexPath!.row < tableView.numberOfRowsInSection(0)-1 || selectedTextField!.tag != TEMPO_VALUE_TEXT_FIELD_TAG
            prevButton.enabled = selectedIndexPath!.row > 0 || selectedTextField!.tag != SONG_NAME_TEXT_FIELD_TAG
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        println("textFieldDidEndEditing")
        var songTempo = newSongList[selectedIndexPath!.row]
        if textField.tag == SONG_NAME_TEXT_FIELD_TAG {
            var value = textField.text.trim()
            songTempo.songName = value == "" ? "Song #\(selectedIndexPath!.row+1)" : value
            textField.text = songTempo.songName
        } else {
            if let value = textField.text.trim().toInt() where value >= 0 {
                songTempo.tempoValue = value > MAX_TEMPO ? MAX_TEMPO : value < MIN_TEMPO ? MIN_TEMPO : value
            } else {
                songTempo.tempoValue = DEFAULT_TEMPO
            }
            textField.text = "\(songTempo.tempoValue)"
        }
        newSongList[selectedIndexPath!.row] = songTempo
        selectedIndexPath = nil
        selectedTextField = nil
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("textFieldShouldReturn")
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
