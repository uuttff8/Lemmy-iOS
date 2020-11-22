//
//  CommunityScreen.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 01.11.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import Combine

protocol CommunityScreenViewControllerProtocol: AnyObject {
    func displayCommunityHeader(viewModel: CommunityScreen.CommunityHeaderLoad.ViewModel)
    func displayPosts(viewModel: CommunityScreen.CommunityPostsLoad.ViewModel)
    func displayNextPosts(viewModel: CommunityScreen.NextCommunityPostsLoad.ViewModel)
}

class CommunityScreenViewController: UIViewController {
    private let viewModel: CommunityScreenViewModelProtocol
    private lazy var tableDataSource = CommunityScreenTableDataSource().then {
        $0.delegate = self
    }

    lazy var communityView = self.view as! CommunityScreenViewController.View
    
    private var canTriggerPagination = true
    private var state: CommunityScreen.ViewControllerState
    
    init(
        viewModel: CommunityScreenViewModelProtocol,
        state: CommunityScreen.ViewControllerState = .loading
    ) {
        self.viewModel = viewModel
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = CommunityScreenViewController.View(tableViewDelegate: tableDataSource)
        view.delegate = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.doCommunityFetch()
        viewModel.doPostsFetch(request: .init(contentType: communityView.contentType))
        self.updateState(newState: state)
    }
    
    private func updateState(newState: CommunityScreen.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.communityView.showLoadingView()
            return
        }

        if case .loading = self.state {
            self.communityView.hideLoadingView()
        }

        if case .result = newState {
            self.communityView.updateTableViewData(dataSource: self.tableDataSource)
        }
    }
    
    private func updatePagination(hasNextPage: Bool, hasError: Bool) {
        self.canTriggerPagination = hasNextPage
    }
}

extension CommunityScreenViewController: CommunityScreenViewControllerProtocol {
    func displayCommunityHeader(viewModel: CommunityScreen.CommunityHeaderLoad.ViewModel) {
        self.communityView.communityHeaderViewData = viewModel.data.community
        self.title = viewModel.data.community.name
    }
    
    func displayPosts(viewModel: CommunityScreen.CommunityPostsLoad.ViewModel) {
        guard case let .result(data) = viewModel.state else { return }
        self.tableDataSource.viewModels = data
        self.updateState(newState: viewModel.state)
    }
    
    func displayNextPosts(viewModel: CommunityScreen.NextCommunityPostsLoad.ViewModel) {
        switch viewModel.state {
        case .result(let posts):
            self.tableDataSource.viewModels.append(contentsOf: posts)
            self.communityView.appendNew(data: posts)
            
            if posts.isEmpty {
                self.updatePagination(hasNextPage: false, hasError: false)
            } else {
                self.updatePagination(hasNextPage: true, hasError: false)
            }
        case .error:
            break
        }
    }
}

extension CommunityScreenViewController: CommunityScreenViewDelegate {
    func communityViewDidPickerTapped(_ communityView: View, toVc: UIViewController) {
        self.present(toVc, animated: true)
    }
    
    func communityViewDidReadMoreTapped(_ communityView: View, toVc: MarkdownParsedViewController) {
        self.present(toVc, animated: true)
    }
}

extension CommunityScreenViewController: CommunityScreenTableDataSourceDelegate {
    func tableDidRequestPagination(_ tableDataSource: CommunityScreenTableDataSource) {
        guard self.canTriggerPagination else { return }
        
        self.canTriggerPagination = false
        self.viewModel.doNextPostsFetch(request: .init(contentType: communityView.contentType))
    }
    
    func tableDidSelect(post: LemmyModel.PostView) {
        fatalError("handle it with coordinators \(post)")
    }
}