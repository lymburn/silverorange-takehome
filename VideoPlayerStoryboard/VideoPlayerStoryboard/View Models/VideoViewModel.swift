//
//  VideoViewModel.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import Foundation

class VideoViewModel {
    // MARK: Public Properties
    var descriptionText: String {
        let videoTitle = video.title
        let videoAuthor = video.author.name
        
        // Append video title and author to the beginning of the video description as 2 separate lines
        let videoTitleMarkdownString = "#\(videoTitle)\n"
        let videoAuthorMarkdownString = "#\(videoAuthor)\n\n"
        
        let description = videoTitleMarkdownString.appending(videoAuthorMarkdownString).appending(video.description)
        
        return description
    }
    
    let video: Video
    
    // MARK: Initialization
    init(video: Video) {
        self.video = video
    }
}
