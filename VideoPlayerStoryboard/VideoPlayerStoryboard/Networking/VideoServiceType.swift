//
//  VideoServiceType.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import Foundation

protocol VideoServiceType {
    /// Fetches a list of videos from the server.
    func fetchVideos() async throws -> [Video]
}
