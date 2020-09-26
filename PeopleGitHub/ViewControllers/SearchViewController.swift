//
//  SearchViewController.swift
//  PeopleGitHub
//
//  Created by Михаил Кожанов on 21.09.2020.
//  Copyright © 2020 MikhailKozhanov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userSearchBar: UISearchBar!
    
    // MARK: - Private Properties
    private var userList: [UserData]?
    private var paggingActivityIndicator = UIActivityIndicatorView()
    private var tableActivityIndicator = UIActivityIndicatorView()
    
    // MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        userSearchBar.delegate = self
        
        configureStyleActivityIndicator()
        configureTableActivityIndicator()
    }
    
    // MARK: - Override Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dvc = segue.destination as? DetailViewController else { return }
        dvc.loginUser = sender as? String
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! SearchTableViewCell
        
        if let count = userList?.count {
            if indexPath.row == (count - 1) {
                configurePaggingActivityIndicator()
                downloadData()
            }
        }
        
        cell.configure(with: userList?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loginUser = userList![indexPath.row].login
        performSegue(withIdentifier: "detailSegue", sender: loginUser)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    private func downloadData() {
        let userList = UserDataList.getBaseData()
        let bootOption = calculatePageCurrent()
        let url = ApiGitHub.fetchUrlUserDataList(with: userSearchBar.text!,
                                                 and: bootOption.page).urlAdress
        
        guard bootOption.lastPage == false else { return }
        
        NetworkManager.shared.fetchPeopleData(for: userList, and: url) { (userList) in
            DispatchQueue.main.async {
                if userList.totalCount == 0 {
                    self.showAlert(with: "Пользователь не найден", and: "Измените текст запроса")
                } else {
                    self.updateUserList(from: userList.items)
                    self.sortPeople()
                    self.paggingActivityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
                self.tableActivityIndicator.stopAnimating()
            }
        }
    }
    
    private func updateUserList(from newData: [UserData]?) {
        userList = StorageManager.shared.fetchData()
        
        guard newData != nil else { return }
        
        if self.userList != nil {
            self.userList = self.userList! + newData!
        } else {
            self.userList = newData
        }
        StorageManager.shared.saveData(dataset: self.userList!)
    }
    
    private func sortPeople() {
        guard userSearchBar.selectedScopeButtonIndex == 1 else { return }
        
        var dictionary: [String : UserData] = [:]
        for userData in userList! {
            dictionary[userData.login!] = userData
        }
        
        let sortedDictionary = dictionary.sorted(by: { $0.key.lowercased() < $1.key.lowercased() })
        userList = []
        for (_, value) in sortedDictionary {
            userList?.append(value)
        }
    }
    
    private func calculatePageCurrent() -> BootOption {
        var bootOption = BootOption(page: 1, lastPage: false)
        guard let count = userList?.count else { return bootOption }
        
        let pageCountModal = count % 15
        if pageCountModal == 0 {
            bootOption.page = (count / 15) + 1
            bootOption.lastPage = false
        } else {
            bootOption.page = lroundf(Float(count / 15))
            bootOption.lastPage = true
        }
        
        return bootOption
    }
    
    private func clearTable() {
        userList = nil
        tableView.reloadData()
        StorageManager.shared.deleteData()
    }
    
    private func configureTableActivityIndicator() {
        tableActivityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        tableActivityIndicator.center = view.center
        view.addSubview(tableActivityIndicator)
        tableActivityIndicator.hidesWhenStopped = true
    }
    
    private func configurePaggingActivityIndicator() {
        paggingActivityIndicator.hidesWhenStopped = true
        paggingActivityIndicator.startAnimating()
        tableView.tableFooterView = paggingActivityIndicator
    }
    
    private func configureStyleActivityIndicator() {
        if #available(iOS 13.0, *) {
            paggingActivityIndicator.style = .medium
            tableActivityIndicator.style = .medium
        } else {
            paggingActivityIndicator.style = .gray
            tableActivityIndicator.style = .gray
        }
    }
}

// MARK: - Extension
extension SearchViewController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard !userSearchBar.text!.trimmingCharacters(in: .whitespaces).isEmpty,
              !userSearchBar.text!.isEmpty else {
            userSearchBar.text = ""
            showAlert(with: "Запрос не выполнен", and: "Введите текст")
            return
        }
        
        tableActivityIndicator.startAnimating()
        clearTable()
        downloadData()
        
        searchBar.showsScopeBar = true
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearTable()
        searchBar.text?.removeAll()
        searchBar.showsScopeBar = false
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        clearTable()
        searchBar.text?.removeAll()
        searchBar.showsScopeBar = false
    }
    
    func searchBar(_ searchBar: UISearchBar,
                            selectedScopeButtonIndexDidChange selectedScope: Int) {
        clearTable()
        tableActivityIndicator.startAnimating()
        downloadData()
    }
    
    func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
