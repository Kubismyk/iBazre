//
//  LoginViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.12.22.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }
    
    private func design(){
        loginField.placeholder = "Email Adress"
        passwordField.placeholder = "Password"
        
        if let usernameLeftImage = UIImage(systemName: "person.crop.circle")?.withTintColor(UIColor(named: "MainColor")!, renderingMode: .alwaysOriginal){
        loginField.withImage(direction: .Left, image: usernameLeftImage, colorSeparator: .lightGray, colorBorder: .black)
        }
        if let passwordLeftImage = UIImage(systemName: "lock.circle")?.withTintColor(UIColor(named: "MainColor")!, renderingMode: .alwaysOriginal){
        passwordField.withImage(direction: .Left, image: passwordLeftImage, colorSeparator: .lightGray, colorBorder: .black)
        }
    }
    
    
    
    @IBAction func loginButton(_ sender: UIButton) {
    }
    
}
