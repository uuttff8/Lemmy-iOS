//
//  AccountsAssembly.swift
//  Lemmy-iOS
//
//  Created by Komolbek Ibragimov on 24/12/2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

final class AccountsAssembly: Assembly {
    
    func makeModule() -> AccountsViewController {
        let viewModel = AccountsViewModel()
        let vc = AccountsViewController(viewModel: viewModel)
        return vc
    }
}
