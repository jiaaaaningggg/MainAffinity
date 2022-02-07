//
//  ImageViewController.swift
//  Affinity
//
//  Created by Mahshukurrahman on 17/1/22.
//

import Foundation
import UIKit
import CoreLocation

class ImageViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    @IBOutlet weak var selectedImageView: UIImageView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    }
   
    @IBAction func cancelUploadBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImageBtn(_ sender: Any) {
        if (selectedImageView.image != nil){
            appDelegate.profileImage = selectedImageView.image!
            self.dismiss(animated: true, completion: nil)
        }
        else{
            let alert:UIAlertController = UIAlertController(title: "Invalid Profile Image", message: "Please upload a proper image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:  { _ in
                
            }))
            present(alert, animated: true, completion: nil)
        }
        
    }
    func chooseImageSource(source:String) -> UIImagePickerController{ //func for setting ImagePicker properties based on source
        let image = UIImagePickerController()
        image.delegate = self
        image.allowsEditing = true

        switch (source){
        case "Camera":
            image.sourceType = .camera
        case "Photo Library":
            image.sourceType = .photoLibrary
        default:
            image.sourceType = .photoLibrary
        }
        return image
    }
    @IBAction func uploadFromLibrary(_ sender: Any) { // when user chooses photo library
        let image =  chooseImageSource(source: "Photo Library")
        self.present(image, animated: true, completion: nil)
        
    
    }
        

    @IBAction func uploadFromCamera(_ sender: Any) { //when user chooses camera
        let image =  chooseImageSource(source: "Camera")
        self.present(image, animated: true, completion: nil)
        
    }
    //func trigger
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageView.image = selectedImage
        }//retrieve selected image from the array
        else if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageView.image = selectedImage
        }
        else{
            showImageUploadErrorAlert()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
 
    func showImageUploadErrorAlert(){
        let errorMessage:String = "Error uploading Image. Please try again." //set alert messsage
        let alertTitle:String = "Image Uploading Error"
        let alert = UIAlertController(title: alertTitle, message:errorMessage, preferredStyle: .alert)
        
        alert.addAction( UIAlertAction(title: "Try Again", style: .default, handler: {
            _ in  self.dismiss(animated: true, completion: nil) //alert button
        }))
        self.present(alert, animated: true, completion: nil)//show the alert
        
    }

}
