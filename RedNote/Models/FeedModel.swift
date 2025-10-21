//
//  FeedModel.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import Foundation
import IGListDiffKit
import UIKit

class FeedModel: NSObject {
    let id: String
    let title: String
    let content: String
    let imageURL: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let authorName: String
    let authorAvatar: String
    let likeCount: Int
    let commentCount: Int
    let tags: [String]
    
    init(id: String, title: String, content: String, imageURL: String, imageWidth: CGFloat, imageHeight: CGFloat, authorName: String, authorAvatar: String, likeCount: Int, commentCount: Int, tags: [String]) {
        self.id = id
        self.title = title
        self.content = content
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.tags = tags
        super.init()
    }
    
    // 计算图片的宽高比
    var imageAspectRatio: CGFloat {
        guard imageWidth > 0 else { return 1.2 } // 默认宽高比
        return imageHeight / imageWidth
    }
}

// MARK: - ListDiffable
extension FeedModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? FeedModel else { return false }
        return id == object.id &&
               title == object.title &&
               content == object.content &&
               likeCount == object.likeCount &&
               commentCount == object.commentCount
    }
}

// MARK: - String Extension for Height Calculation
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont, maxLines: Int = 0) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        let height = ceil(boundingBox.height)
        
        if maxLines > 0 {
            let lineHeight = font.lineHeight
            let maxHeight = lineHeight * CGFloat(maxLines)
            return min(height, maxHeight)
        }
        
        return height
    }
}
