//
//  UserController.swift
//  Affinity
//
//  Created by Mahshukurrahman on 30/1/22.
//

import Foundation
import CoreData
import UIKit

class UserController {
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
//        user.setValue(newUser.currentLongitude, forKey: "currentLongitude")
//        user.setValue(newUser.currentLongitude, forKey: "currentLatitude")
        
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
   
}
