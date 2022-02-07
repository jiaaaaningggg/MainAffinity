//
//  UserController.swift
//  Affinity
//
//  Created by Mahshukurrahman on 30/1/22.
//

import Foundation
import CoreData
import UIKit
import FirebaseFirestore
import FirebaseStorage
import Firebase
import CoreLocation
class UserController {
    func logOutUser(){
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDUser")
        do{
            let userList = try? context.fetch(fetchRequest)
            if userList?.count == 1 {//confirm only 1 user was logged in
                let cdUser = userList![0]
                try context.delete(cdUser)
                try! context.save()
            }
        }
        catch let error as NSError{
            print("Could not logout User: \(error.userInfo)")
        }
    }
    func loginUser(loginEmail:String) -> Bool{
        
        var loginUser :User?
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let db = Firestore.firestore()
        let userRef = db.collection("users")
        var userFound:Bool = false
        let query = userRef.whereField("email", isEqualTo: loginEmail)
        query.getDocuments{ (querySnapshot,err) in
            if let err = err{
                print ("Error logging in user: \(err)")
            }
            if let snapshot = querySnapshot{
                for document in snapshot.documents{
                    if (document.exists){
                        let name = document["name"] as? String
                        let gender = document["Gender"] as? String
                        let language = document["Nationality"] as? String
                        let age = document["age"] as? Int
                        let bio = document["bio"] as? String
                        let contactNo = document["contactNo"] as? String
                        let currentLatitude = document["currentLatitude"] as? Double
                        let currentLongitude = document["currentLongitude"] as? Double
                        let dateOfBirth = Date (timeIntervalSince1970: (document["dob"] as! Double) / 1000.0)
                        let nationality = document["Nationality"] as? String
                        let speakingLanguage = document["Language"] as? String
                        let minAgeFilter = document["minAgeFilter"] as? Int
                        let maxAgeFilter = document["maxAgeFilter"] as? Int
                        var occupation:String?
                        var institution : String?
                        if let occ = document["occupation"] as? String{
                            occupation = occ
                        }
                        if let institute = document["institution"] as? String {
                            institution = institute
                        }
                        let profileImage = self.retrieveProfileImage(userImageName: name!)
                        loginUser = User(name: name!, contactNo: contactNo!, dob: dateOfBirth, nationality: nationality!, language: speakingLanguage!, gender: gender!, emailAddr: loginEmail, institution: institution!, bio: bio!, location: CLLocation.init(latitude: currentLatitude!, longitude: currentLongitude!), occupation: occupation ?? nil, image: profileImage)
                        self.addNewUser(newUser: loginUser!)
                       userFound = true
                    }
                }
            }
            
        }
        return userFound

    }
    func addNewUser(newUser:User){
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CDUser", in: context)!
        let user = NSManagedObject(entity: entity, insertInto: context)
        user.setValue(newUser.name, forKey: "name")
        user.setValue(newUser.email, forKey: "email")
        user.setValue(newUser.minAgeFilter, forKey: "minimumAgeFilter")
        user.setValue(newUser.maxAgeFilter, forKey: "maximumAgeFilter")
        user.setValue(newUser.nationality!, forKey: "nationality")
        user.setValue(newUser.bio!, forKey: "bio")
        user.setValue(newUser.age!, forKey: "age")
        user.setValue(newUser.gender, forKey: "gender")
        user.setValue(newUser.speakingLanguage!, forKey: "speakingLanguage")
        user.setValue(newUser.contactNo, forKey: "contactNo")
        user.setValue(newUser.dateOfBirth!, forKey: "dateOfBirth")
        if let institution =  newUser.institution {
            user.setValue(institution, forKey: "institution")
        }
        if let occupation = newUser.occupation {
            user.setValue(occupation, forKey: "occupation")
        }
        user.setValue(newUser.currentLongitude, forKey: "currentLongitude")
        user.setValue(newUser.currentLatitude, forKey: "currentLatitude")
        
        //user.setValue(newUser.image!, forKey: "photo")
        if newUser.occupation != nil {
            user.setValue(newUser.occupation, forKey: "occupation")
        }
        if newUser.institution != nil {
            user.setValue(newUser.institution, forKey: "institution")
        }
        do{
            try context.save()
        }
        catch let error as NSError{
            print("Could not save profile. \(error), \(error.userInfo)")
        }
    }
    func getUser() -> User?{
        var users :[NSManagedObject] = []
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDUser")
        do{
            users = try context.fetch(fetchRequest)
            if(users.count > 0){ //no user found
                
            let name = users[0].value(forKeyPath: "name") as? String
            let email = users[0].value(forKeyPath: "email") as? String
            let minimumAgeFilter = users[0].value(forKeyPath: "minimumAgeFilter") as? Int
            let maximumAgeFilter = users[0].value(forKeyPath: "maximumAgeFilter") as? Int
            let nationality = users[0].value(forKeyPath: "nationality") as? String
            let bio = users[0].value(forKeyPath: "bio") as? String
            let gender = users[0].value(forKeyPath: "gender") as? String
            let age = users[0].value(forKeyPath: "age") as? Int
            let speakingLanguage = users[0].value(forKeyPath: "speakingLanguage") as? String
            let contactNo = users[0].value(forKeyPath: "contactNo") as? String
            let dob = users[0].value(forKeyPath: "dateOfBirth") as? Date
            let latitude = users[0].value(forKeyPath: "currentLatitude") as? Double
            let longitude = users[0].value(forKeyPath: "currentLongitude") as? Double
            //let profileImage = retrieveProfileImage(userImageName: name!)
                let location = CLLocation.init(latitude: latitude!, longitude: longitude!)
            
            let user = User(name: name!, contactNo: contactNo!, dob: dob!, nationality: nationality!, language: speakingLanguage!, gender: gender!, emailAddr: email!, institution: nil, bio: bio!, location: location, occupation: nil, image: UIImage())
            return user
            }
        }
        catch let error as NSError{
            print("No User has logged in currently. \(error), \(error.userInfo)")
           
        }
        return nil
    }
    func retrieveProfileImage(userImageName:String) -> UIImage{
        var profileImage:UIImage?
        let storageRef = Storage.storage().reference(withPath: "images/\(userImageName).jpg")
        storageRef.getData(maxSize: 4 * 1024 * 1024, completion: { data,error in
            if let error = error {
                print("Error retrieving Image: \(error.localizedDescription)")
                
            }
            else{
                if let data = data {
                    profileImage = UIImage(data: data)
                }
                
            }
        })
        return profileImage!
    }
}
