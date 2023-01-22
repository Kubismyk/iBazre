//
//  RegisterViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.12.22.
//

import UIKit
import FirebaseAuth


class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    
    var termsIsAccepted:Bool = false {
        didSet {
            if termsIsAccepted{
            termsButton.setImage(UIImage(systemName: "square.fill"), for: .normal)
            } else {
                termsButton.setImage(UIImage(systemName: "square"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        

    }
    
    
    
    
    
    
    
    private func design(){
        usernameField.placeholder = "Username"
        emailField.placeholder = "Email Adress"
        passwordField.placeholder = "Password"
        repeatPasswordField.placeholder = "Repeat Password"
        if let usernameLeftImage = UIImage(systemName: "person.crop.circle")?.withTintColor(UIColor(named: "MainColor")!, renderingMode: .alwaysOriginal){
        usernameField.withImage(direction: .Left, image: usernameLeftImage, colorSeparator: .lightGray, colorBorder: .black)
        }
        if let emailLeftImage = UIImage(systemName: "command.circle")?.withTintColor(UIColor(named: "MainColor")!, renderingMode: .alwaysOriginal){
        emailField.withImage(direction: .Left, image: emailLeftImage, colorSeparator: .lightGray, colorBorder: .black)
        }
        if let passwordLeftImage = UIImage(systemName: "lock.circle")?.withTintColor(UIColor(named: "MainColor")!, renderingMode: .alwaysOriginal){
            passwordField.withImage(direction: .Left, image: passwordLeftImage, colorSeparator: .lightGray, colorBorder: .black)
            repeatPasswordField.withImage(direction: .Left, image: passwordLeftImage, colorSeparator: .lightGray, colorBorder: .black)
            }
    }
    
    @IBAction func iAgreeButton(_ sender: UIButton) {
        termsIsAccepted = !termsIsAccepted
    }
    

    @IBAction func registerButoon(_ sender: UIButton) {
        fieldsValidationAndUserAuth()

    }
    @IBAction func switchViewControllerToLogin(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    private func fieldsValidationAndUserAuth(){
        var username = usernameField.text!
        var password = passwordField.text!
        var email = emailField.text!
        var repeatPassword = repeatPasswordField.text!
        
        
        if password != repeatPassword {
            password = ""
            passwordField.attributedPlaceholder = NSAttributedString(
                string: "password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
            )
            repeatPassword = ""
            repeatPasswordField.attributedPlaceholder = NSAttributedString(
                string: "password doesn't match",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red.withAlphaComponent(0.5)]
            )
        }
        if email.isValidEmail() {
            print("valid")
        } else {
            email = ""
            emailField.attributedPlaceholder = NSAttributedString(
                string: "email not valid",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red.withAlphaComponent(0.5)]
            )
        }
        if password.isValidPassword() {
            print("valid")
        } else {
            password = ""
            passwordField.attributedPlaceholder = NSAttributedString(
                string: "password not valid",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red.withAlphaComponent(0.5)]
            )
        }
        
        if termsIsAccepted{
            errorLabel.alpha = 0
        } else {
            errorLabel.textColor = .red
            errorLabel.alpha = 1
            errorLabel.text = "read and accept terms of services"
        }
        
        
        if email.isValidEmail() && password.isValidPassword() && password == repeatPassword && termsIsAccepted {
            
            DatabaseManager.shared.emailExsistCheck(with: email) { exists in
                guard !exists else {
                    // email exsists so shows error
                    self.errorLabel.text = "user already exsists"
                    self.errorLabel.alpha = 1
                    return
                }
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    guard let result = authResult, error == nil else {
                        self.errorLabel.text = "error creating user"
                        return
                    }
                    let user = result.user
                    DatabaseManager.shared.insertUser(with: User(username: username, emailAdress: email, profilePictureURL: ""))
                    print("user created \(user)")
                    goToFeed()
                }
            }
            
        }

    }
    
}

