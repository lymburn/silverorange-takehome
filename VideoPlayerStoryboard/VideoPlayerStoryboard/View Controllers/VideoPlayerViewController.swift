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
    private var player: AVPlayer!
    private var videos: [Video] = []
    private var currentVideoIndex = 0
    private var isVideoPaused = true {
        didSet {
            let playPauseButtonImage = isVideoPaused ? UIImage(named: "play") : UIImage(named: "pause")
            playPauseButton.setImage(playPauseButtonImage, for: .normal)
        }
    }
    
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
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addAction(.init(handler: { _ in self.playPauseButtonTapped() }), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next"), for: .normal)
        button.addAction(.init(handler: { _ in self.nextVideoButtonTapped() }), for: .touchUpInside)
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "previous"), for: .normal)
        button.addAction(.init(handler: { _ in self.previousVideoButtonTapped() }), for: .touchUpInside)
        return button
    }()
    
    private lazy var playbackStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
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
        
        loadVideos()
    }
}

// MARK: Private Functions
private extension VideoPlayerViewController {
    // Load videos from the server and display the first video
    func loadVideos() {
        Task {
            do {
                // Fetch videos from the service and sort them by date
                videos = try await videoService.fetchVideos()
                sortVideosByAscendingDate()

                // Display the first video
                guard let video = videos.first, let url = URL(string: video.hlsURL) else { return }
                
                player = AVPlayer(url: url)
                
                // Create video player layer and add it to the player view layer
                let playerLayer: AVPlayerLayer
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = CGRect(origin: .zero, size: videoPlayerView.frame.size)

                videoPlayerView.layer.addSublayer(playerLayer)
                detailsTextView.text = video.description
                
                // Add playback controls
                videoPlayerView.addSubview(playbackStackView)
                
                NSLayoutConstraint.activate([playbackStackView.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
                                             playbackStackView.widthAnchor.constraint(equalToConstant: videoPlayerView.bounds.width * 0.7),
                                             playbackStackView.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
                                             playbackStackView.heightAnchor.constraint(equalToConstant: videoPlayerView.bounds.height * 0.5)])
            }
            catch {
                print(error)
            }
        }
    }
    
    func sortVideosByAscendingDate() {
        videos = videos.sorted {
            guard let publishedDate1 = $0.publishedDate,
                  let publishedDate2 = $1.publishedDate else { return false }
            
            return publishedDate1.compare(publishedDate2) == .orderedAscending
        }
    }
    
    func updateUI(forVideoIndex index: Int) {
        guard index >= 0 && index < videos.count else { return }
        
        let currentVideo = videos[index]
        
        guard let url = URL(string: currentVideo.hlsURL) else { return }
        
        // Create a new player with the updated video url
        player = AVPlayer(url: url)
        
        // Find the current AVPlayerLayer in the videoPlayerView and update its AVPlayer
        let playerLayer = videoPlayerView.layer.sublayers?.first { $0 is AVPlayerLayer } as! AVPlayerLayer
        playerLayer.player = player
        
        // Make sure the video is paused
        pauseVideo()
        
        // Update video description
        detailsTextView.text = currentVideo.description
    }
    
    func playPauseButtonTapped() {
        guard player != nil else { return }
        
        if isVideoPaused {
            // Play button tapped
            playVideo()
        }
        else {
            // Pause button tapped
            pauseVideo()
        }
    }
    
    func pauseVideo() {
        player.pause()
        isVideoPaused = true
    }
    
    func playVideo() {
        player.play()
        isVideoPaused = false
    }
    
    func nextVideoButtonTapped() {
        guard currentVideoIndex + 1 < videos.count else { return }
        
        currentVideoIndex += 1
        updateUI(forVideoIndex: currentVideoIndex)
    }
    
    func previousVideoButtonTapped() {
        guard currentVideoIndex > 0 else { return }
        
        currentVideoIndex -= 1
        updateUI(forVideoIndex: currentVideoIndex)
    }
}
