//
//  ProfileViewController.swift
//  MainAffinity
//
//  Created by Jordan Kwek on 3/2/22.
//

 
import UIKit
import FirebaseAuth
import SwiftUI
import SDWebImage
import CoreData

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let userController = UserController()
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return nil
            }

            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            let filename = safeEmail + "_profile_picture.png"
            let path = "images/"+filename

            let headerView = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: self.view.width,
                                            height: 300))

            headerView.backgroundColor = .link

            let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2,
                                                      y: 75,
                                                      width: 150,
                                                      height: 150))
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .white
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 3
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = imageView.width/2
            headerView.addSubview(imageView)

            StorageManager.shared.downloadURL(for: path, completion: { result in
                switch result {
                case .success(let url):
                    imageView.sd_setImage(with: url, completed: nil)
                    //self?.downloadImage(imageView: imageView, url: url)
                case .failure(let error):
                    print("Failed to get download url: \(error)")
                }
            })

            return headerView
        }
    func downloadImage(imageView: UIImageView, url:URL){
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
                    
        }).resume()
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        //as! ProfileTableViewCell
        //cell.setUp(with: viewModel)
        
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //data[indexPath.row].handler?()
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut() //firebase signOff
                self!.userController.logOutUser() // remove user entity from coredata
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        

    }
}
