//
//  SwipingViewController.swift
//  MainAffinity
//
//  Created by Mahshukurrahman on 6/2/22.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class SwipingViewController : UIViewController{
    private var datingList:[User] = []
    private let userController = UserController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = userController.getUser()
        if let user = currentUser {
            let minimumAge:Int = user.minAgeFilter
            let maximumAge:Int = user.maxAgeFilter
            let email = user.email
            let currentLocation = CLLocation.init(latitude: user.currentLatitude!, longitude: user.currentLongitude!)
            var preferredGender :String?
            switch (user.gender){
            case "M":
                preferredGender = "F"
            case "F":
                preferredGender = "M"
            default:
                preferredGender = "F"
            }
            generateDates(minimumAge: minimumAge, maximumAge: maximumAge, preferredGender: preferredGender!, currentLocation: currentLocation,email:email) //generate list of Dating profiles for the User
        }
    }
    func generateDates(minimumAge:Int,maximumAge:Int,preferredGender:String,currentLocation:CLLocation,email:String)-> Void{
        
        let db = Firestore.firestore() // store the Firebase Instance
        
        let usersRef = db.collection("users") //specify the collection
        //filter the dating profiles according to userpreferences
        usersRef.whereField("Gender", isEqualTo: preferredGender)
        usersRef.whereField("age", isLessThanOrEqualTo: maximumAge).whereField("age", isGreaterThanOrEqualTo: minimumAge)
        usersRef.whereField("email", isNotEqualTo:email)
            .getDocuments(){
            (querySnapshot, err) in
                var appDelegate = UIApplication.shared.delegate as! AppDelegate
                
            if let error = err{
                print ("Error fetching date profiles: \(error.localizedDescription)")
            }
            else{
                
                for documents in querySnapshot!.documents{ //loop through each document in the collection
                    var institution :String?
                    var occupation : String?
                    var profileImage : UIImage?
                    let name = documents.value(forKeyPath: "name") as! String
                    let email = documents.value(forKeyPath: "email") as! String
                    let age = documents.value(forKeyPath: "age") as? Int
                    let bio = documents.value(forKeyPath: "bio") as? String
                    let currentLatitude = documents.value(forKeyPath: "currentLatitude") as? Double
                    let currentLongitude = documents.value(forKeyPath: "currentLongitude") as? Double
                    let gender = documents.value(forKeyPath: "Gender") as? String
                    let nationality = documents.value(forKeyPath: "Nationality") as? String
                    let contactNo = documents.value(forKeyPath: "contactNo") as? String
                    let dateOfBirth = Date (timeIntervalSince1970: documents.value(forKeyPath: "dob") as! Double / 1000.0)
                    let speakingLanguage = documents.value(forKeyPath: "Language") as? String
                    if(!(documents.value(forKeyPath: "occupation") as! String).isEmpty){
                        occupation = documents.value(forKeyPath: "occupation") as? String
                    }
                    if(!(documents.value(forKeyPath: "institution") as! String).isEmpty){
                        institution = documents.value(forKeyPath: "institution") as? String
                    }
                    
                   
                    let dateProfile = User(name: name, contactNo: contactNo!, dob: dateOfBirth, nationality: nationality!, language: speakingLanguage!, gender: gender!, emailAddr: email, institution: institution ?? nil, bio: bio, location: CLLocation.init(latitude: currentLatitude!, longitude: currentLongitude!), occupation: occupation ?? nil, image: UIImage())
                    appDelegate.recommendationList.append(dateProfile)
                    self.userController.retrieveProfileImage(userImageName: name)
                }
            }
        }
      
        
    }
}
