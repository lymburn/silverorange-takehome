//
//  Video.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import Foundation

struct Video: Decodable {
    let id: String
    let title: String
    let hlsURL: String
    let fullURL: String
    let description: String
    let publishedAt: String
    let author: Author
}

extension Video {
    /// Published date of the video after parsing it from ISO-8601 format. Returns nil if unable to parse.
    var publishedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        return formatter.date(from: publishedAt)
    }
}
