//
//  SearchViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 03.02.23.
//

import UIKit
import JGProgressHUD

class SearchViewController: UIViewController {
    public var completion: (([String:String]) -> (Void))?
    private var users = [[String:String]]()
    private var results = [[String:String]]()
    private var hasFetfched = false
    
    let spiner = JGProgressHUD(style: .dark)
    
    
    //navigation UI
    private var searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search the world"
        return searchBar
    }()
    private let tableView:UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private let noResultLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "no user found"
        label.textAlignment = .center
        return label
    }()
    

    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(dismissSelf))
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = view.bounds
        self.noResultLabel.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
    }
    
//    fileprivate func setupConstraints() {
//       view.addSubview(tableView)
//        view.addSubview(noResultLabel)
//       tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
//       tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
//       tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
//       tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
//    }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true)
    }

}



extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = self.results[indexPath.row]["name"]
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
        
        completion?(targetUserData)
    }
}




extension SearchViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spiner.show(in: view)
        self.searchForUser(query: text)
    }
    func searchForUser(query:String){
        if hasFetfched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetfched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("failed to fetch users: \(error)")
                }
            }
        }
    }
    func filterUsers(with term:String){
        guard hasFetfched else {
            return
        }
        self.spiner.dismiss(animated: true)
        
        let results: [[String:String]] = self.users.filter { a in
            guard let name = a["name"]?.lowercased() as? String else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        self.results = results
        updateUI()
    }
    
    func updateUI(){
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}
