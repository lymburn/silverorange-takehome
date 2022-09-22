//
//  VideoPlayerViewController.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import UIKit

class VideoPlayerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Video Player"
        
        let videoService = VideoService()
        
        Task {
            do {
                let videos = try await videoService.fetchVideos()
                
                print(videos)
            }
            catch {
                print(error)
            }
        }
    }
}
