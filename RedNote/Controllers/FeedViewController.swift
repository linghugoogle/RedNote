//
//  FeedViewController.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit
import IGListKit
import SnapKit
import MJRefresh

class FeedViewController: UIViewController {

    // MARK: - Properties
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    private let collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.delegate = nil // 将在 viewDidLoad 中设置
        layout.numberOfColumns = 2
        layout.minimumColumnSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private var feedData: [FeedModel] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAdapter()
        setupRefresh()
        loadMockData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 视图尺寸就绪后强制刷新布局，避免初次等高
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupUI() {
        title = "小红书"
        view.backgroundColor = .white

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        // 设置瀑布流布局的代理
        if let layout = collectionView.collectionViewLayout as? WaterfallLayout {
            layout.delegate = self
        }
        collectionView.alwaysBounceVertical = true
    }

    private func setupAdapter() {
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    private func loadMockData() {
        feedData = [
            FeedModel(id: "1", title: "美丽的日落风景", content: "今天看到了超美的日落，分享给大家", imageURL: "https://picsum.photos/id/1018/300/400", imageWidth: 300, imageHeight: 400, authorName: "小红", authorAvatar: "https://picsum.photos/id/64/50/50", likeCount: 128, commentCount: 23, tags: ["风景", "日落"]),
            FeedModel(id: "2", title: "今日穿搭分享", content: "简约风格的穿搭，很适合秋天", imageURL: "https://picsum.photos/id/1025/300/500", imageWidth: 300, imageHeight: 500, authorName: "时尚达人", authorAvatar: "https://picsum.photos/id/91/50/50", likeCount: 256, commentCount: 45, tags: ["穿搭", "时尚"]),
            FeedModel(id: "3", title: "美食制作教程", content: "教大家做一道简单的家常菜", imageURL: "https://picsum.photos/id/292/300/350", imageWidth: 300, imageHeight: 350, authorName: "美食家", authorAvatar: "https://picsum.photos/id/177/50/50", likeCount: 89, commentCount: 12, tags: ["美食", "教程"]),
            FeedModel(id: "4", title: "旅行日记", content: "这次旅行真的太棒了，风景如画", imageURL: "https://picsum.photos/id/1036/300/450", imageWidth: 300, imageHeight: 450, authorName: "旅行者", authorAvatar: "https://picsum.photos/id/237/50/50", likeCount: 345, commentCount: 67, tags: ["旅行", "风景"]),
            FeedModel(id: "5", title: "护肤心得分享", content: "最近用的护肤品效果很好", imageURL: "https://picsum.photos/id/225/300/380", imageWidth: 300, imageHeight: 380, authorName: "护肤达人", authorAvatar: "https://picsum.photos/id/338/50/50", likeCount: 178, commentCount: 34, tags: ["护肤", "美妆"]),
            FeedModel(id: "6", title: "健身打卡", content: "坚持健身第30天，感觉身体越来越好", imageURL: "https://picsum.photos/id/375/300/420", imageWidth: 300, imageHeight: 420, authorName: "健身教练", authorAvatar: "https://picsum.photos/id/453/50/50", likeCount: 234, commentCount: 56, tags: ["健身", "运动"]),
            FeedModel(id: "7", title: "咖啡时光", content: "下午茶时间，享受一杯香浓的咖啡", imageURL: "https://picsum.photos/id/429/300/360", imageWidth: 300, imageHeight: 360, authorName: "咖啡爱好者", authorAvatar: "https://picsum.photos/id/507/50/50", likeCount: 156, commentCount: 28, tags: ["咖啡", "生活"]),
            FeedModel(id: "8", title: "宠物日常", content: "我家小猫咪今天特别可爱", imageURL: "https://picsum.photos/id/593/300/480", imageWidth: 300, imageHeight: 480, authorName: "铲屎官", authorAvatar: "https://picsum.photos/id/646/50/50", likeCount: 289, commentCount: 42, tags: ["宠物", "猫咪"]),
            FeedModel(id: "v1",
                      title: "买手机",
                      content: "示例视频：Big Buck Bunny",
                      imageURL: "https://picsum.photos/id/1050/300/400",
                      imageWidth: 300,
                      imageHeight: 400,
                      authorName: "ZJOL",
                      authorAvatar: "https://picsum.photos/id/64/50/50",
                      likeCount: 1024,
                      commentCount: 88,
                      tags: ["视频", "示例"],
                      videoURL: "https://v-cdn.zjol.com.cn/280443.mp4",
                      videoCoverURL: "https://picsum.photos/id/1050/600/800"),
            FeedModel(id: "v2",
                      title: "产品宣传",
                      content: "示例视频：For Bigger Blazes",
                      imageURL: "https://picsum.photos/id/1044/300/400",
                      imageWidth: 300,
                      imageHeight: 400,
                      authorName: "西瓜",
                      authorAvatar: "https://picsum.photos/id/91/50/50",
                      likeCount: 768,
                      commentCount: 56,
                      tags: ["视频", "示例"],
                      videoURL: "https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4",
                      videoCoverURL: "https://picsum.photos/id/1044/600/800")
        ]

        adapter.performUpdates(animated: true)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupRefresh() {
        let header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        header.stateLabel?.textColor = .gray
        collectionView.mj_header = header
    }

    private func refreshData() {
        // 下拉刷新：重新加载数据
        loadMockData()
        // 结束刷新并重算瀑布流布局
        collectionView.mj_header?.endRefreshing()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - ListAdapterDataSource
extension FeedViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return feedData
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = FeedSectionController()
        sectionController.delegate = self
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let emptyView = UIView()
        let label = UILabel()
        label.text = "暂无内容"
        label.textColor = .gray
        label.textAlignment = .center
        emptyView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return emptyView
    }
}

// MARK: - FeedSectionControllerDelegate
extension FeedViewController: FeedSectionControllerDelegate {
    func feedSectionController(_ controller: FeedSectionController, didSelectFeed feed: FeedModel) {
        if feed.isVideo {
            // 收集所有视频列表，并从当前视频开始播放
            let videos = feedData.filter { $0.isVideo }
            let startIndex = videos.firstIndex(where: { $0.id == feed.id }) ?? 0
            let vc = VideoFeedViewController(videos: videos, startIndex: startIndex)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let detailVC = FeedDetailViewController(feedModel: feed)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - WaterfallLayoutDelegate
extension FeedViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        // 使用 section 作为索引（IGListKit 每个 section 一个 item）
        guard indexPath.section < feedData.count else { return 250 }

        let feed = feedData[indexPath.section]

        // 获取 collectionView 的宽度来计算 cell 宽度
        let collectionViewWidth = collectionView.bounds.width
        let cellWidth = (collectionViewWidth - layout.sectionInset.left - layout.sectionInset.right - CGFloat(layout.numberOfColumns - 1) * layout.minimumColumnSpacing) / CGFloat(layout.numberOfColumns)

        // 1. 图片高度 (根据实际图片宽高比计算)
        let imageHeight = cellWidth * feed.imageAspectRatio

        // 2. 标题高度 (最多 2 行)
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleWidth = cellWidth - 16 // 减去左右内边距
        let titleHeight = feed.title.height(withConstrainedWidth: titleWidth, font: titleFont, maxLines: 2)

        // 3. 固定元素高度
        let topPadding: CGFloat = 8             // 图片到标题的间距
        let titleToAuthorSpacing: CGFloat = 8   // 标题到作者信息的间距
        let authorSectionHeight: CGFloat = 24   // 头像高度
        let bottomPadding: CGFloat = 8          // 底部间距

        // 总高度
        let totalHeight = imageHeight + topPadding + titleHeight + titleToAuthorSpacing + authorSectionHeight + bottomPadding

        print("Cell \(indexPath.section): imageHeight=\(imageHeight), titleHeight=\(titleHeight), totalHeight=\(totalHeight)")
        return totalHeight
    }
}
