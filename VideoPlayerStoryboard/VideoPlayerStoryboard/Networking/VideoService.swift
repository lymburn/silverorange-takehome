//
//  VideoService.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import Foundation

class VideoService: VideoServiceType {
    func fetchVideos() async throws -> [Video] {
        guard let url = URL(string: Endpoints.videos.rawValue) else { return [] }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let videos = try JSONDecoder().decode([Video].self, from: data)
        
        return videos
    }
}
