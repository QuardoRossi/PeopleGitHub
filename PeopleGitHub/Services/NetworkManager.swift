//
//  NetworkManager.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 17.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import Foundation

class NetworkManager {
    // MARK: - Properties
    static let shared = NetworkManager()
    
    // MARK: - Public Methods
    func fetchPeopleData<Box: Codable>(for object: Box,
                                       and urlJson: String,
                                       with complition: @escaping (Box) -> Void) {
        var dataFromNetwork = object
        guard let url = URL(string: urlJson) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error { print(error); return }
            guard let data = data else { return }
            
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                dataFromNetwork = try decoder.decode(Box.self, from: data)
                complition(dataFromNetwork)
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func fetchImageData(from url: URL, complition: @escaping (Data, URLResponse) -> Void)  {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error { print(error); return }
            guard let dataImage = data, let response = response else { return }

            guard let responseURL = response.url else { return }
            guard responseURL == url else { return }

            complition (dataImage, response)
        }.resume()
    }
}
