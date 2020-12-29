//
//  AddAccountsAssebly.swift
//  Lemmy-iOS
//
//  Created by Komolbek Ibragimov on 25/12/2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

enum LemmyAuthMethod {
    case auth // auth mean Authentication
    case register
}

final class AddAccountsAssembly: Assembly {
    
    var onUserReceive: ((_ account: Account) -> Void)?
    
    private let authMethod: LemmyAuthMethod
    private let currentInstance: Instance
    
    init(
        authMethod: LemmyAuthMethod,
        currentInstance: Instance
    ) {
        self.authMethod = authMethod
        self.currentInstance = currentInstance
    }
    
    func makeModule() -> AddAccountViewController {
        let viewModel = AddAccountViewModel(
            shareData: LemmyShareData.shared
        )
        let vc = AddAccountViewController(
            viewModel: viewModel,
            authMethod: authMethod
        )
        
        onUserReceive = vc.onUserReceive
        
        return vc
    }
}
