//
//  PictrsRequests.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 25.10.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

private protocol PictrsRequestManagerProtocol {
    func uploadPictrs(image: UIImage, completion: @escaping (Result<LemmyApiStructs.Pictrs.PictrsResponse, Error>) -> Void)
}

extension RequestsManager: PictrsRequestManagerProtocol {
    func uploadPictrs(image: UIImage, completion: @escaping (Result<LemmyApiStructs.Pictrs.PictrsResponse, Error>) -> Void) {
        return uploadImage(path: HttpLemmyEndpoint.Pictrs.image.endpoint,
                           image: image,
                           completion: completion)
    }
}