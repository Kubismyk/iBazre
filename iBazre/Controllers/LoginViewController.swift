//
//  LoginViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 20.12.22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //googleButton.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        // Move view up while keyboard on
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Disable keyboard on tapping any view
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
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
    
    // Move view up while keyboard on
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 75
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        var email = loginField.text!
        var password = passwordField.text!
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password,completion:{ [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("failed to log in")
                return
            }
            let user = result.user
            
            //save email to userdefaults
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(user.uid, forKey: "userUid")
            
            print("user: \(user) logged succesfully")

            strongSelf.dismiss(animated: true)
        })
        
    }
    @IBAction func goToRegisterButton(_ sender: UIButton) {
        switchScreen(storyboardName: "LoginAndRegisterStoryboard", viewControllerName: "RegisterViewController")
    }
    
    

    
}


