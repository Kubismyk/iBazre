//
//  MenuViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.01.23.
//

import UIKit
import FirebaseAuth

protocol MenuViewControllerDelegate: AnyObject {
    func removePropertyFromConversations(_ property: Conversation)
}

class MenuViewController: UIViewController {
    
    weak var feedViewController: FeedViewController?
    
    private var logOutButton:UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.setTitle("Sign out", for: .normal)
        button.titleLabel?.textColor = .red
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        self.view.addSubview(logOutButton)
    }
    
    func removeConversations() {
        feedViewController?.removeAllConversations()
        feedViewController?.feedTableView.reloadData()
    }
    
    
    private func logOutAlert(){
        let alertController = UIAlertController(title: "Sign out?", message: "You can always access your content by logging back", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.removeConversations()
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                let storyboard = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func buttonAction(sender:UIButton) {
        logOutAlert()
    }
}
