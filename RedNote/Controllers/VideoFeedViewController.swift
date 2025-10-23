import UIKit
import AVFoundation
import SnapKit

class VideoFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let videos: [FeedModel]
    private let startIndex: Int

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.bounces = false
        cv.alwaysBounceVertical = false
        return cv
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()

    init(videos: [FeedModel], startIndex: Int) {
        self.videos = videos
        self.startIndex = startIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进入视频页面时隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 退出视频页面时显示导航栏
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
        setupBackButton()
        // 配置音频会话，确保静音键下也能播放
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let indexPath = IndexPath(item: startIndex, section: 0)
        // 滚动到起始视频
        if collectionView.bounds.height > 0 {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
        // 自动播放当前可见的视频
        autoplayVisibleVideo()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "VideoCell")
        
        // 确保内容偏移量不会超出边界
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCell else {
            return UICollectionViewCell()
        }
        let model = videos[indexPath.item]
        if let urlString = model.videoURL, let url = URL(string: urlString) {
            cell.configure(with: url, title: model.title, author: model.authorName)
        }
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size // 全屏
    }

    // MARK: - 自动播放管理
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 确保内容偏移量在有效范围内
        ensureValidContentOffset()
        autoplayVisibleVideo()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 确保内容偏移量在有效范围内
            ensureValidContentOffset()
            autoplayVisibleVideo()
        }
    }
    
    private func ensureValidContentOffset() {
        let contentOffset = collectionView.contentOffset
        if contentOffset.y < 0 {
            collectionView.setContentOffset(CGPoint(x: contentOffset.x, y: 0), animated: false)
        }
    }

    private func autoplayVisibleVideo() {
        for cell in collectionView.visibleCells {
            if let videoCell = cell as? VideoCell {
                videoCell.play()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? VideoCell)?.play()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? VideoCell)?.pause()
    }
}
