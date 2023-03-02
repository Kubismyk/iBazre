//
//  FeedViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 04.01.23.
//

import UIKit
import SideMenu
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    
    let testData = ["test1","test2","test3"]
    private var conversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.searchBarClick.delegate = self
        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
        design()
        startListeningForConversations()
        print("1111111")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        validateAuth()
        print("2222222")
    }
    
    private func design(){
        self.title = "Chats"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), landscapeImagePhone: UIImage(systemName: "line.3.horizontal"), style: .done, target: self, action: #selector(openMenu))
    }
    
    @objc func openMenu(){
        let menu = SideMenuNavigationController(rootViewController: MenuViewController())
        menu.leftSide = true
        present(menu, animated: true, completion: nil)
        print("\(conversations)")
    }
    
    
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        print(safeEmail)
        DatabaseManager.shared.getConversation(with: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversations.append(conversations)
                print(self?.conversations)
                DispatchQueue.main.async {
                    self?.feedTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching conversation: \(error.localizedDescription)")
            }
        }
    }
    
    
    @IBAction func newConversationButton(_ sender: UIButton) {
        let vc = SearchViewController()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
        let navVc = UINavigationController(rootViewController: vc)
        self.present(navVc, animated: true, completion: nil)
    }
    private func createNewConversation(result: [String:String]){
        guard let name = result["name"],
              let email = result["mail"] else {
            return
        }
        let vc = ChatViewController(with: email)
        vc.isNewConversation = true
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        navVc.navigationBar.topItem?.title = name
        self.present(navVc, animated: true)
    }
    @IBOutlet weak var searchBarClick: UISearchBar!
    
}



extension FeedViewController:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let vc = SearchViewController()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
        let navVc = UINavigationController(rootViewController: vc)
        self.present(navVc, animated: true, completion: nil)
    }
}





extension FeedViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell {
            cell.config(with: model)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = conversations[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UINavigationController(rootViewController: ChatViewController(with: model.otherUserEmail))
        vc.modalPresentationStyle = .fullScreen
        vc.title = model.name
        self.present(vc, animated: true)
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
