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
        let firebaseAuth = Auth.auth()
    do {
        try firebaseAuth.signOut()
        let story = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
    }
}
