//
//  VideoPlayerViewController.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import UIKit
import AVKit
import MarkdownKit

class VideoPlayerViewController: UIViewController {
    // MARK: Private Properties
    private var player: AVPlayer!
    private var videoViewModels: [VideoViewModel] = []
    private var currentVideoIndex = 0
    private var isVideoPaused = true {
        didSet {
            let playPauseButtonImage = isVideoPaused ? UIImage(named: "play") : UIImage(named: "pause")
            playPauseButton.setImage(playPauseButtonImage, for: .normal)
        }
    }
    
    private let markdownParser = MarkdownParser()
    private let videoService = VideoService()
    
    private let videoPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private let detailsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addAction(.init(handler: { _ in self.playPauseButtonTapped() }), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next"), for: .normal)
        button.addAction(.init(handler: { _ in self.nextVideoButtonTapped() }), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "previous"), for: .normal)
        button.addAction(.init(handler: { _ in self.previousVideoButtonTapped() }), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()
    
    private lazy var playbackStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 60
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
                var videos = try await videoService.fetchVideos()
                sortVideosByAscendingDate(videos: &videos)
                
                // Populate video view models with the fetched videos
                videoViewModels = videos.map { VideoViewModel(video: $0) }

                // Display the first video
                guard let videoViewModel = videoViewModels.first, let url = URL(string: videoViewModel.video.hlsURL) else { return }
                
                player = AVPlayer(url: url)
                
                // Create video player layer and add it to the player view layer
                let playerLayer: AVPlayerLayer
                playerLayer = AVPlayerLayer(player: player)
                // Using resizeAspect instead of resizeAspectFill or the video will get cut out
                playerLayer.videoGravity = .resizeAspect
                playerLayer.frame = CGRect(origin: .zero, size: videoPlayerView.frame.size)

                videoPlayerView.layer.addSublayer(playerLayer)
                detailsTextView.attributedText = markdownParser.parse(videoViewModel.descriptionText)
                
                // Add playback controls
                // NOTE: I am assuming the playback controls are always displayed as it does not mention otherwise.
                // Additionally, I did not have time to add a circular gray background to the buttons as shown in the wireframe.
                videoPlayerView.addSubview(playbackStackView)
                
                NSLayoutConstraint.activate([playbackStackView.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
                                             playbackStackView.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor)])
            }
            catch {
                self.showAlert(alertTitle: "Server Error", alertMessage: "Failed to fetch videos from the server.")
            }
        }
    }
    
    func sortVideosByAscendingDate(videos: inout [Video]) {
        videos = videos.sorted {
            guard let publishedDate1 = $0.publishedDate,
                  let publishedDate2 = $1.publishedDate else { return false }
            
            return publishedDate1.compare(publishedDate2) == .orderedAscending
        }
    }
    
    func updateUI(forVideoIndex index: Int) {
        guard index >= 0 && index < videoViewModels.count else { return }
        
        let currentVideoViewModel = videoViewModels[index]
        
        guard let url = URL(string: currentVideoViewModel.video.hlsURL) else { return }
        
        // Create a new player with the updated video url
        player = AVPlayer(url: url)
        
        // Find the current AVPlayerLayer in the videoPlayerView and update its AVPlayer
        let playerLayer = videoPlayerView.layer.sublayers?.first { $0 is AVPlayerLayer } as! AVPlayerLayer
        playerLayer.player = player
        
        // Make sure the video is paused
        pauseVideo()
        
        // Update video description
        detailsTextView.attributedText = markdownParser.parse(currentVideoViewModel.descriptionText)
    }
    
    func playPauseButtonTapped() {
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
        guard player != nil else { return }
        
        player.pause()
        isVideoPaused = true
    }
    
    func playVideo() {
        guard player != nil else { return }
        
        player.play()
        isVideoPaused = false
    }
    
    func nextVideoButtonTapped() {
        guard currentVideoIndex + 1 < videoViewModels.count else { return }
        
        currentVideoIndex += 1
        updateUI(forVideoIndex: currentVideoIndex)
    }
    
    func previousVideoButtonTapped() {
        guard currentVideoIndex > 0 else { return }
        
        currentVideoIndex -= 1
        updateUI(forVideoIndex: currentVideoIndex)
    }
}
