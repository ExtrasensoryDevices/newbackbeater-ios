//
//  SongListCell.swift
//  Backbeater
//
//  Created by Alina on 2015-06-16.
//

import UIKit

class SongListCell: UITableViewCell {

    @IBOutlet weak var songNameTextField: UITextField!
    @IBOutlet weak var tempoValueTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songNameTextField.backgroundColor = ColorPalette.Black.color()
        tempoValueTextField.backgroundColor = ColorPalette.Black.color()
        
        songNameTextField.font = Font.FuturaDemi.get(13)
        tempoValueTextField.font = Font.FuturaBook.get(14)
        
        songNameTextField.minimumFontSize = 13
        tempoValueTextField.minimumFontSize = 14
        
        tempoValueTextField.drawBorder()
        
        songNameTextField.editingRectForBounds(songNameTextField.bounds)
        tempoValueTextField.editingRectForBounds(tempoValueTextField.bounds)
        
    }
    
    @IBAction func didTapDelete(sender: AnyObject) {
        println("didTapDelete")
    }
    
    
    
}
