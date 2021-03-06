//
//  LoginData.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 10/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import KeychainSwift

extension UserDefaults {
    enum Key {
        static let jwt = "jwt"
        static let userId = "userId"
        static let userdata = "userdata"
        static let currentInstanceUrl = "currentInstanceUrl"
        static let blockedUsersId = "blockedUsersId"
        
        static let needsAppOnboarding = "needsAppOnboarding"
    }
    
    static let userSuiteName = "userDefaults.uuttff8.LemmyiOS"
    static let appSuiteName = "userDefaults.uuttff8.LemmyiOS.user"
    
    static var userShared: UserDefaults {
        let userDefaults = UserDefaults(suiteName: UserDefaults.userSuiteName)!
        
        return userDefaults
    }
    
    static var appShared: UserDefaults {
        let userDefaults = UserDefaults(suiteName: UserDefaults.appSuiteName)!
        
        userDefaults.register(defaults: [
            Key.needsAppOnboarding: true
        ])
        
        return userDefaults
    }
}

class LoginData {
    static let shared = LoginData()

    private let keychain = KeychainSwift()
    
    let userUserDefaults = UserDefaults.userShared
    let appUserDefaults = UserDefaults.appShared

    func login(jwt: String) {
        self.jwtToken = jwt
    }

    func logout() {
        ApiManager.chainedWsCLient.close()
        self.clear()
        userUserDefaults.resetDefaults()
        URLCache.shared.removeAllCachedResponses()
    }
    
    // delete all except currentInstance URL
    func userLogout() {
        let currInstance = LemmyShareData.shared.currentInstanceUrl
        self.clear()
        userUserDefaults.resetDefaults()
        URLCache.shared.removeAllCachedResponses()
        LemmyShareData.shared.currentInstanceUrl = currInstance
    }
    
    var isLoggedIn: Bool {
        jwtToken != nil && userId != nil
    }

    var jwtToken: String? {
        get { keychain.get(UserDefaults.Key.jwt) }
        set { keychain.set(newValue!, forKey: UserDefaults.Key.jwt) }
    }

    var userId: LMModels.Source.LocalUserSettings.ID? {
        get { userUserDefaults.integer(forKey: UserDefaults.Key.userId) }
        set { userUserDefaults.set(newValue, forKey: UserDefaults.Key.userId) }
    }

    func clear() {
        userUserDefaults.removeSuite(named: UserDefaults.userSuiteName)
        keychain.clear()
    }
}
