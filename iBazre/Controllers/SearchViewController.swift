//
//  SearchViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 03.02.23.
//

import UIKit
import JGProgressHUD

class SearchViewController: UIViewController {
    let spiner = JGProgressHUD(style: .dark)
    
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
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(dismissSelf))
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()
    }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true)
    }


}

extension SearchViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
