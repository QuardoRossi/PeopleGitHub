//
//  StorageManager.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 18.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import Foundation

class StorageManager {
    // MARK: - Properties
    static let shared = StorageManager()
    
    private var archiveURL: URL!
    private let documentsDirectory = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
    ).first!
    
    // MARK: - Initializers
    private init() {
        archiveURL = documentsDirectory.appendingPathComponent("userData").appendingPathExtension("plist")
    }
    
    // MARK: - Public Methods
    func saveData(dataset: [UserData]) {
        var dataCodable: Data
        do {
            try dataCodable = PropertyListEncoder().encode(dataset)
            try dataCodable.write(to: archiveURL, options: .noFileProtection)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func fetchData() -> [UserData]? {
        var dataCodable: Data
        var dataset: [UserData]? = nil

        do {
            try dataCodable = Data(contentsOf: archiveURL)
            try dataset = PropertyListDecoder().decode([UserData].self,
                                                            from: dataCodable)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        return dataset
    }
    
    func deleteData() {
        let userData: [UserData] = []
        saveData(dataset: userData)
    }
}
