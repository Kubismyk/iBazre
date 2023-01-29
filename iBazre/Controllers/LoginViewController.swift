//
//  LoginViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.12.22.
//

import UIKit
import FirebaseAuth

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
        var email = loginField.text!
        var password = passwordField.text!
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password,completion:{ [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else {
                print("failed to log in")
                return
            }
            let user = result.user
            print("user: \(user) logged succesfully")

            strongSelf.dismiss(animated: true)
        })
        
    }
    @IBAction func goToRegisterButton(_ sender: UIButton) {
        switchScreen(storyboardName: "LoginAndRegisterStoryboard", viewControllerName: "RegisterViewController")
    }
    
    

    
}


