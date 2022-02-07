//
//  DatingMapViewController.swift
//  MainAffinity
//
//  Created by Jordan Kwek on 7/2/22.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class DatingMapViewController: UIViewController {
    
    //private var datingList:[Any] = []
    private let userController = UserController()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //datingList = getDatingUsers()
        /*
        var annotationLocations : [Dictionary<<#Key: Hashable#>, Any>]
        for users in datingList{
            var annotationLocations : [String : Any] = [:]
            ["title": users[0], "latitude": users[1], "longitude": users[2]]
            datingList.append(userInfo)
        }
         */
        createAnnotations()
        
        zoomlevel(location: locationLatLong)
    }

    // Specify region and zoom level
    // Set start location
    // Used the coordinates of the middle of Singapore
    let locationLatLong = CLLocation(latitude: 1.356719, longitude: 103.835237)
    
    // CLLocationDistance is the distance measurement in meters
    let distanceSpan: CLLocationDistance = 45000
    
    func zoomlevel(location: CLLocation){
        
        // Create new region for zoom level
        let mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
        
        // Set new map region
        mapView.setRegion(mapCoordinates, animated: true)
    }
    
    var annotationLocations = [
        ["title": "Dr. James A. Dillon Park Frisbee", "latitude": 1.392604, "longitude":103.873258],
        ["title": "Dr. Papi", "latitude": 1.4063169, "longitude":103.912149]
    ]
    
    func createAnnotations(){
        for user in getDatingUsers() {
            //let userData = userInfo(name: user.title, long: user.long , lat: user.lat)
            let annotations = MKPointAnnotation()
            annotations.title = user.name
            
            annotations.coordinate = CLLocationCoordinate2D(latitude: user.lat!, longitude: user.long!)
        
            mapView.addAnnotation(annotations)
        }
    }
     
    
    func getDatingUsers() -> [userInfo]
    {
        var datingUser:[userInfo] = []

        let db = Firestore.firestore() // store the Firebase Instance
        
        //let usersRef = db.collection("users") //specify the collection
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let error = err{
                print ("Error fetching date profiles: \(error.localizedDescription)")
            }
            else{
                for documents in querySnapshot!.documents{ //loop through each document in the collection
                    //var profileImage : UIImage?
                
                    let name = documents.value(forKeyPath: "name") as! String
                    //let email = documents.value(forKeyPath: "email") as! String
                    //let age = documents.value(forKeyPath: "age") as? Int
                    //let bio = documents.value(forKeyPath: "bio") as? String
                    let currentLatitude = documents.value(forKeyPath: "currentLatitude") as? Double
                    let currentLongitude = documents.value(forKeyPath: "currentLongitude") as? Double
                    /*
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
                    profileImage = self.userController.retrieveProfileImage(userImageName: name)
                     */
                    print("\(name)")
                    let userInfo = userInfo(name: name, long: currentLongitude, lat: currentLatitude)
                    datingUser.append(userInfo)
                }
            }
        }
        return datingUser
        
    }
}

struct userInfo{
    var name: String
    var long: Double?
    var lat: Double?
}
