//
//  LemmyCheckLogin.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 10/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class LemmyContinueIfLogined {
    
    init(onViewController: UIViewController?, doAction: () -> Void) {
        if let _ = LemmyShareData.shared.jwtToken {
            doAction()
        }
    }
}