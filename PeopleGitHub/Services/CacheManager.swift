//
//  CacheManager.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 20.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import Foundation

class CacheManager {
    // MARK: - Properties
    static let shared = CacheManager()
    
    // MARK: - Public Methods
    func getImageData(from url: URL) -> Data? {
        let urlRequest = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
            return cachedResponse.data
        }
        return nil
    }

    func saveImageData(with data: Data, and response: URLResponse) {
        guard let urlResponse = response.url else { return }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        let urlRequest = URLRequest(url: urlResponse)
        URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
    }
}
