//
//  SearchResultsTableDataSource.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 03.12.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

protocol SearchResultsTableDataSourceDelegate: AnyObject {
    func tableDidRequestPagination(_ tableDataSource: SearchResultsTableDataSource)
    func postDidSelect(post: LemmyModel.PostView)
    // other functions
}

final class SearchResultsTableDataSource: NSObject {
    var viewModels: SearchResults.Results
    
    let delegateImpl: SearchResultsViewController
    
    init(viewModels: SearchResults.Results = .posts([]), delegateImpl: SearchResultsViewController) {
        self.viewModels = viewModels
        self.delegateImpl = delegateImpl
        super.init()
    }
    
    func appendNew(objects: [AnyObject] = []) -> [IndexPath] {
        let startIndex = countViewModels() - objects.count
        let endIndex = startIndex + objects.count
        
        let newIndexPaths = Array(startIndex ..< endIndex)
            .map { IndexPath(row: $0, section: 0) }
        
        return newIndexPaths
    }
    
    private func countViewModels() -> Int {
        switch viewModels {
        case let .comments(data): return data.count
        case let .posts(data): return data.count
        case let .communities(data): return data.count
        case let .users(data): return data.count
        }
    }
    
    private func createPostCell(
        post: LemmyModel.PostView,
        tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: PostContentTableCell = tableView.cell(forRowAt: indexPath)
        cell.bind(with: post, config: .default)
        return cell
    }
    
    private func createCommentCell(
        comment: LemmyModel.CommentView,
        tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: CommentContentTableCell = tableView.cell(forRowAt: indexPath)
        cell.bind(with: comment, level: 0)
        return cell
    }
    
    private func createCommunityCell(
        community: LemmyModel.CommunityView,
        tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = CommunityPreviewTableCell(community: community)
        return cell
    }
}

extension SearchResultsTableDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.countViewModels()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch viewModels {
        case let .comments(data):
            return createCommentCell(comment: data[indexPath.row], tableView: tableView, indexPath: indexPath)
        case let .posts(data):
            return createPostCell(post: data[indexPath.row], tableView: tableView, indexPath: indexPath)
        case let .communities(data):
            return createCommunityCell(community: data[indexPath.row], tableView: tableView, indexPath: indexPath)
        case .users(_):
            // todo: implement users cell
            return UITableViewCell()
        }
    }
}

extension SearchResultsTableDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}