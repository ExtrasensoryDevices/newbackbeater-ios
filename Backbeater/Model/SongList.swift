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
    
    func serialize() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func deserialize(data: Data?) -> [SongTempo]? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(Array<SongTempo>.self, from: data)
    }
}


func ==(lhs: SongTempo, rhs: SongTempo) -> Bool {
    return lhs.songName == rhs.songName && lhs.tempoValue == rhs.tempoValue
}