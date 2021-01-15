//
//  PostRequests.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 9/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Combine

extension RequestsManager {
    func asyncGetPost(
        parameters: LMModels.Api.Post.GetPost
    ) -> AnyPublisher<LMModels.Api.Post.GetPostResponse, LemmyGenericError> {
        
        asyncRequestDecodable(path: WSEndpoint.Post.getPost.endpoint,
                              parameters: parameters)
    }
    
    func asyncCreatePost(
        parameters: LemmyModel.Post.CreatePostRequest
    ) -> AnyPublisher<LemmyModel.Post.CreatePostResponse, LemmyGenericError> {
        asyncRequestDecodable(path: WSEndpoint.Post.createPost.endpoint, parameters: parameters)
    }
    
    func asyncGetPosts(
        parameters: LemmyModel.Post.GetPostsRequest
    ) -> AnyPublisher<LemmyModel.Post.GetPostsResponse, LemmyGenericError> {
        
        return asyncRequestDecodable(path: WSEndpoint.Post.getPosts.endpoint, parameters: parameters)
    }
    
    func asyncCreatePostLike(
        parameters: LemmyModel.Post.CreatePostLikeRequest
    ) -> AnyPublisher<LemmyModel.Post.CreatePostLikeResponse, LemmyGenericError> {
        
        asyncRequestDecodable(path: WSEndpoint.Post.createPostLike.endpoint, parameters: parameters)
    }
    
    func asyncCreatePostReport(
        parameters: LemmyModel.Post.CreatePostReportRequest
    ) -> AnyPublisher<LemmyModel.Post.CreatePostReportResponse, LemmyGenericError> {
        asyncRequestDecodable(path: WSEndpoint.Post.createPostReport.endpoint, parameters: parameters)
    }
    
    func asyncResolvePostReport(
        parameters: LemmyModel.Post.ResolvePostReportRequest
    ) -> AnyPublisher<LemmyModel.Post.ResolvePostReportResponse, LemmyGenericError> {
        asyncRequestDecodable(path: WSEndpoint.Post.resolvePostReport.endpoint, parameters: parameters)
    }
    
    func asyncListPostReportsRequest(
        parameters: LemmyModel.Post.ListPostReportsRequest
    ) -> AnyPublisher<LemmyModel.Post.ListPostReportsResponse, LemmyGenericError> {
        asyncRequestDecodable(path: WSEndpoint.Post.listPostReports.endpoint, parameters: parameters)
    }
}
