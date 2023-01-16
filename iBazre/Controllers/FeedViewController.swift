//
//  FeedViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 04.01.23.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    
    let testData = ["test1","test2","test3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.feedTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")

        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
    }
}








extension FeedViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell {
            cell.ttest.text = testData[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        addSwipeControllerLeft(name: "Favorites", color: .systemBlue)
    }
//    func tableView(_ tableView: UITableView,
//                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        // ...
//    }
    
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }
    
    
    
    
    
    private func addSwipeControllerLeft(name:String,color:UIColor) -> UISwipeActionsConfiguration{
        let action = UIContextualAction(style: .normal,
                                        title: name) { [weak self] (action, view, completionHandler) in
                                            self?.handleMarkAsFavourite()  // I need to create function with accepts another function as a parametre
                                            completionHandler(true)
        }
        action.backgroundColor = color
        return UISwipeActionsConfiguration(actions: [action])
    }

    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func handleMoveToTrash() {
        print("Moved to trash")
    }

    private func handleMoveToArchive() {
        print("Moved to archive")
    }
}
