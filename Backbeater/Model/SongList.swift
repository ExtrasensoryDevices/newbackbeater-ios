//
//  SongList.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-08.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import Foundation


struct SongTempo: Equatable, Codable {
    var songName:String
    var tempoValue:Int
    
    init(songName: String, tempoValue:  Int) {
        self.songName = songName.uppercased()
        self.tempoValue = tempoValue
    }
}


func ==(lhs: SongTempo, rhs: SongTempo) -> Bool {
    return lhs.songName == rhs.songName && lhs.tempoValue == rhs.tempoValue
}


extension Array where Element == SongTempo {

    func prepareToSave(_ songList:[SongTempo]?) -> Data? {
        return try? JSONEncoder().encode(songList)
    }

    static func restoreSongTempoList(_ data:Data) -> [SongTempo]? {
        //if let data = UserDefaults.standard.value(forKey:"songs") as? Data {
            return try? JSONDecoder().decode(Array<SongTempo>.self, from: data)
        //}
    }

}
