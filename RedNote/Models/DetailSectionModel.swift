//
//  DetailSectionModel.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import Foundation
import IGListDiffKit

enum DetailSectionType {
    case header
    case content
    case author
    case comments
}

class DetailSectionModel: NSObject {
    let type: DetailSectionType
    let feedModel: FeedModel?
    let comments: [CommentModel]?
    
    init(type: DetailSectionType, feedModel: FeedModel? = nil, comments: [CommentModel]? = nil) {
        self.type = type
        self.feedModel = feedModel
        self.comments = comments
        super.init()
    }
}

extension DetailSectionModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(type)" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailSectionModel else { return false }
        return type == object.type
    }
}

class CommentModel: NSObject {
    let id: String
    let authorName: String
    let authorAvatar: String
    let content: String
    let likeCount: Int
    let time: Int
    
    init(id: String, authorName: String, authorAvatar: String, content: String, likeCount: Int, time: Int) {
        self.id = id
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.content = content
        self.likeCount = likeCount
        self.time = time
        super.init()
    }
}
