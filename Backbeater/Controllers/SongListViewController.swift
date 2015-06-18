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
    
    
    weak var currentTextField:UITextField?
    
    var keyboardToolbar:UIToolbar!
    var nextButton: UIBarButtonItem!
    var prevButton: UIBarButtonItem!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorPalette.Black.color()
        tableView.backgroundColor = ColorPalette.Black.color()
        tableView.backgroundView = nil
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "tableViewLongPress:"))
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
        
        let frame = CGRectMake(0, 0, 320, 40)
        
        keyboardToolbar = UIToolbar(frame: frame)
        keyboardToolbar.barTintColor = ColorPalette.KeyboardBg.color()
        keyboardToolbar.items = [prevButton, nextButton, flexibleSpace, submitButton]
        
        // create bottom line
        let borderView = UIView(frame: CGRectMake(0, 39, 320, 1))
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
            
//            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SongListCell {
//                let pointInCell = cell.convertPoint(p, fromView:self.tableView)
//                
//                if CGRectContainsPoint(cell.songNameLabel.frame, pointInCell) {
//                    println("longpress in song name")
//                } else if CGRectContainsPoint(cell.tempoValueLabel.frame, pointInCell) {
//                    println("longpress in tempo value")
//                }
//            }
        }
    }
        
        // MARK: - Keyboard
        
        func didTapDoneButton() {
            currentTextField?.resignFirstResponder()
            currentTextField = nil
        }
        
        func didTapNextButton() {
//            if currentTextField == songNameTextField {
//                tempoValueTextField.becomeFirstResponder()
//                currentTextField = tempoValueTextField
//            }
        }
        
        func didTapPrevButton() {
//            if currentTextField == tempoValueTextField {
//                songNameTextField.becomeFirstResponder()
//                currentTextField = songNameTextField
//            }
        }
        
        func textFieldDidBeginEditing(textField: UITextField) {
//            currentTextField = textField
//            nextButton.enabled = currentTextField == songNameTextField
//            prevButton.enabled = currentTextField == tempoValueTextField
        }
        
        
        func textFieldShouldReturn(textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            currentTextField = nil
            return true
        }
        

}
