//
//  InstancesAssembly.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 19.12.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class InstancesAssembly: Assembly {
    func makeModule() -> InstancesViewController {
        return InstancesViewController()
    }
}