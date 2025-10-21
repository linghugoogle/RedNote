//
//  FeedDetailViewController.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit
import IGListKit
import SnapKit

class FeedDetailViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    private let feedModel: FeedModel
    private var sectionData: [DetailSectionModel] = []
    
    // MARK: - Initialization
    init(feedModel: FeedModel) {
        self.feedModel = feedModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAdapter()
        loadData()
    }
    
    private func setupUI() {
        title = "详情"
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    private func setupAdapter() {
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    private func loadData() {
        // 创建模拟评论数据
        let mockComments = [
            CommentModel(
                id: "1",
                authorName: "小美",
                authorAvatar: "https://picsum.photos/id/103/100/100",
                content: "太美了！这个地方在哪里呀？",
                likeCount: 10,
                time: 1761097276
            ),
            CommentModel(
                id: "2",
                authorName: "旅行达人",
                authorAvatar: "https://picsum.photos/id/213/100/100",
                content: "拍得真好看，构图很棒！",
                likeCount: 8,
                time: 1761097276
            ),
            CommentModel(
                id: "3",
                authorName: "摄影爱好者",
                authorAvatar: "https://picsum.photos/id/342/100/100",
                content: "请问用的什么相机拍的？色彩很棒",
                likeCount: 2,
                time: 1761097276
            )
        ]
        
        sectionData = [
            DetailSectionModel(type: .header, feedModel: feedModel),
            DetailSectionModel(type: .content, feedModel: feedModel),
            DetailSectionModel(type: .author, feedModel: feedModel),
            DetailSectionModel(type: .comments, comments: mockComments)
        ]
        
        adapter.performUpdates(animated: true)
    }
}

// MARK: - ListAdapterDataSource
extension FeedDetailViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sectionData
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let sectionModel = object as? DetailSectionModel else {
            return ListSectionController()
        }
        
        switch sectionModel.type {
        case .header:
            return DetailHeaderSectionController()
        case .content:
            return DetailContentSectionController()
        case .author:
            return DetailAuthorSectionController()
        case .comments:
            return DetailCommentsSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
