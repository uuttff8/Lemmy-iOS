//
//  RequestsManager.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 9/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import Combine

// MARK: - Error -
struct ApiErrorResponse: Codable, Equatable {
    let error: String
}

class RequestsManager {
    
    struct ApiResponse<T: Codable>: Codable {
        let op: String
        let data: T
    }
    
    let wsClient = WSLemmyClient()
    let httpClient = HttpLemmyClient()
    
    let decoder = LemmyJSONDecoder()
    
    func asyncRequestDecodable<Req: Codable, Res: Codable>(
        path: String,
        parameters: Req? = nil,
        parsingFromRootKey rootKey: String? = nil
    ) -> AnyPublisher<Res, LemmyGenericError> {
        
        wsClient.asyncSend(on: path, data: parameters)
            .flatMap { (outString: String) in
                self.asyncDecode(data: outString.data(using: .utf8)!)
            }.eraseToAnyPublisher()
    }
    
    func requestDecodable<Req: Codable, Res: Codable>(
        path: String,
        parameters: Req? = nil,
        parsingFromRootKey rootKey: String? = nil,
        completion: @escaping ((Result<Res, LemmyGenericError>) -> Void)
    ) {
        wsClient.send(on: path, data: parameters) { (outString) in
            self.decode(data: outString.data(using: .utf8)!, rootKey: rootKey, completion: completion)
        }
    }
    
    func uploadImage<Res: Codable>(
        path: String,
        image: UIImage,
        completion: @escaping ((Result<Res, LemmyGenericError>) -> Void)
    ) {
        httpClient.uploadImage(url: path, image: image) { (result) in
            switch result {
            case .failure(let why):
                completion(.failure(why))
            case .success(let outData):
                
                guard let decoded = try? self.decoder.decode(Res.self, from: outData) else {
                    completion(.failure(.string("Failed to decode from \(Res.self)")))
                    return
                }
                completion(.success(decoded))
            }
        }
    }
    
    private func asyncDecode<D: Codable>(
        data: Data
    ) -> Future<D, LemmyGenericError> {
        
        Future { promise in
            
            guard let apiResponse = try? self.decoder.decode(ApiResponse<D>.self, from: data)
            else {
                promise(.failure("Can't decode api response \(String(data: data, encoding: .utf8)!)".toLemmyError))
                return
            }
            
            let normalResponse = apiResponse.data
            promise(.success(normalResponse))
        }
    }
    
    private func decode<D: Codable>(
        data: Data,
        rootKey: String?,
        completion: ((Result<D, LemmyGenericError>) -> Void)
    ) {
        if let rootKey = rootKey {
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard dict?.keys.firstIndex(of: rootKey) != nil, let items = dict?[rootKey] else {
                    
                    // if no root key it maybe an error from backend
                    if let backendError = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) {
                        completion(.failure(.string(backendError.error)))
                        return
                    }
                    
                    completion(.failure(.string("Root key not found")))
                    return
                }
                let serializedData = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
                let dec = try decoder.decode(D.self, from: serializedData)
                completion(.success(dec))
            } catch let error {
                completion(.failure(.string("JSON decoding failed with error: \(error)")))
            }
        } else {
            do {
                let dec = try decoder.decode(D.self, from: data)
                completion(.success(dec))
            } catch {
                completion(.failure(.string("JSON decoding failed with error: \(error)".errorDescription)))
            }
        }
    }
}

extension String: Error {
    public var errorDescription: String { return self }
}
