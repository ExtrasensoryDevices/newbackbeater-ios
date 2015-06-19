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

class SongListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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

    let songNameTextFieldTag = 1
    let tempoValueTextFieldTag = 2
    
    
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
    
    var songList:[SongTempo]? = [SongTempo(songName:"Song #1", tempoValue: 120),
        SongTempo(songName:"Song #2", tempoValue: 60),
        SongTempo(songName:"Song #3", tempoValue: 90),
        SongTempo(songName:"Song #4", tempoValue: 120),
        SongTempo(songName:"Song #5", tempoValue: 60),
        SongTempo(songName:"Song #6", tempoValue: 90),
        SongTempo(songName:"Song #7", tempoValue: 120),
        SongTempo(songName:"Song #8", tempoValue: 60),
        SongTempo(songName:"Song #9", tempoValue: 90)]
    
    
    
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
        keyboardToolbar.addSubview(borderView)
    }


    @IBAction func didTapClose(sender: AnyObject) {
        delegate?.songListViewControllerDidReturnSongList(songList, updated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let SongListCellReuseID = "SongListCellReuseID"
        let cell = tableView.dequeueReusableCellWithIdentifier(SongListCellReuseID, forIndexPath: indexPath) as! SongListCell
        cell.backgroundColor = ColorPalette.Black.color()
        cell.songNameTextField.text = songList![indexPath.row].songName.uppercaseString
        cell.tempoValueTextField.text = "\(songList![indexPath.row].tempoValue)"
        cell.songNameTextField.inputAccessoryView = keyboardToolbar
        cell.tempoValueTextField.inputAccessoryView = keyboardToolbar
        cell.songNameTextField.tag = songNameTextFieldTag
        cell.tempoValueTextField.tag = tempoValueTextFieldTag
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SongListCell {
            cell.songNameTextField.becomeFirstResponder()
        }
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
    
    
    
    func getCellForView(aView:UIView) -> NSIndexPath? {
        //println("viewCenter: \(aView.center), converted point \(tableView.convertPoint(aView.center, fromView: aView.superview))")
        return tableView.indexPathForRowAtPoint(tableView.convertPoint(aView.center, fromView: aView.superview))
    }
        
    // MARK: - Keyboard
    
    func didTapDoneButton() {
        selectedTextField?.resignFirstResponder()
        selectedTextField = nil
        selectedIndexPath = nil
    }
    
    func didTapNextButton() {
        println(selectedTextField)
        println(selectedIndexPath)
        if selectedTextField == nil || selectedIndexPath == nil {
            return
        }
        let selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
        if selectedTextField!.tag == songNameTextFieldTag {
            let nextTextField = selectedCell!.viewWithTag(tempoValueTextFieldTag)!
            nextTextField.becomeFirstResponder()
        } else {
            let newIndexPath = NSIndexPath(forRow: selectedIndexPath!.row+1, inSection: selectedIndexPath!.section)
            let cell = tableView.cellForRowAtIndexPath(newIndexPath)
            if let tf = cell?.viewWithTag(songNameTextFieldTag) as? UITextField {
                selectedTextField = tf
                selectedTextField?.becomeFirstResponder()
            }
        }
    }
    
    func didTapPrevButton() {
        if selectedTextField == nil || selectedIndexPath == nil {
            return
        }
        let selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
        if selectedTextField!.tag == tempoValueTextFieldTag {
            let prevTextField = selectedCell!.viewWithTag(songNameTextFieldTag)!
            prevTextField.becomeFirstResponder()
        } else {
            let newIndexPath = NSIndexPath(forRow: selectedIndexPath!.row-1, inSection: selectedIndexPath!.section)
            let cell = tableView.cellForRowAtIndexPath(newIndexPath)
            if let tf = cell?.viewWithTag(tempoValueTextFieldTag) as? UITextField {
                selectedTextField = tf
                selectedTextField?.becomeFirstResponder()
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
        
        if let cellIndexPath = getCellForView(textField) {
            selectedIndexPath = cellIndexPath
            println("row: \(selectedIndexPath!.row), tag: \(selectedTextField!.tag)")
            nextButton.enabled = selectedIndexPath!.row < tableView.numberOfRowsInSection(0)-1 || selectedTextField!.tag != tempoValueTextFieldTag
            prevButton.enabled = selectedIndexPath!.row > 0 || selectedTextField!.tag != songNameTextFieldTag
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        selectedTextField = nil
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
