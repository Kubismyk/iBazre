//
//  ViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 15.12.22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        

    }
    @IBAction func Test(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(vc, animated: true, completion: nil)
    }
}

