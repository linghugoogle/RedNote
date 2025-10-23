import UIKit
import AVFoundation
import SnapKit

class VideoCell: UICollectionViewCell {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let overlayTitle = UILabel()
    private let overlayAuthor = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    // 播放控制相关 UI
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.value = 0
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "00:00"
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "00:00"
        return label
    }()
    
    private var isPlaying = false
    private var controlsVisible = false
    private var hideControlsTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
        gradientLayer.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        pause()
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        isPlaying = false
        controlsVisible = false
    }

    private func setupUI() {
        backgroundColor = .black

        overlayTitle.textColor = .white
        overlayTitle.font = UIFont.boldSystemFont(ofSize: 18)
        overlayTitle.numberOfLines = 2

        overlayAuthor.textColor = .lightGray
        overlayAuthor.font = UIFont.systemFont(ofSize: 14)

        contentView.addSubview(overlayTitle)
        contentView.addSubview(overlayAuthor)
        contentView.addSubview(playPauseButton)
        contentView.addSubview(progressSlider)
        contentView.addSubview(currentTimeLabel)
        contentView.addSubview(totalTimeLabel)

        overlayTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-60)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }

        overlayAuthor.snp.makeConstraints { make in
            make.left.equalTo(overlayTitle)
            make.top.equalTo(overlayTitle.snp.bottom).offset(8)
        }
        
        // 播放/暂停按钮 - 居中
        playPauseButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        // 进度条
        progressSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-120)
        }
        
        // 当前时间
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(progressSlider)
            make.top.equalTo(progressSlider.snp.bottom).offset(8)
        }
        
        // 总时间
        totalTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(progressSlider)
            make.top.equalTo(progressSlider.snp.bottom).offset(8)
        }

        // 底部渐变提升可读性
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradientLayer.locations = [0.6, 1.0]
        contentView.layer.addSublayer(gradientLayer)
        
        // 添加手势识别
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        
        // 按钮事件
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        // 初始显示控制元素
        showControls()
    }

    func configure(with url: URL, title: String, author: String) {
        overlayTitle.text = title
        overlayAuthor.text = author

        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        contentView.layer.insertSublayer(playerLayer, at: 0)

        self.player = player
        self.playerLayer = playerLayer

        // 静音自动播放（如需声音可移除）
        player.isMuted = false
        
        // 添加播放时间观察者
        let timeInterval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            self?.updateProgress()
        }
        
        // 监听播放完成
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    @objc private func handleTap() {
        if controlsVisible {
            hideControls()
        } else {
            showControls()
        }
    }
    
    @objc private func playPauseButtonTapped() {
        if isPlaying {
            pause()
        } else {
            play()
        }
        resetHideControlsTimer()
    }
    
    @objc private func progressSliderChanged() {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let targetTime = totalSeconds * Double(progressSlider.value)
        let seekTime = CMTime(seconds: targetTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: seekTime)
        resetHideControlsTimer()
    }
    
    @objc private func playerDidFinishPlaying() {
        // 播放完成后重置到开头并自动重新播放
        player?.seek(to: CMTime.zero)
        progressSlider.value = 0
        currentTimeLabel.text = "00:00"
        
        // 自动重新播放
        player?.play()
        isPlaying = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        // 显示控制元素并设置自动隐藏
        showControls()
    }
    
    private func updateProgress() {
        guard let player = player, let currentItem = player.currentItem else { return }
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let duration = CMTimeGetSeconds(currentItem.duration)
        
        if !duration.isNaN && duration > 0 {
            progressSlider.value = Float(currentTime / duration)
            currentTimeLabel.text = formatTime(currentTime)
            totalTimeLabel.text = formatTime(duration)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func showControls() {
        controlsVisible = true
        playPauseButton.isHidden = false
        progressSlider.isHidden = false
        currentTimeLabel.isHidden = false
        totalTimeLabel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.playPauseButton.alpha = 1
            self.progressSlider.alpha = 1
            self.currentTimeLabel.alpha = 1
            self.totalTimeLabel.alpha = 1
        }
        resetHideControlsTimer()
    }
    
    private func hideControls() {
        controlsVisible = false
        UIView.animate(withDuration: 0.3, animations: {
            self.playPauseButton.alpha = 0
            self.progressSlider.alpha = 0
            self.currentTimeLabel.alpha = 0
            self.totalTimeLabel.alpha = 0
        }) { _ in
            self.playPauseButton.isHidden = true
            self.progressSlider.isHidden = true
            self.currentTimeLabel.isHidden = true
            self.totalTimeLabel.isHidden = true
        }
        hideControlsTimer?.invalidate()
    }
    
    private func resetHideControlsTimer() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            if self?.isPlaying == true {
                self?.hideControls()
            }
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }

    func pause() {
        player?.pause()
        isPlaying = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
}
