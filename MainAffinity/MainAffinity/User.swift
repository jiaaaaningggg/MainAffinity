//
//  User.swift
//  Affinity
//
//  Created by Mahshukurrahman on 18/1/22.
//

import Foundation
import CoreLocation
import UIKit
class User{
    var name : String
    
    var contactNo: String?
    var dateOfBirth :Date?
    var nationality : String?
    var speakingLanguage : String?
    var currentLatitude : Double?
    var currentLongitude : Double?
    var gender : String?
    var image: Data?
    var age:Int?
    var email : String
    var institution : String?
    var isOnline:Bool?
    var lastActiveTime :Date?
    var minAgeFilter : Int
    var maxAgeFilter: Int
    var occupation:String?
    var bio :String?
    
    init(name:String,contactNo:String,dob:Date,nationality:String,language:String,gender:String,emailAddr:String,institution:String?,bio:String?,location:CLLocation,occupation:String?,image:UIImage){
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.contactNo = contactNo.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dateOfBirth = dob
        self.nationality = nationality
        self.speakingLanguage = language
        self.email = emailAddr
        self.institution = institution ?? nil
        self.bio = bio 
        self.isOnline = nil
        self.lastActiveTime = nil
        self.maxAgeFilter = 100
        self.minAgeFilter = 18
        self.occupation = occupation ?? nil
        self.currentLongitude = location.coordinate.longitude
        self.currentLatitude = location.coordinate.latitude
        switch gender{         //1 : Male 0: Female
        case "Male":
            self.gender = "M"
        case "Female":
            self.gender = "F"
        default:
            self.gender = "M"
        }
        //age computation
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        self.age = ageComponents.year! //retrieve year difference from date differences
        //check image format
//        if(image.pngData() != nil){
//            self.image = image.pngData()
//        }
//        else{
//            self.image = image.jpegData(compressionQuality: 1.0)
//        }
        
//        self.image =
//        let assetPath = info[.imageURL] as! NSURL
//        if(assetPath.absoluteString?.hasSuffix("jpeg"))!{
//
//        }
       
    }
}
