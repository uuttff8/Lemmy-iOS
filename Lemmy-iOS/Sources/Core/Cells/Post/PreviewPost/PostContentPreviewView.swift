//
//  PostContentPreviewView.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 19.12.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import DateToolsSwift

class PostContentPreviewView: UIView {
    
    weak var delegate: PostContentPreviewTableCellDelegate?    
    
    private let paddingView = UIView()
    private let headerView = PostContentHeaderView()
    private let centerView = PostContentCenterView()
    private let footerView = PostContentFooterView()
    private let separatorView = UIView.Configutations.separatorView
    
    init() {
        super.init(frame: .zero)
        setupView()
        addSubviews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(with post: LMModels.Views.PostView, config: PostContentType) {
        setupTargets(with: post)
        
        headerView.bind(
            config: config,
            with: .init(
                avatarImageUrl: post.creator.avatar,
                username: post.creator.name,
                community: post.community.name,
                published: post.post.published.toLocalTime().shortTimeAgoSinceNow,
                urlDomain: post.getUrlDomain()
            )
        )
        
        centerView.bind(
            config: config,
            with: .init(
                imageUrl: post.post.thumbnailUrl,
                title: post.post.name,
                subtitle: post.post.body
            )
        )
        
        footerView.bind(
            with: .init(
                score: post.counts.score,
                myVote: post.myVote,
                numberOfComments: post.counts.comments,
                voteType: post.getVoteType()
            )
        )
        
    }
    
    func updateForCreatePostLike(post: LMModels.Views.PostView) {
        footerView.bind(
            with: .init(
                score: post.counts.score,
                myVote: post.myVote,
                numberOfComments: post.counts.comments,
                voteType: post.getVoteType()
            )
        )
    }
    
    private func setupTargets(with post: LMModels.Views.PostView) {
        headerView.communityButtonTap = { [weak self] in
            let mention = LemmyCommunityMention(name: post.community.name, id: post.community.id)
            self?.delegate?.communityTapped(with: mention)
        }
        
        headerView.usernameButtonTap = { [weak self] in
            let mention = LemmyUserMention(string: post.creator.name, id: post.creator.id)
            self?.delegate?.usernameTapped(with: mention)
        }

        headerView.showMoreButtonTap = { [weak self] in
            self?.delegate?.showMore(in: post)
        }
        
        centerView.addTap {
            self.delegate?.postCellDidSelected(postId: post.id)
        }
        
        centerView.onUserMentionTap = { [weak self] mention in
            self?.delegate?.usernameTapped(with: mention)
        }
        
        centerView.onCommunityMentionTap = { [weak self] mention in
            self?.delegate?.communityTapped(with: mention)
        }
        
        footerView.downvoteButtonTap = { [weak self] (scoreView, button, voteType) in
            self?.delegate?.voteContent(scoreView: scoreView, voteButton: button, newVote: voteType, post: post)
        }
        
        footerView.upvoteButtonTap = { [weak self] (scoreView, button, voteType) in
            self?.delegate?.voteContent(scoreView: scoreView, voteButton: button, newVote: voteType, post: post)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        separatorView.backgroundColor = Config.Color.separator
    }
    
    func prepareForReuse() {
        centerView.prepareForReuse()
        headerView.prepareForReuse()
    }    
}

extension PostContentPreviewView: ProgrammaticallyViewProtocol {
    func setupView() {
        
    }
    
    func addSubviews() {
        // padding and separator
        self.addSubview(paddingView)
        self.addSubview(separatorView)
        
        paddingView.addSubview(headerView)
        paddingView.addSubview(centerView)
        paddingView.addSubview(footerView)
    }
    
    func makeConstraints() {
        paddingView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5) // SELF SIZE TOP HERE
            make.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(10)
        }
                
        headerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
                
        centerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalTo(headerView)
        }
                
        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(centerView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(headerView)
            make.bottom.equalToSuperview() // SELF SIZE BOTTOM HERE
        }
    }
}
