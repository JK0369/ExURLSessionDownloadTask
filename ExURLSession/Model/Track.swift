//
//  Track.swift
//  ExURLSession
//
//  Created by 김종권 on 2021/10/25.
//

import Foundation

class Track {
    let name: String
    let artist: String
    let previewURL: URL
    let index: Int
    var downloaded = false

    init(name: String, artist: String, previewURL: URL, index: Int) {
        self.name = name
        self.artist = artist
        self.previewURL = previewURL
        self.index = index
    }
}
