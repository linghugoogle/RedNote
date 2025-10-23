//
//  FeedCell.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit
import SnapKit
import SDWebImage

class FeedCell: UICollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorAvatarImageView = UIImageView()
    private let authorNameLabel = UILabel()
    private let likeButton = UIButton()
    private let likeCountLabel = UILabel()
    // 播放浮层（视频时显示）
    private let playOverlayView = UIImageView(image: UIImage(systemName: "play.circle.fill"))

    // MARK: - Properties
    var onTapAction: (() -> Void)?
    private var imageHeightConstraint: NSLayoutConstraint?
    private var titleHeightConstraint: Constraint? // 添加标题高度约束引用

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // SDWebImage会自动处理图片复用问题
        imageView.sd_cancelCurrentImageLoad()
        authorAvatarImageView.sd_cancelCurrentImageLoad()
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2

        authorAvatarImageView.contentMode = .scaleAspectFill
        authorAvatarImageView.clipsToBounds = true
        authorAvatarImageView.layer.cornerRadius = 12
        authorAvatarImageView.backgroundColor = .systemGray5

        authorNameLabel.font = UIFont.systemFont(ofSize: 12)
        authorNameLabel.textColor = .gray

        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .systemRed

        likeCountLabel.font = UIFont.systemFont(ofSize: 12)
        likeCountLabel.textColor = .gray

        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorAvatarImageView)
        containerView.addSubview(authorNameLabel)
        containerView.addSubview(likeButton)
        containerView.addSubview(likeCountLabel)
        playOverlayView.tintColor = .white
        playOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        playOverlayView.contentMode = .scaleAspectFit
        playOverlayView.isHidden = true
        contentView.addSubview(playOverlayView)
    }

    private func setupConstraints() {
        // 容器视图约束
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 图片约束 - 顶部对齐，左右对齐
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            // 高度约束将在configure方法中根据实际图片宽高比设置
        }

        // 标题约束 - 在图片下方，设置高度约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            // 初始高度约束，将在configure方法中动态更新
            titleHeightConstraint = make.height.equalTo(20).constraint
        }

        // 头像约束 - 在标题下方
        authorAvatarImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-8) // 设置底部约束
        }

        // 点赞按钮约束 - 右侧对齐
        likeButton.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarImageView)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(20)
        }

        // 点赞数约束 - 在点赞按钮左侧
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarImageView)
            make.right.equalTo(likeButton.snp.left).offset(-4)
        }

        // 作者名称约束 - 在头像右侧，不超过点赞数
        authorNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarImageView)
            make.left.equalTo(authorAvatarImageView.snp.right).offset(6)
            make.right.lessThanOrEqualTo(likeCountLabel.snp.left).offset(-8)
        }
        // 播放浮层覆盖在图片中心
        playOverlayView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.height.equalTo(40)
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func cellTapped() {
        onTapAction?()
    }

    func configure(with model: FeedModel) {
        titleLabel.text = model.title
        authorNameLabel.text = model.authorName
        likeCountLabel.text = "\(model.likeCount)"

        // 根据图片的实际宽高比设置高度约束
        imageView.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(model.imageAspectRatio)
        }

        // 使用boundingRect手动计算标题高度并更新约束
        let titleWidth = bounds.width - 16 // 减去左右内边距
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleText = model.title as NSString
        
        let titleRect = titleText.boundingRect(
            with: CGSize(width: titleWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: titleFont],
            context: nil
        )
        
        // 限制最多2行，计算实际高度
        let lineHeight = titleFont.lineHeight
        let maxHeight = lineHeight * 2
        let calculatedHeight = min(ceil(titleRect.height), maxHeight)
        
        // 更新标题高度约束
        titleHeightConstraint?.update(offset: calculatedHeight)

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

        if let url = URL(string: model.authorAvatar) {
            authorAvatarImageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.progressiveLoad, .retryFailed]
            ) { [weak self] image, error, cacheType, url in
                if error == nil {
                    self?.authorAvatarImageView.backgroundColor = .clear
                }
            }
        }
        // 视频封面优先（没有则使用 imageURL）
        let coverURLString = model.videoCoverURL ?? model.imageURL
        if let url = URL(string: coverURLString) {
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

        // 视频时显示播放浮层
        playOverlayView.isHidden = !model.isVideo

        // 使用SDWebImage加载头像
    }


}
