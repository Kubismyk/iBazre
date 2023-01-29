//
//  FeedViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 04.01.23.
//

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    
    let testData = ["test1","test2","test3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.feedTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")

        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
        print("current user: \(FirebaseAuth.Auth.auth().currentUser?.uid)")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        validateAuth()
    }
    
    
    
    
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
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
        
        addSwipeControllerLeft(name: "Favorites", color: .systemBlue, handleFunction: self.handleMarkAsFavourite)
    }
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        addSwipeControllerRight(name: "archive", color: .magenta, handleFunction: self.handleMoveToArchive)
    }
    
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }
    

    
    
    private func addSwipeControllerLeft(name:String,color:UIColor,handleFunction: @escaping ()-> Void) -> UISwipeActionsConfiguration{
        let action = UIContextualAction(style: .normal,
                                        title: name) { [weak self] (action, view, completionHandler) in
                                            handleFunction()
                                            completionHandler(true)
        }
        action.backgroundColor = color
        
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    private func addSwipeControllerRight(name:String,color:UIColor,handleFunction: @escaping ()-> Void) -> UISwipeActionsConfiguration{
        func handleMoveToTrash() {
            print("Moved to trash")
        }
        
        let deleteAction = UIContextualAction(style: .destructive,
                                        title: "delete") { [weak self] (action, view, completionHandler) in
                                            handleMoveToTrash()
                                            completionHandler(true)
        }
        
        let archiveAction = UIContextualAction(style: .normal,
                                        title: name) { [weak self] (action, view, completionHandler) in
                                            handleFunction()
                                            completionHandler(true)
        }
        archiveAction.backgroundColor = color
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction,archiveAction])
    }

    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func handleMoveToArchive() {
        print("Moved to archive")
    }
}
