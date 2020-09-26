//
//  ImageManager.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 24.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import Foundation

class ImageManager {
    // MARK: - Properties
    static let shared = ImageManager()
    
    // MARK: - Public Methods
    func fetchImageData(from url: String, with complition: @escaping (Data?) -> Void)  {
        let imageData: Data? = nil
        
        guard let url = URL(string: url) else {
            complition(imageData)
            return
        }
        
        if let cachedResponseData = CacheManager.shared.getImageData(from: url) {
            let imageData = cachedResponseData
            complition(imageData)
        }
        
        NetworkManager.shared.fetchImageData(from: url) { (data, response) in
            DispatchQueue.main.async { complition(data) }
            CacheManager.shared.saveImageData(with: data, and: response)
        }
    }
}
