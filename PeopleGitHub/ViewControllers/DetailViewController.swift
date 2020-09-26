//
//  DetailViewController.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 20.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - IB Outlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var topActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        }
    }
    
    // MARK: - Public Properties
    var loginUser: String!
    
    // MARK: - Private Properties
    private var userReposList: [UserRepos]?
    private var tableActivityIndicator = UIActivityIndicatorView()
    
    // MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStyleActivityIndicators()
        configureTop()
        configureTable()
    }
    
    // MARK: - IB Actions
    @IBAction func showDetailButton(_ sender: UIButton) {
        guard let indexPath = tableView.getIndexPath(for: sender as UIView) else { return }
        
        userReposList?[indexPath.row].hasPages = true //для развертывания ячейки
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Table view data source
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Список репозиториев"
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userReposList?.count ?? 0
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
        
        cell.configure(with: userReposList?[indexPath.row])
        return cell
    }
    
    // MARK: - Private Methods
    private func configureTop() {
        downloadDataForTop()
        
        topActivityIndicator.startAnimating()
        topActivityIndicator.hidesWhenStopped = true
    }
    
    private func configureTable() {
        downloadDataForTable()
        
        configureTableActivityIndicator()
        
        tableView.allowsSelection = false
    }

    private func downloadDataForTop() {
        let userData = UserData.getBaseData()
        
        let url = ApiGitHub.fetchUrlUserData(with: loginUser).urlAdress
        
        NetworkManager.shared.fetchPeopleData(for: userData, and: url) { (userData) in
            DispatchQueue.main.async { self.putDataInTopElements(with: userData) }
        }
    }

    private func downloadDataForTable() {
        let userRepos = UserRepos.getBaseData()
        
        let url = ApiGitHub.fetchUrlUserRepos(with: loginUser).urlAdress
        
        NetworkManager.shared.fetchPeopleData(for: userRepos, and: url) { (userRepos) in
            DispatchQueue.main.async { self.putDataInTable(with: userRepos) }
        }
    }
    
    private func putDataInTopElements(with userData: UserData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        topActivityIndicator.stopAnimating()
        nameLabel.text = userData.name ?? "No name"
        loginLabel.text = userData.login
        locationLabel.text = String(userData.location ?? "no location")
        dateLabel.text = dateFormatter.string(from: userData.createdAt ?? Date())
        
        ImageManager.shared.fetchImageData(from: userData.avatarUrl ?? "") { (data) in
            guard data != nil else { self.avatarImageView.image = #imageLiteral(resourceName: "stockImage"); return }
            self.avatarImageView.image = UIImage(data: data!)
        }
    }
    
    private func putDataInTable(with userReposList: [UserRepos]) {
        self.userReposList = userReposList
        updateUserReposList() //для развертывания ячейки
        tableActivityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    //для развертывания ячейки
    private func updateUserReposList() {
        guard userReposList != nil else { return }
        let oldList = userReposList!
        userReposList = []
        for var repos in oldList {
            repos.hasPages = false //добавляем каждой записи false
            userReposList?.append(repos)
        }
    }
    
    private func configureTableActivityIndicator() {
        tableActivityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        tableActivityIndicator.center = view.center
        view.addSubview(tableActivityIndicator)
        tableActivityIndicator.hidesWhenStopped = true
        tableActivityIndicator.startAnimating()
    }
    
    private func configureStyleActivityIndicators() {
        if #available(iOS 13.0, *) {
            topActivityIndicator.style = .medium
            tableActivityIndicator.style = .medium
        } else {
            topActivityIndicator.style = .gray
            tableActivityIndicator.style = .gray
        }
    }
}

// MARK: - Extension
extension UITableView {
    func getIndexPath(for view: AnyObject) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: location) as IndexPath?
    }
}
