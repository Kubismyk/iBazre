//
//  RegisterViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.12.22.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var termsButton: UIButton!
    
    
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
    }
    
}
