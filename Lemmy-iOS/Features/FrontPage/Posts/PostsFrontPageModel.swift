//
//  PostsFrontPageModel.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 10/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class PostsFrontPageModel: NSObject {
    var goToPostScreen: ((LemmyApiStructs.PostView) -> ())?
    var newDataLoaded: ((Array<LemmyApiStructs.PostView>) -> Void)?
    var dataLoaded: ((Array<LemmyApiStructs.PostView>) -> Void)?
    
    private var isFetchingNewContent = false
    var currentPage = 1
    
    var postsDataSource: Array<LemmyApiStructs.PostView> = []
    
    // at init always posts
    var currentContentType: LemmyContentType = LemmyContentType.posts {
        didSet {
            print(currentContentType)
        }
    }
    
    // at init always all
    var currentFeedType: LemmyFeedType = LemmyFeedType.all {
        didSet {
            print(currentFeedType)
        }
    }
    
    func loadPosts() {
        let parameters = LemmyApiStructs.Post.GetPostsRequest(type_: self.currentFeedType,
                                                              sort: LemmySortType.active,
                                                              page: 1,
                                                              limit: 20,
                                                              communityId: nil,
                                                              communityName: nil,
                                                              auth: nil)
        
        ApiManager.shared.requestsManager.getPosts(
            parameters: parameters,
            completion: { (dec: Result<LemmyApiStructs.Post.GetPostsResponse, Error>) in
                switch dec {
                case .success(let posts):
                    self.postsDataSource = posts.posts
                    DispatchQueue.main.async {
                        self.dataLoaded?(posts.posts)
                    }
                case .failure(let error):
                    print(error)
                }
            })
    }
    
    func loadMorePosts(completion: @escaping (() -> Void)) {
        let parameters = LemmyApiStructs.Post.GetPostsRequest(type_: self.currentFeedType,
                                                              sort: LemmySortType.active,
                                                              page: currentPage,
                                                              limit: 20,
                                                              communityId: nil,
                                                              communityName: nil,
                                                              auth: nil)
        
        ApiManager.shared.requestsManager.getPosts(
            parameters: parameters,
            completion: { (dec: Result<LemmyApiStructs.Post.GetPostsResponse, Error>) in
                switch dec {
                case let .success(posts):
                    DispatchQueue.main.async {
                        self.newDataLoaded?(posts.posts)
                    }
                    completion()
                case .failure(let error):
                    print(error)
                }
            })
    }
}


extension PostsFrontPageModel: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleDidSelectForPosts(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPathRow = indexPath.row
        let bottomItems = self.postsDataSource.count - 5
        
        if indexPathRow >= bottomItems {
            guard !self.isFetchingNewContent else { return }
            
            self.isFetchingNewContent = true
            self.currentPage += 1
            self.loadMorePosts {
                self.isFetchingNewContent = false
            }
        }
    }
    
    private func handleDidSelectForPosts(indexPath: IndexPath) {
        self.goToPostScreen?(postsDataSource[indexPath.row])
    }
    
    private func handleCellForPosts(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = {
            guard let postCell =
                    tableView.dequeueReusableCell(withIdentifier: PostContentTableCell.reuseId) as? PostContentTableCell
            else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            postCell.postContentView.delegate = self
            postCell.bind(with: postsDataSource[indexPath.row])

            return postCell
        }()
        
        return cell
    }
}

extension PostsFrontPageModel: PostContentTableCellDelegate {
    func usernameTapped(in post: LemmyApiStructs.PostView) {
        print(post.creatorName)
    }
    
    func communityTapped(in post: LemmyApiStructs.PostView) {
        print(post.communityName)
    }
    
    func upvote(post: LemmyApiStructs.PostView) {
        print("upvote")
    }
    
    func downvote(post: LemmyApiStructs.PostView) {
        print("downvote")
    }
}

extension PostsFrontPageModel: FrontPageHeaderCellDelegate {
    func contentTypeChanged(to content: LemmyContentType) {
        self.currentContentType = content
//        self.loadPosts()
    }
    
    func feedTypeChanged(to feed: LemmyFeedType) {
        self.currentFeedType = feed
//        self.loadPosts()
    }
}
