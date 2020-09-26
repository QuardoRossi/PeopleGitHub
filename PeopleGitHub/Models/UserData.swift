//
//  UserData.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 17.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import Foundation

struct UserDataList: Codable {
    let items: [UserData]
    let totalCount: Int?
}

struct UserData: Codable {
    let avatarUrl: String?
    let login: String?
    let type: String?
    let name: String?
    let createdAt: Date?
    let location: String?
    let reposUrl: String?
}

struct UserRepos: Codable {
    let name: String?
    let language: String?
    let stargazersCount: Int?
    let updatedAt: Date?
    var hasPages: Bool? //для хранения данных о необходимости развернуть ячейку
}

//Параметры для загрузки из сети (пагинация)
struct BootOption {
    var page: Int
    var lastPage: Bool
}

//Boxing (NetworkManager)
class Box<T: Codable> {
    typealias Listener = (T) -> Void
    
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(value: T) {
        self.value = value
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
}

struct ApiGitHub {
    let urlAdress: String
}

extension ApiGitHub {
    static func fetchUrlUserDataList(with user: String, and page: Int) -> ApiGitHub {
        return ApiGitHub(urlAdress: "https://api.github.com/search/users?q=\(user)&page=\(page)&per_page=15")
    }
    
    static func fetchUrlUserData(with user: String) -> ApiGitHub {
        return ApiGitHub(urlAdress: "https://api.github.com/users/\(user)")
    }
    
    static func fetchUrlUserRepos(with user: String) -> ApiGitHub {
        return ApiGitHub(urlAdress: "https://api.github.com/users/\(user)/repos")
    }
}

extension UserDataList {
    static func getBaseData() -> UserDataList {
        return UserDataList(items: [], totalCount: 0)
    }
}

extension UserData {
    static func getBaseData() -> UserData {
        return UserData(avatarUrl: "",
                        login: "",
                        type: "",
                        name: "",
                        createdAt: Date(),
                        location: "",
                        reposUrl: "")
    }
}

extension UserRepos {
    static func getBaseData() -> [UserRepos] {
        return [UserRepos(name: "",
                          language: "",
                          stargazersCount: 0,
                          updatedAt: Date(),
                          hasPages: false)]
    }
}
