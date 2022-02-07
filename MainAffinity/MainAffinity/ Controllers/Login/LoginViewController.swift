//

//  LoginViewController.swift

//  MainAffinity

//

//  Created by Jordan Kwek on 3/2/22.

import UIKit

import Foundation

import FirebaseAuth

import JGProgressHUD
import CoreData
class LoginViewController: UIViewController {
    private let userController = UserController()
    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView: UIScrollView = {

        let scrollView = UIScrollView()

        scrollView.clipsToBounds = true

        return scrollView

    }()

    private let imageView: UIImageView = {

        let imageView = UIImageView()

        imageView.image = UIImage(named: "Logo")

        imageView.contentMode = .scaleAspectFit

        return imageView

    }()

    private let emailField: UITextField = {

        let field = UITextField()

        field.autocapitalizationType = .none

        field.autocorrectionType = .no

        field.returnKeyType = .continue

        field.layer.cornerRadius = 12

        field.layer.borderWidth = 1

        field.layer.borderColor = UIColor.lightGray.cgColor

        field.placeholder = "Email Address..."

        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))

        field.leftViewMode = .always

        field.backgroundColor = .secondarySystemBackground

        return field

    }()

    private let passwordField: UITextField = {

        let field = UITextField()

        field.autocapitalizationType = .none

        field.autocorrectionType = .no

        field.returnKeyType = .done

        field.layer.cornerRadius = 12

        field.layer.borderWidth = 1

        field.layer.borderColor = UIColor.lightGray.cgColor

        field.placeholder = "Password..."

        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))

        field.leftViewMode = .always

        field.backgroundColor = .secondarySystemBackground

        field.isSecureTextEntry = true

        return field

    }()

    private let loginButton: UIButton = {

        let button = UIButton()

        button.setTitle("Log In", for: .normal)

        button.backgroundColor = .link

        button.setTitleColor(.white, for: .normal)

        button.layer.cornerRadius = 12

        button.layer.masksToBounds = true

        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)

        return button

    }()


    private let navBar : UINavigationBar = {

        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIView().frame.size.width, height: 44))

        return bar

                                
    }()

    private let navItem = UINavigationItem(title: "Login")

    private let registerButtonItem : UIBarButtonItem = {

        let barButtonItem = UIBarButtonItem(title: "Register",style: .done, target: self, action: #selector(didTapRegister))

        return barButtonItem

    }()

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.

//        self.title = "Log In"

                view.backgroundColor = .systemBackground

                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",

                                                                    style: .done,

                                                                    target: self,

                                                                    action: #selector(didTapRegister))

        loginButton.addTarget(

            self,

            action: #selector(loginButtonTapped),

            for: .touchUpInside

        )

        emailField.delegate = self
        emailField.keyboardType = .emailAddress
        emailField.clearButtonMode = .whileEditing
        

        passwordField.delegate = self
        passwordField.clearButtonMode = .whileEditing
        view.addSubview(navBar)

        navItem.rightBarButtonItem = registerButtonItem

        navItem.title = self.title

        

        navBar.setItems([self.navItem], animated: true)

        // Adding subviews

        view.addSubview(scrollView)


        scrollView.addSubview(imageView)

        scrollView.addSubview(emailField)

        scrollView.addSubview(passwordField)

        scrollView.addSubview(loginButton)

}

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds

        let size = scrollView.width/3

        imageView.frame = CGRect(x: (scrollView.width-size)/2,

                                 y: 20,

                                 width: size,

                                 height: size)

        emailField.frame = CGRect(x: 30,

                                  y: imageView.bottom+10,

                                  width: scrollView.width-60,

                                  height: 52)

        passwordField.frame = CGRect(x: 30,

                                     y: emailField.bottom+10,

                                     width: scrollView.width-60,

                                     height: 52)

        loginButton.frame = CGRect(x: 30,

                                   y: passwordField.bottom+10,

                                   width: scrollView.width-60,

                                   height: 52)

        //loginButton.center = scrollView.center

        //loginButton.frame.origin.y = loginButton.bottom+20

    }

    
    @objc private func loginButtonTapped() {

            emailField.resignFirstResponder()

            passwordField.resignFirstResponder()

            guard let email = emailField.text, let password = passwordField.text,

                !email.isEmpty, !password.isEmpty, password.count >= 6 else {

                    alertUserLoginError()

                    return

            }

        

        spinner.show(in: view)

        

        //Firebase login

        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else {

                return

            }
        
            DispatchQueue.main.async {

                strongSelf.spinner.dismiss()

            }
            guard let result = authResult, error == nil else {

                print("Failed to log in user with email: \(email)")

                return

            }

            let user = result.user

            
            
            if(self!.userController.loginUser(loginEmail: email)){//check if coredata saving works
                UserDefaults.standard.set(email, forKey: "email")
                print("Logged in user")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
            else{
                self!.alertFirebaseProfileError()
            }
        })

    }

    func alertFirebaseProfileError(){
        let alert = UIAlertController(title: "Profile Not Found", message: "Your profile is invalid. To resolve this error, kindly setup a new Affinity Profile", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func alertUserLoginError(){

        let alert = UIAlertController(title: "Missing Info",

                                      message: "Please enter all information to log in.",

                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title:"Dismiss",

                                      style: .cancel, handler: nil))

        present(alert, animated: true)

    }

    

    @objc private func didTapRegister() {

        let vc = RegisterViewController()

        vc.title = "Create Account"

        navigationController?.pushViewController(vc, animated: true)

    }

    

}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == emailField {

            passwordField.becomeFirstResponder()

        }

        else if textField == passwordField {

            loginButtonTapped()

        }

        return true

    }

}
