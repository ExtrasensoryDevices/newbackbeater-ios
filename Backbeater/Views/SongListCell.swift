//
//  SongListCell.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-16.
//

import UIKit

class SongListCell: UITableViewCell {

    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var tempoValueLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songNameLabel.font = Font.FuturaDemi.get(13)
        tempoValueLabel.font = Font.FuturaBook.get(14)
        
        tempoValueLabel.drawBorder()
        
    }
}
