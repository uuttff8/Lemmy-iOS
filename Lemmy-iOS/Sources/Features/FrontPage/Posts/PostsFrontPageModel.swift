//
//  PostsFrontPageModel.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 10/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import Combine

class PostsFrontPageModel: NSObject {
    var goToPostScreen: ((LemmyModel.PostView) -> Void)?
    var goToCommunityScreen: ((_ fromPost: LemmyModel.PostView) -> Void)?
    var goToProfileScreen: ((_ username: String) -> Void)?
    var onLinkTap: ((URL) -> Void)?
    var newDataLoaded: (([LemmyModel.PostView]) -> Void)?
    var dataLoaded: (([LemmyModel.PostView]) -> Void)?
    
    private let upvoteDownvoteService = UpvoteDownvoteService(userAccountService: UserAccountService())
    
    private var cancellable = Set<AnyCancellable>()
    
    var isFetchingNewContent = false
    var currentPage = 1
    
    var postsDataSource: [LemmyModel.PostView] = []
    
    // at init always posts
    var currentContentType: LemmyContentType = LemmyContentType.posts {
        didSet {
            print(currentContentType)
        }
    }
    
    // at init always all
    var currentFeedType: LemmyPostListingType = LemmyPostListingType.all {
        didSet {
            self.currentPage = 1
            print(currentFeedType)
        }
    }
    
    var currentSortType: LemmySortType = LemmySortType.active {
        didSet {
            self.currentPage = 1
        }
    }
    
    func loadPosts() {
        let parameters = LemmyModel.Post.GetPostsRequest(type: self.currentFeedType,
                                                         sort: currentSortType,
                                                         page: 1,
                                                         limit: 50,
                                                         communityId: nil,
                                                         communityName: nil,
                                                         auth: LemmyShareData.shared.jwtToken)
        
        ApiManager.shared.requestsManager.asyncGetPosts(parameters: parameters)
            .receive(on: RunLoop.main)
            .sink { (error) in
                print(error)
            } receiveValue: { (response) in
                self.postsDataSource = response.posts
                self.dataLoaded?(response.posts)
            }.store(in: &cancellable)
    }
    
    func loadMorePosts(completion: @escaping (() -> Void)) {
        let parameters = LemmyModel.Post.GetPostsRequest(type: self.currentFeedType,
                                                         sort: currentSortType,
                                                         page: currentPage,
                                                         limit: 50,
                                                         communityId: nil,
                                                         communityName: nil,
                                                         auth: LemmyShareData.shared.jwtToken)
        
        ApiManager.shared.requestsManager.getPosts(
            parameters: parameters,
            completion: { (dec: Result<LemmyModel.Post.GetPostsResponse, LemmyGenericError>) in
                switch dec {
                case let .success(posts):
                    self.newDataLoaded?(posts.posts)
                    completion()
                case .failure(let error):
                    print(error)
                }
            })
    }
    
    private func saveNewPost(_ post: LemmyModel.PostView) {
        
        if let index = postsDataSource.firstIndex(where: { $0.id == post.id }) {
            postsDataSource[index] = post
        }
        
    }
        
}

extension PostsFrontPageModel: PostContentTableCellDelegate {
    func upvote(voteButton: VoteButton, newVote: LemmyVoteType, post: LemmyModel.PostView) {
        vote(for: newVote, post: post)
    }
    
    func downvote(voteButton: VoteButton, newVote: LemmyVoteType, post: LemmyModel.PostView) {
        vote(for: newVote, post: post)
    }
    
    func onLinkTap(in post: LemmyModel.PostView, url: URL) {
        self.onLinkTap?(url)
    }
    
    func usernameTapped(in post: LemmyModel.PostView) {
        goToProfileScreen?(post.creatorName)
    }
    
    func communityTapped(in post: LemmyModel.PostView) {        
        goToCommunityScreen?(post)
    }
    
    private func vote(for newVote: LemmyVoteType, post: LemmyModel.PostView) {
        self.upvoteDownvoteService.createPostLike(vote: newVote, post: post)
            .receive(on: RunLoop.main)
            .sink { (completion) in
                print(completion)
            } receiveValue: { (post) in
                self.saveNewPost(post)
            }.store(in: &cancellable)
    }
}

extension PostsFrontPageModel: FrontPageHeaderCellDelegate {
    func contentTypeChanged(to content: LemmyContentType) {
        self.currentContentType = content
        //        self.loadPosts()
    }
    
    func feedTypeChanged(to feed: LemmyPostListingType) {
        self.currentFeedType = feed
        //        self.loadPosts()
    }
}