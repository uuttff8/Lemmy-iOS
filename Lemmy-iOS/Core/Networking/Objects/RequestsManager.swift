//
//  RequestsManager.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 9/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class RequestsManager {
    let wsClient = WSLemmy()
    
    func requestDecodable<Req: Codable, Res: Codable>(
        path: String,
        parameters: Req,
        parsingFromRootKey rootKey: String? = nil,
        completion: @escaping ((Result<Res, Error>) -> Void)
    ) {
        wsClient.send(on: path, data: parameters) { (outString) in
            self.decode(data: outString.data(using: .utf8)!, rootKey: rootKey, completion: completion)
        }
    }
    
    private func decode<D: Codable>(
        data: Data,
        rootKey: String?,
        completion: ((Result<D, Error>) -> Void)
    ) {
        let decoder = JSONDecoder()
        
        if let rootKey = rootKey {
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard dict?.keys.firstIndex(of: rootKey) != nil, let items = dict?[rootKey] else {
                    
                    // if no root key it maybe an error from backend
                    if let backendError = try? JSONDecoder().decode(LemmyApiStructs.ErrorResponse.self, from: data) {
                        completion(.failure(backendError.error))
                        return
                    }
                    
                    completion(.failure("Root key not found"))
                    return
                }
                let serializedData = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
                let dec = try decoder.decode(D.self, from: serializedData)
                completion(.success(dec))
            } catch let error {
                completion(.failure("JSON decoding failed with error: \(error)"))
            }
        } else {
            do {
                let dec = try decoder.decode(D.self, from: data)
                completion(.success(dec))
            } catch {
                completion(.failure("JSON decoding failed with error: \(error)"))
            }
        }
    }
}

extension String: Error {
    public var errorDescription: String { return self }
}
