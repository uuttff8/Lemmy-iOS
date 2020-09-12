//
//  WSLemmy.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 9/11/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

enum LemmyEndpoint {
    
    // User / Authentication / Admin actions
    enum Authentication {
        case login
        case register
        case getCaptcha
        
        var endpoint: String {
            switch self {
            case .login: return "Login"
            case .register: return "Register"
            case .getCaptcha: return "GetCaptcha"
            }
        }
    }
    
    enum User {
        case getUserDetails
        case saveUserSettings
        case getReplies         // Get Replies / Inbox
        case getUserMentions
        case markUserMentionAsRead
        
        case getPrivateMessage
        case createPrivateMessage
        case editPrivateMessage
        case deletePrivateMessage
        case markPrivateMessageAsRead
        case markAllAsRead
        
        case deleteAccount // Permananently deletes your posts and comments
        
        var endpoint: String {
            switch self {
            case .getUserDetails: return "GetUserDetails"
            case .saveUserSettings: return "SaveUserSettings"
            case .getReplies: return "SaveUserSettings"
            case .getUserMentions: return "GetUserMentions"
            case .markUserMentionAsRead: return "MarkUserMentionAsRead"
            case .getPrivateMessage: return "GetPrivateMessages"
            case .createPrivateMessage: return "CreatePrivateMessage"
            case .editPrivateMessage: return "EditPrivateMessage"
            case .deletePrivateMessage: return "DeletePrivateMessage"
            case .markPrivateMessageAsRead: return "MarkPrivateMessageAsRead"
            case .markAllAsRead: return "MarkAllAsRead"
            case .deleteAccount: return "DeleteAccount"
            }
        }
        
    }
    
    enum AdminActions {
        case addAdmin
        case banUser
        
        var endpoint: String {
            switch self {
            case .addAdmin: return "AddAdmin"
            case .banUser: return "BanUser"
            }
        }
    }
    
    enum Site {
        case listCategories
        case search // All, Comments, Posts, Communities, Users, Url
        case getModlog
        case createSite
        case editSite
        case getSite
        case transferSite
        case getSiteConfig
        case saveSiteConfig
        
        var endpoint: String {
            switch self {
            case .listCategories: return "ListCategories"
            case .search: return "Search"
            case .getModlog: return "GetModlog"
            case .createSite: return "CreateSite"
            case .editSite: return "EditSite"
            case .getSite: return "GetSite"
            case .transferSite: return "TransferSite"
            case .getSiteConfig: return "GetSiteConfig"
            case .saveSiteConfig: return "SaveSiteConfig"
                
            }
        }
    }
    
    enum Community {
        case getCommunity
        case createCommunity
        case listCommunities
        case banFromCommunity
        case addModToCommunity
        case editCommunity
        case deleteCommunity
        case removeCommunity
        case followCommunity
        case getFollowedCommunities
        case transferCommunities
        
        var endpoint: String {
            switch self {
            case .getCommunity: return "GetCommunity"
            case .createCommunity: return "CreateCommunity"
            case .listCommunities: return "ListCommunities"
            case .banFromCommunity: return "BanFromCommunity"
            case .addModToCommunity: return "AddModToCommunity"
            case .editCommunity: return "EditCommunity"
            case .deleteCommunity: return "DeleteCommunity"
            case .removeCommunity: return "RemoveCommunity"
            case .followCommunity: return "FollowCommunity"
            case .getFollowedCommunities: return "GetFollowedCommunities"
            case .transferCommunities: return "TransferCommunities"
            }
        }
    }
    
    enum Post {
        case createPost
        case getPost
        case getPosts
        case createPostLike
        case editPost
        case deletePost
        case removePost
        case lockPost
        case stickyPost
        case savePost
        
        var endpoint: String {
            switch self {
            case .createPost: return "CreatePost"
            case .getPost: return "GetPost"
            case .getPosts: return "GetPosts"
            case .createPostLike: return "CreatePostLike"
            case .editPost: return "EditPost"
            case .deletePost: return "DeletePost"
            case .removePost: return "RemovePost"
            case .lockPost: return "LockPost"
            case .stickyPost: return "StickyPost"
            case .savePost: return "SavePost"
            }
        }
    }
    
    enum Comment {
        case createComment
        case editComment
        case deleteComment
        case removeComment
        case markCommentAsRead
        case saveComment
        case createCommentLike // score can be 0, -1, or 1
        
        var endpoint: String {
            switch self {
            case .createComment: return "CreateComment"
            case .editComment: return "EditComment"
            case .deleteComment: return "DeleteComment"
            case .removeComment: return "RemoveComment"
            case .markCommentAsRead: return "MarkCommentAsRead"
            case .saveComment: return "SaveComment"
            case .createCommentLike: return "CreateCommentLike"
            }
        }
    }
}

class WSLemmy {
    func send<D: Codable>(on endpoint: String, data: D? = nil, completion: @escaping (String) -> Void) {
        wrapper(url: endpoint, data: data, completion: completion)
    }
    
    func wrapper<D: Codable>(url: String, data: D? = nil, completion: @escaping (String) -> Void) {
        let reqStr: String
        if let data = data {
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let orderJsonData = try! encoder.encode(data)
            let sss = String(data: orderJsonData, encoding: .utf8)!
            
            reqStr = """
            {"op": "\(url)","data": \(sss)}
            """
        } else {
            reqStr = """
            {
            "op": \(url)
            }
            """
        }
        
        print(reqStr)
        
        let wsTask = URLSessionWebSocketTask.Message.string(reqStr)
        let urlSession = URLSession(configuration: .default)
        let ws = urlSession.webSocketTask(with: URL(string: "wss://dev.lemmy.ml/api/v1/ws")!)
        ws.resume()
        
        ws.send(wsTask) { (error) in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
        
        ws.receive { (res) in
            switch res {
            case .failure(let error):
                print(error)
            case .success(let messageType):
                switch messageType {
                case .string(let outString):
                    completion(outString)
                case .data(let outData):
                    print(outData)
                @unknown default:
                    break
                }
            }
        }
    }
}


extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}