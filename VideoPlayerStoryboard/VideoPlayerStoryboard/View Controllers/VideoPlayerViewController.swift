//
//  VideoPlayerViewController.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import UIKit
import AVKit

class VideoPlayerViewController: UIViewController {
    // MARK: Private Properties
    private let videoService = VideoService()
    
    private let videoPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .boldSystemFont(ofSize: 20)
        return textView
    }()
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Video Player"
        view.backgroundColor = .white

        
        view.addSubview(videoPlayerView)
        view.addSubview(detailsTextView)
        
        NSLayoutConstraint.activate([videoPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     videoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     videoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     videoPlayerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.3),
                                     detailsTextView.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor),
                                     detailsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     detailsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     detailsTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                let videos = try await videoService.fetchVideos()
                
                guard let video = videos.first else { return }
                guard let url = URL(string: video.hlsURL) else { return }
                
                let player = AVPlayer(url: url)
                
                var playerLayer: AVPlayerLayer
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspect
                playerLayer.frame = CGRect(origin: .zero, size: videoPlayerView.frame.size)

                videoPlayerView.layer.addSublayer(playerLayer)
                detailsTextView.text = video.description
                
                player.play()
            }
            catch {
                print(error)
            }
        }
    }
}
