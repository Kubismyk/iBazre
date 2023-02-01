//
//  MenuViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.01.23.
//

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOut(_ sender: UIButton) {
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
