//
//  DetailSectionControllers.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit
import IGListKit
import SnapKit

// MARK: - Header Section Controller
class DetailHeaderSectionController: ListSectionController {
    private var feedModel: FeedModel?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let containerWidth = collectionContext?.containerSize.width ?? 0
        guard let feedModel = feedModel else {
            return CGSize(width: containerWidth, height: containerWidth * 0.75)
        }
        
        // imageView 左右各 12 的内边距，所以内容宽度为 containerWidth - 24
        let imageWidth = containerWidth - 24
        let imageHeight = imageWidth * feedModel.imageAspectRatio
        
        // imageView 上下各 8 的内边距，总计 16
        let verticalPadding: CGFloat = 16
        
        return CGSize(width: containerWidth, height: imageHeight + verticalPadding)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: DetailHeaderCell.self, for: self, at: index) as? DetailHeaderCell,
              let feedModel = feedModel else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: feedModel)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let sectionModel = object as? DetailSectionModel else { return }
        feedModel = sectionModel.feedModel
    }
}

// MARK: - Content Section Controller
class DetailContentSectionController: ListSectionController {
    private var feedModel: FeedModel?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let feedModel = feedModel else {
            let width = collectionContext?.containerSize.width ?? 0
            return CGSize(width: width, height: 120)
        }
        
        let width = collectionContext?.containerSize.width ?? 0
        let contentWidth = width - 32 // 左右各16的边距
        
        // 计算标题高度
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let titleHeight = feedModel.title.height(withConstrainedWidth: contentWidth, font: titleFont)
        
        // 计算内容高度
        let contentFont = UIFont.systemFont(ofSize: 15)
        let contentHeight = feedModel.content.height(withConstrainedWidth: contentWidth, font: contentFont)
        
        // 计算标签高度（假设单行，高度约20）
        let tagsHeight: CGFloat = feedModel.tags.isEmpty ? 0 : 20
        
        // 总高度 = 顶部边距 + 标题高度 + 间距 + 内容高度 + 间距 + 标签高度 + 底部边距
        let totalHeight = 12 + titleHeight + 8 + contentHeight + 8 + tagsHeight + 12
        
        return CGSize(width: width, height: max(totalHeight, 120))
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: DetailContentCell.self, for: self, at: index) as? DetailContentCell,
              let feedModel = feedModel else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: feedModel)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let sectionModel = object as? DetailSectionModel else { return }
        feedModel = sectionModel.feedModel
    }
}

// MARK: - Author Section Controller
class DetailAuthorSectionController: ListSectionController {
    private var feedModel: FeedModel?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: 80)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: DetailAuthorCell.self, for: self, at: index) as? DetailAuthorCell,
              let feedModel = feedModel else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: feedModel)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let sectionModel = object as? DetailSectionModel else { return }
        feedModel = sectionModel.feedModel
    }
}

// MARK: - Comments Section Controller
class DetailCommentsSectionController: ListSectionController {
    private var comments: [CommentModel] = []
    
    override func numberOfItems() -> Int {
        return comments.count
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard index < comments.count else {
            let width = collectionContext?.containerSize.width ?? 0
            return CGSize(width: width, height: 80)
        }
        
        let comment = comments[index]
        let width = collectionContext?.containerSize.width ?? 0
        let contentWidth = width - 24 - 40 - 8 // 总宽度 - 左右边距 - 头像宽度 - 头像右边距
        
        // 计算评论内容高度
        let contentFont = UIFont.systemFont(ofSize: 14)
        let contentHeight = comment.content.height(withConstrainedWidth: contentWidth, font: contentFont)
        
        // 总高度 = 顶部边距 + max(头像高度, 内容高度 + 用户名高度 + 时间高度) + 底部边距
        let nameHeight: CGFloat = 20
        let timeHeight: CGFloat = 16
        let avatarHeight: CGFloat = 32
        let textTotalHeight = nameHeight + 4 + contentHeight + 4 + timeHeight
        
        let totalHeight = 12 + max(avatarHeight, textTotalHeight) + 12
        
        return CGSize(width: width, height: max(totalHeight, 80))
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: DetailCommentCell.self, for: self, at: index) as? DetailCommentCell else {
            return UICollectionViewCell()
        }
        
        let comment = comments[index]
        cell.configure(with: comment)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let sectionModel = object as? DetailSectionModel else { return }
        comments = sectionModel.comments ?? []
    }
}
