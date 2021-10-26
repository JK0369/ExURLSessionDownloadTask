//
//  TrackResponse.swift
//  ExURLSession
//
//  Created by 김종권 on 2021/10/25.
//

import Foundation

struct TrackResponse: Codable {
    let resultCount: Int
    let results: [Result]

    struct Result: Codable {
        let artistName: String
        let trackName: String
        let previewURL: String

        enum CodingKeys: String, CodingKey {
            case artistName
            case trackName
            case previewURL = "previewUrl"
        }
    }
}

extension TrackResponse {
    var toDomain: [Track] {
        var tracks = [Track]()
        for i in 0..<resultCount {
            let trackElement = results[i]
            guard let url = URL(string: trackElement.previewURL) else { continue }
            let track = Track(name: trackElement.trackName, artist: trackElement.artistName, previewURL: url, index: i)
            tracks.append(track)
        }
        return tracks
    }
}
