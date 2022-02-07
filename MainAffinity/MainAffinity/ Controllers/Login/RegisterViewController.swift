//
//  RegisterViewController.swift
//  MainAffinity
//
//  Created by Jordan Kwek on 3/2/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import Firebase
import FirebaseFirestore
class RegisterViewController: UIViewController {
    var newDocumentID:String = "" //pass document id to Profile setup View Controller

    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
        }()

      

        private let firstNameField: UITextField = {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "First Name..."
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            field.leftViewMode = .always
            field.backgroundColor = .secondarySystemBackground
            field.spellCheckingType = .no
            field.autocorrectionType = .no
            field.clearButtonMode = .whileEditing
            return field
        }()

        private let lastNameField: UITextField = {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "Last Name..."
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            field.leftViewMode = .always
            field.backgroundColor = .secondarySystemBackground
            field.spellCheckingType = .no
            field.autocorrectionType = .no
            field.clearButtonMode = .whileEditing

            return field
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
            field.keyboardType = .emailAddress
            field.clearButtonMode = .whileEditing

            return field
        }()

        private let passwordField: UITextField = {
            let field = UITextField()
            field.clearButtonMode = .whileEditing
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

        private let registerButton: UIButton = {
            let button = UIButton()
            button.setTitle("Register", for: .normal)
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            return button
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Register"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))

        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
                              for: .touchUpInside)

        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)

        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)

        scrollView.isUserInteractionEnabled = true

    
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        let size = scrollView.width/3
    

        

        firstNameField.frame = CGRect(x: 30,
                                  y: 100,
                                  width: scrollView.width-60,
                                  height: 52)
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)

    }
    
    @objc private func registerButtonTapped() {
            emailField.resignFirstResponder()
            passwordField.resignFirstResponder()
            firstNameField.resignFirstResponder()
            lastNameField.resignFirstResponder()

            guard let firstName = firstNameField.text,
                let lastName = lastNameField.text,
                let email = emailField.text,
                let password = passwordField.text,
                !email.isEmpty,
                !password.isEmpty,
                !firstName.isEmpty,
                !lastName.isEmpty,
                password.count >= 6 else {
                    alertUserLoginError()
                    return
            }
        
        spinner.show(in: view)
        
        //Firebase login
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
                    
            guard !exists else{
            //User alrdy exist
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
            return
        }
        
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            guard authResult != nil, error == nil else{
                print("Error creating user")
                return
            }
            
            let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
//            DatabaseManager.shared.insertUser(with: chatUser, completion: {success in
//                if success {
//                    //upload image
//                    guard let image = strongSelf.imageView.image, let data = image.pngData() else{
//                        return
//                    }
//                    let fileName = chatUser.profilePictureFileName
//                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
//                        switch result {
//                        case .success(let downloadUrl):
//                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
//                            print(downloadUrl)
//                        case .failure(let error):
//                            print("Storage manager error: \(error)")
//                        }
//                    })
//                }
//            })
            let db = Firestore.firestore()
            let newDocument = db.collection("users").document()
            self!.newDocumentID = newDocument.documentID
            newDocument.setData(["firstname":firstName, "lastname":lastName, "uid": authResult!.user.uid ]){ (error) in
                if error != nil {
                    // Show error message
                    print(error?.localizedDescription )
                    
                }
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileSetupViewController = storyboard.instantiateViewController(identifier: "ProfileSetupVC") as? ProfileSetupViewController
            profileSetupViewController?.userEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            
            profileSetupViewController?.userName = firstName.trimmingCharacters(in: .whitespacesAndNewlines) + " " + lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            profileSetupViewController?.referenceDocId = self!.newDocumentID
            profileSetupViewController?.modalPresentationStyle = .fullScreen
            self!.present(profileSetupViewController ?? UIViewController(), animated: true, completion: nil)
           
            
        })
    })
    }
    
   
    func alertUserLoginError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "Enter info",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    
    
    @objc private func loginButtonTapped() {
            emailField.resignFirstResponder()
            passwordField.resignFirstResponder()

            guard let email = emailField.text, let password = passwordField.text,
                !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                    alertUserLoginError()
                    return
            }
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
        var vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    

}

extension RegisterViewController: UITextFieldDelegate {

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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentCamera()

        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentPhotoPicker()

        }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
