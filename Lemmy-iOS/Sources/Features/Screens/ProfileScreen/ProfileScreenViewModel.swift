//
//  ProfileScreenModel.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 07.11.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import Combine

protocol ProfileScreenViewModelProtocol: AnyObject {
    var loadedProfile: ProfileScreenViewModel.ProfileData? { get }
    
    func doProfileFetch()
    func doIdentifyProfile()
    func doProfileLogout()
    func doSubmoduleControllerAppearanceUpdate(request: ProfileScreenDataFlow.SubmoduleAppearanceUpdate.Request)
    func doSubmodulesRegistration(request: ProfileScreenDataFlow.SubmoduleRegistration.Request)
    func doSubmodulesDataFilling(request: ProfileScreenDataFlow.SubmoduleDataFilling.Request)
//    func doSubmoduleDataFilling(request: ProfileScreenDataFlow.SubmoduleDataFilling.Request)
}
 
extension ProfileScreenViewModel {
    struct ProfileData: Identifiable {
        let id: Int
        let viewData: ProfileScreenHeaderView.ViewData
        let follows: [LMModels.Views.CommunityFollowerView]
        let moderates: [LMModels.Views.CommunityModeratorView]
        let comments: [LMModels.Views.CommentView]
        let posts: [LMModels.Views.PostView]
    }
}

class ProfileScreenViewModel: ProfileScreenViewModelProtocol {
    private var profileId: Int?
    private let profileUsername: String?
    
    weak var viewController: ProfileScreenViewControllerProtocol?
    
    private let userAccountService: UserAccountSerivceProtocol
    
    private var cancellable = Set<AnyCancellable>()
    
    private(set) var loadedProfile: ProfileData?
    
    // Tab index -> Submodule
    private(set) var submodules: [Int: ProfileScreenSubmoduleProtocol] = [:] {
        didSet {
            print("Submodules is changed")
        }
    }
    
    init(
        profileId: Int?,
        profileUsername: String?,
        userAccountService: UserAccountSerivceProtocol
    ) {
        self.profileId = profileId
        self.profileUsername = profileUsername
        self.userAccountService = userAccountService
    }
        
    func doProfileFetch() {
        self.viewController?.displayNotBlockingActivityIndicator(viewModel: .init(shouldDismiss: false))
        
        let parameters = LMModels.Api.User.GetUserDetails(userId: profileId,
                                                          username: profileUsername,
                                                          sort: .active,
                                                          page: 1,
                                                          limit: 50,
                                                          communityId: nil,
                                                          savedOnly: false,
                                                          auth: LemmyShareData.shared.jwtToken)
        
        ApiManager.requests.asyncGetUserDetails(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                Logger.logCombineCompletion(completion)
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                self.viewController?.displayNotBlockingActivityIndicator(viewModel: .init(shouldDismiss: true))
                                
                guard let loadedProfile = self.initializeProfileData(with: response) else {
                    Logger.commonLog.emergency("GetUserDetails Response does not have user, or it is changed!")
                    return
                }
                self.loadedProfile = loadedProfile
                          
                // if blocked user then show nothing
                if self.userIsBlocked(userId: loadedProfile.id) {
                    self.viewController?.displayProfile(viewModel: .init(state: .blockedUser))
                    return
                }
                
                self.viewController?.displayProfile(
                    viewModel: .init(state: .result(profile: loadedProfile.viewData,
                                                    posts: response.posts,
                                                    comments: response.comments,
                                                    subscribers: response.follows))
                )
            }.store(in: &cancellable)
    }
    
    func doIdentifyProfile() {
        let isCurrent = loadedProfile?.id == userAccountService.currentUser?.id
            ? true
            : false
        
        let userId = loadedProfile.require().id
        
        let isBlocked = self.userIsBlocked(userId: userId)
        
        self.viewController?.displayMoreButtonAlert(
            viewModel: .init(isCurrentProfile: isCurrent, isBlocked: isBlocked, userId: userId)
        )
    }
    
    func doProfileLogout() {
        userAccountService.userLogout()
        NotificationCenter.default.post(name: .didLogin, object: nil)
    }
    
    func doSubmoduleControllerAppearanceUpdate(request: ProfileScreenDataFlow.SubmoduleAppearanceUpdate.Request) {
        self.submodules[request.submoduleIndex]?.handleControllerAppearance()
    }
    
    func doSubmodulesRegistration(request: ProfileScreenDataFlow.SubmoduleRegistration.Request) {
        for (key, value) in request.submodules {
            self.submodules[key] = value
        }
        self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
    }
    
    private func pushCurrentCourseToSubmodules(submodules: [ProfileScreenSubmoduleProtocol]) {
        guard let profileData = loadedProfile else { return }
        
        self.submodules.forEach({ $1.updateFirstData(profile: profileData,
                                                     posts: profileData.posts,
                                                     comments: profileData.comments,
                                                     subscribers: profileData.follows) })
    }
    
    func doSubmodulesDataFilling(request: ProfileScreenDataFlow.SubmoduleDataFilling.Request) {
        guard let profile = loadedProfile else {
            Logger.commonLog.error("Profile is not initialized")
            return
        }
        
        self.submodules = request.submodules
        request.submodules.forEach {
            $1.updateFirstData(
                profile: profile,
                posts: request.posts,
                comments: request.comments,
                subscribers: request.subscribers
            )
        }
    }
    
    private func initializeProfileData(with response: LMModels.Api.User.GetUserDetailsResponse) -> ProfileData? {
        if let userView = response.userView {
            return ProfileData(
                id: userView.user.id,
                viewData: .init(name: userView.user.name,
                                avatarUrl: userView.user.avatar,
                                bannerUrl: userView.user.banner,
                                numberOfComments: userView.counts.commentCount,
                                numberOfPosts: userView.counts.postCount,
                                published: userView.user.published.toLocalTime()),
                follows: response.follows,
                moderates: response.moderates,
                comments: response.comments,
                posts: response.posts
            )
        } else if let userView = response.userViewDangerous {
            return ProfileData(
                id: userView.user.id,
                viewData: .init(name: userView.user.name,
                                avatarUrl: userView.user.avatar,
                                bannerUrl: userView.user.banner,
                                numberOfComments: userView.counts.commentCount,
                                numberOfPosts: userView.counts.postCount,
                                published: userView.user.published.toLocalTime()),
                follows: response.follows,
                moderates: response.moderates,
                comments: response.comments,
                posts: response.posts
            )
        }
        
        return nil
    }
    
    private func userIsBlocked(userId: Int) -> Bool {
        if LemmyShareData.shared.blockedUsersId.contains(userId) {
            return true
        }
        
        return false
    }
}

enum ProfileScreenDataFlow {
    enum Tab: Int, CaseIterable {
        case posts
        case comments
        case about
        
        var title: String {
            switch self {
            case .about: return "About"
            case .comments: return "Comments"
            case .posts: return "Posts"
            }
        }
    }
    
    enum ProfileLoad {
        struct Request { }
        
        struct ViewModel {
            var state: ViewControllerState
        }
    }
    
    enum IdentifyProfile {
        struct Request { }
        
        struct ViewModel {
            let isCurrentProfile: Bool
            let isBlocked: Bool
            let userId: Int
        }
    }
    
    enum BlockedUser {
        struct ViewModel { }
    }
    
    enum SubmoduleDataFilling {
        struct Request {
            let submodules: [Int: ProfileScreenSubmoduleProtocol]
            let posts: [LMModels.Views.PostView]
            let comments: [LMModels.Views.CommentView]
            let subscribers: [LMModels.Views.CommunityFollowerView]
        }
    }
    
    /// Handle submodule controller appearance
    enum SubmoduleAppearanceUpdate {
        struct Request {
            let submoduleIndex: Int
        }
    }
    
    /// Register submodules
    enum SubmoduleRegistration {
        struct Request {
            var submodules: [Int: ProfileScreenSubmoduleProtocol]
        }
    }
    
    enum ShowingActivityIndicator {
        struct ViewModel {
            let shouldDismiss: Bool
        }
    }
    
    enum ViewControllerState {
        case loading
        case result(profile: ProfileScreenHeaderView.ViewData,
                    posts: [LMModels.Views.PostView],
                    comments: [LMModels.Views.CommentView],
                    subscribers: [LMModels.Views.CommunityFollowerView])
        case blockedUser
    }
}
