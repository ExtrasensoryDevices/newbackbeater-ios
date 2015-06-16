//
//  SongListViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-15.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

protocol SongListViewControllerDelegate: class {
    func songListViewControllerDidReturnSongList(songList: [SongTempo])
}

class SongListViewController: UIViewController {
    
    weak var delegate:SongListViewControllerDelegate?

    @IBAction func didTapClose(sender: AnyObject) {
        
        let songList = [SongTempo(songName:"Song #1", tempoValue: 120),
            SongTempo(songName:"Song #2", tempoValue: 60),
            SongTempo(songName:"Song #3", tempoValue: 90)]
        
        delegate?.songListViewControllerDidReturnSongList(songList)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
