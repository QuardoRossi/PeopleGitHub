//
//  DetailTableViewCell.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 20.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var dateUpdateLabel: UILabel!
    @IBOutlet var starsLabel: UILabel!
    @IBOutlet var detailButton: UIButton!
    
    // MARK: - Public Methods
    func configure(with object: UserRepos?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let name = object?.name ?? "Error repos name"
        let language = object?.language ?? "Empty"
        let stars = (String(object?.stargazersCount ?? 0))
        let dateUpdate = dateFormatter.string(from: object?.updatedAt ?? Date())
        
        nameLabel.text = name
        languageLabel.text = language
        starsLabel.text = "Количество звёзд: \(stars)"
        dateUpdateLabel.text = "Дата обновления: \(dateUpdate)"
        
        object?.hasPages == true ? showDetailInfo() : hideDetailInfo()
    }
    
    // MARK: - Private Methods
    private func hideDetailInfo() {
        detailButton.isHidden = false
        dateUpdateLabel.isHidden = true
        starsLabel.isHidden = true
    }
    
    private func showDetailInfo() {
        detailButton.isHidden = true
        dateUpdateLabel.isHidden = false
        starsLabel.isHidden = false
    }
}
