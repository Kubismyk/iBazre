//
//  MenuViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.01.23.
//

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController {
    
    private var testButoon:UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        self.view.addSubview(testButoon)
    }
    
    @objc func buttonAction(sender:UIButton) {
        //alert should be added if user clicks by an accident
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyboard = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}
