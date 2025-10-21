//
//  DetailCells.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit
import SnapKit
import SDWebImage

// MARK: - Detail Header Cell
class DetailHeaderCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    
    func timestampToDateString(timestamp: TimeInterval, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 12
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(with model: FeedModel) {
        if let url = URL(string: model.imageURL) {
            imageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.progressiveLoad, .retryFailed]
            ) { [weak self] image, error, cacheType, url in
                if error == nil {
                    self?.imageView.backgroundColor = .clear
                }
            }
        }
    }
}

// MARK: - Detail Content Cell
class DetailContentCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let tagsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = .darkGray
        contentLabel.numberOfLines = 0
        
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading
        tagsStackView.distribution = .fillProportionally
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(tagsStackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(12)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        
        tagsStackView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    func configure(with model: FeedModel) {
        titleLabel.text = model.title
        contentLabel.text = model.content
        
        // 清除之前的标签
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 添加标签
        for tag in model.tags {
            let tagLabel = UILabel()
            tagLabel.text = "#\(tag)"
            tagLabel.font = UIFont.systemFont(ofSize: 13)
            tagLabel.textColor = .systemBlue
            tagLabel.backgroundColor = .clear // 去掉背景色
            tagLabel.textAlignment = .left
            
            tagsStackView.addArrangedSubview(tagLabel)
        }
    }
}

// MARK: - Detail Author Cell
class DetailAuthorCell: UICollectionViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let followButton = UIButton()
    private let likeButton = UIButton()
    private let likeCountLabel = UILabel()
    private let commentButton = UIButton()
    private let commentCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.backgroundColor = .systemGray5
        
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .black
        
        followButton.setTitle("关注", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = .systemRed
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        followButton.layer.cornerRadius = 16
        followButton.contentEdgeInsets = UIEdgeInsets(top: 6, left:16, bottom: 6, right: 16)
        
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .systemGray
        
        likeCountLabel.font = UIFont.systemFont(ofSize: 14)
        likeCountLabel.textColor = .systemGray
        
        commentButton.setImage(UIImage(systemName: "message"), for: .normal)
        commentButton.tintColor = .systemGray
        
        commentCountLabel.font = UIFont.systemFont(ofSize: 14)
        commentCountLabel.textColor = .systemGray
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(followButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentButton)
        contentView.addSubview(commentCountLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        followButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.right.equalTo(followButton.snp.left).offset(-20)
            make.centerY.equalToSuperview()
        }
        
        commentButton.snp.makeConstraints { make in
            make.right.equalTo(commentCountLabel.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.right.equalTo(commentButton.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints { make in
            make.right.equalTo(likeCountLabel.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    func configure(with model: FeedModel) {
        nameLabel.text = model.authorName
        likeCountLabel.text = "\(model.likeCount)"
        commentCountLabel.text = "\(model.commentCount)"
        
        if let url = URL(string: model.authorAvatar) {
            avatarImageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.progressiveLoad, .retryFailed]
            ) { [weak self] image, error, cacheType, url in
                if error == nil {
                    self?.avatarImageView.backgroundColor = .clear
                }
            }
        }
    }
}

// MARK: - Detail Comment Cell
class DetailCommentCell: UICollectionViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let contentLabel = UILabel()
    private let likeButton = UIButton()
    private let likeCountLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.backgroundColor = .systemGray5
        
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .black
        
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = .black
        contentLabel.numberOfLines = 0
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .systemGray4
        
        likeCountLabel.font = UIFont.systemFont(ofSize: 12)
        likeCountLabel.textColor = .systemGray
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(likeCountLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(8)
            make.top.equalTo(avatarImageView.snp.top)
            make.right.lessThanOrEqualTo(likeButton.snp.left).offset(-8)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        likeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerX.equalTo(likeButton)
            make.top.equalTo(likeButton.snp.bottom).offset(2)
        }
    }
    
    func configure(with model: CommentModel) {
        nameLabel.text = model.authorName
        contentLabel.text = model.content
        likeCountLabel.text = "\(model.likeCount)"
        timeLabel.text = timestampToDateString(timestamp: TimeInterval(model.time), format: "yyyy-MM-dd hh:mm:ss a")
        
        if let url = URL(string: model.authorAvatar) {
            avatarImageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.progressiveLoad, .retryFailed]
            ) { [weak self] image, error, cacheType, url in
                if error == nil {
                    self?.avatarImageView.backgroundColor = .clear
                }
            }
        }
    }
    
    func timestampToDateString(timestamp: TimeInterval, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
           let date = Date(timeIntervalSince1970: timestamp)
           let formatter = DateFormatter()
           formatter.dateFormat = format
           formatter.timeZone = TimeZone.current
           formatter.locale = Locale.current
           return formatter.string(from: date)
       }
}
