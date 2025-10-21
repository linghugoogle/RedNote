//
//  FeedSectionController.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit
import IGListKit

protocol FeedSectionControllerDelegate: AnyObject {
    func feedSectionController(_ controller: FeedSectionController, didSelectFeed feed: FeedModel)
}

class FeedSectionController: ListSectionController {

    private var feedModel: FeedModel?
    weak var delegate: FeedSectionControllerDelegate?

    override func sizeForItem(at index: Int) -> CGSize {
        // 对于WaterfallLayout，返回固定宽度，高度由WaterfallLayoutDelegate计算
        guard feedModel != nil else {
            let width = (collectionContext?.containerSize.width ?? 0 - 24) / 2
            return CGSize(width: width, height: 250)
        }

        let containerWidth = collectionContext?.containerSize.width ?? 0
        let width = (containerWidth - 24) / 2 // 减去左右边距(8*2)和中间间距(8)

        // 这里返回一个基础高度，实际高度由waterfallLayout delegate方法决定
        return CGSize(width: width, height: 250)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: FeedCell.self, for: self, at: index) as? FeedCell,
              let feedModel = feedModel else {
            return UICollectionViewCell()
        }

        cell.configure(with: feedModel)
        cell.onTapAction = { [weak self] in
            guard let self = self, let feed = self.feedModel else { return }
            self.delegate?.feedSectionController(self, didSelectFeed: feed)
        }

        return cell
    }

    override func didSelectItem(at index: Int) {
        guard let feedModel = feedModel else { return }
        delegate?.feedSectionController(self, didSelectFeed: feedModel)
    }

    override func didUpdate(to object: Any) {
        feedModel = object as? FeedModel
    }
}
