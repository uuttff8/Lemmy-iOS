//
//  InstancesView.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 19.12.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

final class InstancesView: UIView {
    
    private lazy var tableView = LemmyTableView(style: .insetGrouped, separator: true).then {
        $0
    }
}

extension InstancesView: ProgrammaticallyViewProtocol {
    func setupView() {
        
    }
    
    func addSubviews() {
        
    }
    
    func makeConstraints() {
        
    }
}