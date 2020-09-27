//
//  SearchTableViewCell.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 17.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        }
    }
    
    // MARK: - Public Methods
    func configure(with object: UserData?) {
        avatarImageView.image = nil
        
        var type = object?.type ?? "Error type"
        if object?.type == "User" { type = "Пользователь" }
        if object?.type == "Organization" { type = "Организация" }

        typeLabel.text = type
        loginLabel.text = object?.login ?? "Error login"

        ImageManager.shared.fetchImageData(from: object?.avatarUrl ?? "") { (data) in
            guard data != nil else { self.avatarImageView.image = #imageLiteral(resourceName: "stockImage"); return }
            self.avatarImageView.image = UIImage(data: data!)
        }
    }
}
