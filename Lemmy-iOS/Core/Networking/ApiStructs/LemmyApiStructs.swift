//
//  LemmyApiStructs.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 9/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit


enum LemmySortType: String, Codable, CaseIterable {
    case active = "Active"
    case hot = "Hot"
    case new = "New"
    
    case topDay = "TopDay"
    case week = "Week"
    case month = "Month"
    case all = "All"
    
    // used in listCommunities
    // case topAll = "TopAll"
    // LemmySortType(rawValue: "TopAll")
    
    var label: String {
        switch self {
        case .active: return "Active"
        case .hot: return "Hot"
        case .new: return "New"
        case .topDay: return "Top day"
        case .week: return "Week"
        case .month: return "Month"
        case .all: return "All"
        //        case .topAll: return "TopAll"
        }
    }
    
    var index: Int {
        switch self {
        case .active: return 0
        case .hot: return 1
        case .new: return 2
        case .topDay: return 3
        case .week: return 4
        case .month: return 5
        case .all: return 6
        //        case .topAll: return 7
        }
    }
}

enum LemmyContentType: String, Codable, CaseIterable {
    case posts = "Posts"
    case comments = "Comments"
    
    var label: String {
        switch self {
        case .posts: return "Posts"
        case .comments: return "Comments"
        }
    }
    
    var index: Int {
        switch self {
        case .posts: return 0
        case .comments: return 1
        }
    }
}

enum LemmyFeedType: String, Codable, CaseIterable {
    case subscribed = "Subscribed"
    case all = "All"
    
    var label: String {
        switch self {
        case .all: return "All"
        case .subscribed: return "Subscribed"
        }
    }
    
    var index: Int {
        switch self {
        case .subscribed: return 0
        case .all: return 1
        }
    }
}

enum LemmyApiStructs {
    enum PostType {
        case link, pictureAndText, plainText
    }
    
    // MARK: - Error -
    struct ErrorResponse: Codable, Equatable {
        let error: String
    }
    
    // MARK: - PostView -
    struct PostView: Codable, Equatable {
        let id: Int
        let name: String
        let url: String?
        let body: String?
        let communityId: Int
        let removed: Bool
        let locked: Bool
        let published: String // Timestamp
        let updated: String? // Timestamp
        let deleted: Bool
        let nsfw: Bool
        let stickied: Bool
        let embedTitle: String?
        let embedDescription: String?
        let embedHtml: String?
        let thumbnailUrl: String?
        let apId: String
        let local: Bool
        let creatorActorId: String
        let creatorLocal: Bool
        let creatorName: String
        let creatorPreferredUsername: String?
        let creatorPublished: String // Timestamp
        let creatorAvatar: String?
        let banned: Bool
        let bannedFromCommunity: Bool
        let communityActorId: String
        let communityLocal: Bool
        let communityName: String
        let communityIcon: String?
        let communityRemoved: Bool
        let communityDeleted: Bool
        let communityNsfw: Bool
        let numberOfComments: Int
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let hotRank: Int
        let hotRankActive: Int
        let newestActivityTime: String // Timestamp
        let userId: Int?
        let myVote: Int?
        let subscribed: Bool?
        let read: Bool?
        let saved: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id, name, url, body
            case communityId = "community_id"
            case removed, locked, published, updated, deleted, nsfw, stickied
            case embedTitle = "embed_title"
            case embedDescription = "embed_description"
            case embedHtml = "embed_html"
            case thumbnailUrl = "thumbnail_url"
            case apId = "ap_id", local
            case creatorActorId = "creator_actor_id"
            case creatorLocal = "creator_local"
            case creatorName = "creator_name"
            case creatorPreferredUsername = "creator_preferred_username"
            case creatorPublished = "creator_published"
            case creatorAvatar = "creator_avatar", banned
            case bannedFromCommunity = "banned_from_community"
            case communityActorId = "community_actor_id"
            case communityLocal = "community_local"
            case communityName = "community_name"
            case communityIcon = "community_icon"
            case communityRemoved = "community_removed"
            case communityDeleted = "community_deleted"
            case communityNsfw = "community_nsfw"
            case numberOfComments = "number_of_comments"
            case score, upvotes, downvotes
            case hotRank = "hot_rank"
            case hotRankActive = "hot_rank_active"
            case newestActivityTime = "newest_activity_time"
            case userId = "user_id"
            case myVote = "my_vote", subscribed, read, saved
        }
        
        var postType: PostType {
            if self.url != nil {
                return PostType.link
            }
            
            if ((self.url?.contains("https://dev.lemmy.ml/pictrs/image")) != nil) {
                return PostType.pictureAndText
            }
            
            return PostType.plainText
        }
    }
    
    // MARK: - CommentView -
    struct CommentView: Codable, Equatable {
        let id: Int
        let creatorId: Int
        let postId: Int
        let postName: String
        let parentId: Int?
        let content: String
        let removed: Bool
        let published: String // Timestamp
        let updated: String? // Timestamp
        let deleted: Bool
        let apId: String
        let local: Bool
        let communityId: Int
        let communityActorId: String
        let communityLocal: Bool
        let communityName: String
        let communityIcon: String?
        let banned: Bool
        let bannedFromCommunity: Bool
        let creatorActorId: String
        let creatorLocal: Bool
        let creatorName: String
        let creatorPreferredUsername: String?
        let creatorPublished: String // Timestamp
        let creatorAvatar: String?
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let hotRank: Int
        let hotRankActive: Int
        let userId: Int?
        let myVote: Int?
        let subscribed: Bool?
        let read: Bool
        let saved: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id, content
            case creatorId = "creator_id"
            case postId = "post_id"
            case postName = "post_name"
            case parentId = "parent_id"
            case communityId = "community_id"
            case removed, published, updated, deleted
            case apId = "ap_id", local
            case creatorActorId = "creator_actor_id"
            case creatorLocal = "creator_local"
            case creatorName = "creator_name"
            case creatorPreferredUsername = "creator_preferred_username"
            case creatorPublished = "creator_published"
            case creatorAvatar = "creator_avatar", banned
            case bannedFromCommunity = "banned_from_community"
            case communityActorId = "community_actor_id"
            case communityLocal = "community_local"
            case communityName = "community_name"
            case communityIcon = "community_icon"
            case score, upvotes, downvotes
            case hotRank = "hot_rank"
            case hotRankActive = "hot_rank_active"
            case userId = "user_id"
            case myVote = "my_vote"
            case subscribed, read, saved
        }
    }
    
    // MARK: - CommunityView -
    struct CommunityView: Codable, Equatable {
        let id: Int
        let name, title: String
        let icon, banner, description: String?
        let categoryId, creatorId: Int
        let removed: Bool
        let published: String // Timestamp
        let updated: String? // Timestamp
        let deleted, nsfw, local: Bool
        let actorId: String
        let lastRefreshedAt: String // Timestamp
        let creatorActorId: String
        let creatorLocal: Bool
        let creatorName: String
        let creatorPreferredUsername: String?
        let creatorAvatar: String?
        let categoryName: String
        let numberOfSubscribers: Int
        let numberOfPosts: Int
        let numberOfComments: Int
        let hotRank: Int
        let userId: Int?
        let subscribed: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id, name, title, icon, banner, description
            case categoryId = "category_id"
            case creatorId = "creator_id"
            case removed, published, updated, deleted, nsfw, local
            case actorId = "actor_id"
            case lastRefreshedAt = "last_refreshed_at"
            case creatorActorId = "creator_actor_id"
            case creatorLocal = "creator_local"
            case creatorName = "creator_name"
            case creatorPreferredUsername = "creator_preferred_username"
            case creatorAvatar = "creator_avatar"
            case categoryName = "category_name"
            case numberOfSubscribers = "number_of_subscribers"
            case numberOfPosts = "number_of_posts"
            case numberOfComments = "number_of_comments"
            case hotRank = "hot_rank"
            case userId = "user_id"
            case subscribed
        }
    }
    
    // MARK: - CommunityModeratorView -
    struct CommunityModeratorView: Codable, Equatable {
        let id: Int
        let communityId: Int
        let userId: Int
        let published: String // Timestamp
        let userActorId: String
        let userLocal: Bool
        let userName: String
        let userPreferredUsermame: String?
        let avatar: String?
        let communityActorId: String
        let communityLocal: Bool
        let communityName: String
        let communityIcon: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case communityId = "community_id"
            case userId = "user_id"
            case published
            case userActorId = "user_actor_id"
            case userLocal = "user_local"
            case userName = "user_name"
            case userPreferredUsermame = "user_preferred_username"
            case avatar = "avatar"
            case communityActorId = "community_actor_id"
            case communityLocal = "community_local"
            case communityName = "community_name"
            case communityIcon = "community_icon"
        }
    }
    
    // MARK: - UserView -
    struct UserView: Codable, Equatable {
        let id: Int
        let actorId: String
        let name: String
        let preferredUsername: String?
        let avatar: String?
        let banner: String?
        let matrixUserId: String?
        let bio: String?
        let local: Bool
        let admin: Bool
        let banned: Bool
        let published: String
        let numberOfPosts: Int
        let postScore: Int
        let numberOfComments: Int
        let commentScore: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case actorId = "actor_id"
            case name
            case preferredUsername = "preferred_username"
            case avatar, banner
            case matrixUserId = "matrix_user_id"
            case bio, local, admin, banned, published
            case numberOfPosts = "number_of_posts"
            case postScore = "post_score"
            case numberOfComments = "number_of_comments"
            case commentScore = "comment_score"
        }
    }
    
    // MARK: - MyUser -
    // inner struct in lemmy backend called User_, that is why its not a *View
    struct MyUser: Codable, Equatable {
        let id: Int
        let name: String
        let preferredUsername: String?
        let passwordEncrypted: String
        let email: String
        let avatar: String?
        let admin: Bool
        let banned: Bool
        let published: String // Timestamp
        let updated: String? // Timestamp
        let showNsfw: Bool
        let theme: String
        let defaultSortType: Int
        let defaultListingType: Int
        let lang: String
        let showAvatars: Bool
        let sendNotificationsToEmail: Bool
        let matrixUserId: String?
        let actorId: String
        let bio: String?
        let local: Bool
        let privateKey: String?
        let publicKey: String?
        let lastRefreshedAt: String // Timestamp
        let banner: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case preferredUsername = "preferred_username"
            case passwordEncrypted = "password_encrypted"
            case email, avatar, admin, banned
            case published, updated
            case showNsfw = "show_nsfw"
            case theme
            case defaultSortType = "default_sort_type"
            case defaultListingType = "default_listing_type"
            case lang
            case showAvatars = "show_avatars"
            case sendNotificationsToEmail = "send_notifications_to_email"
            case matrixUserId = "matrix_user_id"
            case actorId = "actor_id"
            case bio, local
            case privateKey = "private_key"
            case publicKey = "public_key"
            case lastRefreshedAt = "last_refreshed_at"
            case banner
        }
    }
    
    
    // MARK: - CommunityFollowerView -
    struct CommunityFollowerView: Codable, Equatable {
        let id: Int
        let communityId: Int
        let userId: Int
        let published: String
        let userActorId: String
        let userLocal: Bool
        let userName: String
        let userPreferredUsername: String?
        let avatar: String?
        let communityActorId: String
        let communityLocal: Bool
        let communityName: String
        let communityIcon: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case communityId = "community_id"
            case userId = "user_id"
            case published
            case userActorId = "user_actor_id"
            case userLocal = "user_local"
            case userName = "user_name"
            case userPreferredUsername = "user_preferred_username"
            case avatar
            case communityActorId = "community_actor_id"
            case communityLocal = "community_local"
            case communityName = "community_name"
            case communityIcon = "community_icon"
        }
    }
    
    // MARK: - ReplyView -
    struct ReplyView: Codable, Equatable {
        let id: Int
        let creatorId: Int
        let postId: Int
        let postName: String
        let parentId: Int?
        let content: String
        let removed: Bool
        let read: Bool
        let published: String // Timestamp
        let updated: String? // Timestamp
        let deleted: Bool
        let apId: String
        let local: Bool
        let communityId: Int
        let communityActorId: String
        let communityLocal: Bool
        let communityName: String
        let communityIcon: String?
        let banned: Bool
        let bannedFromCommunity: Bool
        let creatorActorId: String
        let creatorLocal: Bool
        let creatorName: String
        let creatorPreferredUsername: String?
        let creatorAvatar: String?
        let creatorPublished: String // Timestamp
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let hotRank: Int
        let hotRankActive: Int
        let userId: Int?
        let myVote: Int?
        let subscribed: Bool?
        let saved: Bool?
        let recipientId: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case creatorId = "creator_id"
            case postId = "post_id"
            case postName = "post_name"
            case parentId = "parent_id"
            case content, removed, read
            case published, updated, deleted
            case apId = "ap_id"
            case local
            case communityId = "community_id"
            case communityActorId = "community_actor_id"
            case communityLocal = "community_local"
            case communityName = "community_name"
            case communityIcon = "communityIcon"
            case banned
            case bannedFromCommunity = "banned_from_community"
            case creatorActorId = "creator_actor_id"
            case creatorLocal = "creator_local"
            case creatorName = "creator_name"
            case creatorPreferredUsername = "creator_preferred_username"
            case creatorAvatar = "creator_avatar"
            case creatorPublished = "creator_published"
            case score, upvotes, downvotes
            case hotRank = "hot_rank"
            case hotRankActive = "hot_rank_active"
            case userId = "user_id"
            case myVote = "my_vote"
            case subscribed, saved
            case recipientId = "recipient_id"
        }
    }
    
    // MARK: - UserMentionView -
    struct UserMentionView: Codable, Equatable {
        let id: Int
        let userMentionId: Int
        let creatorId: Int
        let creatorActorId: String
        let creatorLocal: Bool
        let postId: Int
        let postName: String
        let parentId: Int?
        let content: String
        let removed: Bool
        let read: Bool
        let published: String // Timestamp
        let updated: String? // Timestamp
        let deleted: Bool
        let communityId: Int
        let communityActorId: String
        let communityLocal: Bool
        let communityName: String
        let communityIcon: String?
        let banned: Bool
        let bannedFromCommunity: Bool
        let creatorName: String
        let creatorPreferredUsername: String
        let creatorAvatar: String?
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let hotRank: Int
        let hotRankActive: Int
        let userId: Int?
        let myVote: Int?
        let saved: Bool?
        let recipientId: Int
        let recipientActorId: String
        let recipientLocal: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case userMentionId = "user_mention_id"
            case creatorId = "creator_id"
            case creatorActorId = "creator_actor_id"
            case creatorLocal = "creator_local"
            case postId = "post_id"
            case postName = "post_name"
            case parentId = "parent_id"
            case content, removed, read, published
            case updated, deleted
            case communityId = "community_id"
            case communityActorId = "community_actor_id"
            case communityLocal = "community_local"
            case communityName = "community_name"
            case communityIcon = "community_icon"
            case banned
            case bannedFromCommunity = "banned_from_community"
            case creatorName = "creator_name"
            case creatorPreferredUsername = "creator_preferred_username"
            case creatorAvatar = "creator_avatar"
            case score, upvotes, downvotes
            case hotRank = "hot_rank"
            case hotRankActive = "hot_rank_active"
            case userId = "user_id"
            case myVote = "my_vote"
            case saved
            case recipientId = "recipient_id"
            case recipientActorId = "recipient_actor_id"
            case recipientLocal = "recipient_local"
        }
    }
    
    // MARK: - SiteView -
    struct SiteView: Codable, Equatable {
        let id: Int
        let name: String
        let description: String?
        let creatorId: Int
        let published: String // Timestamp
        let updated: String? // Timestamp
        let enableDownvotes: Bool
        let openRegistration: Bool
        let enableNsfw: Bool
        let icon: String?
        let banner: String?
        let creatorName: String
        let creatorPreferredUsername: String?
        let creatorAvatar: String?
        let numberOfUsers: Int
        let numberOfPosts: Int
        let numberOfComments: Int
        let numberOfCommunities: Int
        
        enum CodingKeys: String, CodingKey {
            case id, name, description
            case creatorId = "creator_id"
            case published, updated
            case enableDownvotes = "enable_downvotes"
            case openRegistration = "open_registration"
            case enableNsfw = "enable_nsfw"
            case icon, banner
            case creatorName = "creator_name"
            case creatorPreferredUsername = "creator_preferred_username"
            case creatorAvatar = "creator_avatar"
            case numberOfUsers = "number_of_users"
            case numberOfPosts = "number_of_posts"
            case numberOfComments = "number_of_comments"
            case numberOfCommunities = "number_of_communities"
        }
    }
}