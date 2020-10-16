//
//  PostsFrontPageViewController.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 10/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class PostsFrontPageViewController: UIViewController {
    enum Section {
        case main
    }
    
    weak var coordinator: FrontPageCoordinator?
    
    let model = PostsFrontPageModel()
    
    let tableView = LemmyUITableView(style: .plain)
    private lazy var dataSource = makeDataSource()
    private var snapshot = NSDiffableDataSourceSnapshot<Section, LemmyApiStructs.PostView>()
    
    private var nonMainThread = DispatchQueue(label: "posts.nonMain")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = model
//        tableView.dataSource = model
        
        tableView.register(
            PostContentTableCell.self,
            forCellReuseIdentifier: PostContentTableCell.reuseId
        )
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        model.loadPosts()
        
        model.dataLoaded = { [self] newPosts in
            addFirstRows(with: newPosts)
        }
        
        model.newDataLoaded = { [self] newPosts in
            addRows(with: newPosts)
        }
//
//        model.newDataLoaded = { [self] (newPosts) in
//            let startIndex = model.postsDataSource.count - newPosts.count
//            let endIndex = startIndex + newPosts.count
//
//            let newIndexpaths =
//                Array(startIndex ..< endIndex)
//                .map { (index) in
//                    IndexPath(row: index, section: 0)
//                }
//
//            tableView.performBatchUpdates {
//                tableView.insertRows(at: newIndexpaths, with: .automatic)
//            }
//        }
        
        model.goToPostScreen = { [self] (post: LemmyApiStructs.PostView) in
            coordinator?.goToPostScreen(post: post)
        }
    }
    
    func addRows(with list: Array<LemmyApiStructs.PostView>, animate: Bool = true) {
        
        // Last item from 
        let lastItem = (model.postsDataSource.count - 1) - (model.currentPage * 20 - 20)
        snapshot.insertItems(list, afterItem: model.postsDataSource.last!)
        nonMainThread.async {
            self.model.postsDataSource.append(contentsOf: list)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func addFirstRows(with list: Array<LemmyApiStructs.PostView>, animate: Bool = true) {
        snapshot.appendSections([.main])
        snapshot.appendItems(list)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, LemmyApiStructs.PostView> {
        return UITableViewDiffableDataSource<Section, LemmyApiStructs.PostView>(
            tableView: tableView,
            cellProvider: { (tableView, indexPath, postView) -> UITableViewCell? in
                let cell: UITableViewCell = { [self] in
                    guard let postCell =
                            tableView.dequeueReusableCell(withIdentifier: PostContentTableCell.reuseId) as? PostContentTableCell
                    else {
                        return UITableViewCell(style: .default, reuseIdentifier: "cell")
                    }
                    postCell.postContentView.delegate = model
                    postCell.bind(with: model.postsDataSource[indexPath.row])

                    return postCell
                }()
                
                return cell
        })
    }
}
