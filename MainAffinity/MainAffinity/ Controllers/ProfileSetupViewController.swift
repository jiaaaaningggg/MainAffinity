//
//  ProfileSetupViewController.swift
//  Affinity
//
//  Created by Mahshukurrahman on 20/1/22.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseStorage
import FirebaseFirestore
class ProfileSetupViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate{
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    //data passed from SignUpVC
    var userEmail = String()
    var userName = String()
    var referenceDocId = String()
    let userController = UserController()
    var countryList :[String] = []
    var bioRecommendations:String? //dynamiclly built later
    let imagePlaceholder :UIImage = UIImage(systemName: "person.circle.fill")!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var dobFld: UITextField!
    
    @IBOutlet weak var languageFld: UITextField!
    @IBOutlet weak var mobileFld: UITextField!
    @IBOutlet weak var nationalityFld: UITextField!
    @IBOutlet weak var GenderFld: UITextField!
    @IBOutlet weak var ageFld: UITextField!
    @IBOutlet weak var BioFld: UITextView!
    @IBOutlet weak var NameFld: UITextField!
    
    @IBOutlet weak var occupationFld: UITextField!
    @IBOutlet weak var institutionFld: UITextField!
    //Validation text fields
    
    @IBOutlet weak var NameError: UILabel!
    @IBOutlet weak var MobileError: UILabel!
    @IBOutlet weak var DOBError: UILabel!
    @IBOutlet weak var NationalityError: UILabel!
    @IBOutlet weak var BioError: UILabel!
    @IBOutlet weak var LangError: UILabel!
    @IBOutlet weak var ImageError: UILabel!
    @IBOutlet weak var GenderError: UILabel!
    
    private var datePickerFld:UIDatePicker?
    private var countryPicker = UIPickerView()
    private var genderPickerFld = UIPickerView()
    
    var hasValidImage:Bool = true
//    var hasValidImage:Bool = false
    var hasValidName : Bool = false
    var hasValidMobileNo : Bool = false
    var hasValidDob : Bool = false
    var hasValidGender:Bool = false
    var hasValidNationality:Bool = false
    var hasValidLanguage:Bool = false
    var hasValidBio:Bool = false
    
    let endpoint:String = "https://restcountries.com/v2/all"

    @IBOutlet weak var CreateProfileBtnOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //autofill user name
        NameFld.text = userName
        //set placeholder profile avatar
        appDelegate?.profileImage = imagePlaceholder
        //configure tapping events to hide keyboard
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tap)
        //disable submit button
        CreateProfileBtnOutlet.isEnabled = false
        // hide validation errors upon UIView load
        hideAllErrorMessages()
        BioFld.delegate = self
        
        //set tags for picker views
        genderPickerFld.tag = 2
        countryPicker.tag = 3
        
        //configure avatar imageView constraints
        profileImageView.layer.masksToBounds = true
    
        profileImageView.layer.cornerRadius =  profileImageView.bounds.width/2
        if (appDelegate?.profileImage != nil){
            profileImageView.image = appDelegate?.profileImage!
        }
       
        
        //set pickerview for Nationality Field
        countryPicker.delegate = self
        countryPicker.dataSource = self
        
        nationalityFld.inputView = countryPicker

        datePickerFld = UIDatePicker()
        datePickerFld?.datePickerMode = .date
        datePickerFld?.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        
         
        
        let tapGesture = UIGestureRecognizer(target: self, action:#selector (self.viewTapped(gestureRecognizer:))) //for interactions when only touch is made with no date input
        view.addGestureRecognizer(tapGesture)
        dobFld.inputView = datePickerFld
        
        //set pickerview for Gender
        genderPickerFld.delegate = self
        genderPickerFld.dataSource = self
        GenderFld.inputView = genderPickerFld
        
        //Set Placeholder text for Bio Input Field
        bioRecommendations = "Share with us: \nYour hobbies \nYour interests \nYour background"
        BioFld.textColor = UIColor.lightGray
        BioFld.textAlignment = .left
        BioFld.text = bioRecommendations
        BioFld.font = .systemFont(ofSize: 17.0)
        
        //intitialise country list from API response here
        URLSession.shared.dataTask(with: URL(string:endpoint)!, completionHandler: {data,response,error in
            guard let data = data, error == nil  else{
                print("error in API call")
                return
            }
            var result:[Response]?
            do{
                result = try JSONDecoder().decode([Response].self, from: data)
            }
            catch{
                print("Error: \(error.localizedDescription)")
            }
            guard let json = result else{
                return
            }
            var indexOfCountry:Int?
            for country in json{
                let asianCountries:[String] = ["Brunei Darussalam", "Cambodia","Indonesia","Laos", "Malaysia","Myanmar", " Philippines", "Singapore", "Thailand","Timor-Leste","Vietnam"]
                
                indexOfCountry = asianCountries.firstIndex(of: String(country.name)) ?? 0
                if (indexOfCountry! == 0){ //for non-asian countries
                 self.countryList.append(String(country.name))
                    
                }
                else{
                    for c in asianCountries{ // insert asian countries first for convenience
                        if(country.name == c){
                            self.countryList.insert(String(country.name), at: indexOfCountry! - 1)
                        }
                    }
                    
                }
            }
        }).resume()
        
    }
    func hideAllErrorMessages(){
        BioError.isHidden = true
        DOBError.isHidden = true
        LangError.isHidden = true
        MobileError.isHidden = true
        NationalityError.isHidden = true
        ImageError.isHidden = true
        GenderError.isHidden = true
        NameError.isHidden = true
    }
    //functions to throw validation messages
    func showProfileImageError(){
        if(profileImageView.image == imagePlaceholder){
            ImageError.isHidden = false
            hasValidImage = false //re-assign if user edits and deletes to bypass validation
        }
        else{
            ImageError.isHidden = true
            hasValidImage = true
        }
    }
    func showMobileFldError(){
        if(!hasValidMobileNo){
            MobileError.isHidden = false
        }
        
    }
    func showDobFldError(){
        if(!hasValidDob){
            DOBError.isHidden = false
        }
        
    }
    func showNationalityFldError(){
        if(!hasValidNationality){
            NationalityError.isHidden = false
        }
        
    }
    func showLanguageFldError(){
        if(!hasValidLanguage){
            LangError.isHidden = false
        }
        
    }
    func showNameFldError(){
        if(!hasValidName){
            NameError.isHidden = false
        }
    }
    func showGenderFldError(){
        if(!hasValidGender){
            GenderError.isHidden = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if (appDelegate?.profileImage != nil){
            profileImageView.image = appDelegate?.profileImage!
            
        }
        if (appDelegate?.profileImage != imagePlaceholder){ //dynamically change text to 'edit' when image is uploaded
            uploadBtnOutlet.setTitle("Edit Image", for: .normal)
            if !ImageError.isHidden{
                ImageError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var uploadBtnOutlet: UIButton!
    
    @IBAction func uploadImageBtn(_ sender: Any) {
        let uploadvc = self.storyboard?.instantiateViewController(withIdentifier: "ImageUpload") as? UIViewController
        uploadvc!.modalPresentationStyle = .fullScreen
        self.present(uploadvc!, animated: true, completion: nil)
    }
 
   
    

   //data validation functions
    @IBAction func dobTextChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD/MM/YYYY"
        let requiredWarning:String = DOBError.text!
        let underageWarning:String = "Age requirement is 18 & above"
        let incorrectFormatWarning : String = "Please enter in DD/MM/YYYY"
        
        if let dob = dateFormatter.date(from: dobFld.text!){ //check if date is in correct format for typed inputs
            if(Int(ageFld.text!) ?? 0 < 18){
                DOBError.text = underageWarning
                DOBError.isHidden = false //confirm the presence of validation msg
                hasValidDob = false //re-assign if user edits and deletes to bypass validation
            }
            else{ //all well
                DOBError.isHidden = true
                hasValidDob = true
            }
        }
        else if ageFld.text!.isEmpty{
            DOBError.text = requiredWarning
            DOBError.isHidden = false
           
        }
        
        else{
            DOBError.text = incorrectFormatWarning
            DOBError.isHidden = false
            hasValidDob = false //re-assign if user edits and deletes to bypass validation
        }
        checkToEnableButton()
    }
    
    @IBAction func nameEditingEnded(_ sender: Any) {
        
        if ((NameFld.text ?? "" ).isEmpty){
            hasValidName = false
            NameFld.isHidden = false
        }
        else{//all well

            hasValidName = true
            NameError.isHidden = true
        }
        checkToEnableButton()
    }
    
    @IBAction func genderEditingEnded(_ sender: Any) {
        if(GenderFld.text! == "Male" || GenderFld.text! == "Female"){
            hasValidGender = true
            GenderError.isHidden = true
        }
        checkToEnableButton()
    }
    @IBAction func mobileNoEditingEnded(_ sender: Any) {
        let invalidFormatMessage = "Invalid Phone Number Format"
        let mobileNo = mobileFld.text ?? ""
        let requiredMessage = MobileError.text //get default value
        if(mobileNo.isValidPhoneNumber()){
            MobileError.isHidden = true
            hasValidMobileNo = true
        }
        else if(mobileNo.isEmpty){
            hasValidMobileNo = false
            MobileError.isHidden = false
            MobileError.text = requiredMessage
        }
        else{
            hasValidMobileNo = false
            MobileError.isHidden = false
            MobileError.text = invalidFormatMessage
        }
        checkToEnableButton()
    }
    
    
    @IBAction func NationalityEnded(_ sender: Any) {
        
        if ((nationalityFld.text ?? "" ).isEmpty){
            
            NationalityError.isHidden = false
        }
        else {
            hasValidNationality = true
            NationalityError.isHidden = true
        }
            
        checkToEnableButton()
        
    }
    
    @IBAction func LanguageEnded(_ sender: Any) {
        
        if ((languageFld.text ?? "" ).isEmpty){
            hasValidLanguage = false //re-assign if user edits and deletes to bypass validation
            LangError.isHidden = false
        }
        else{

            hasValidLanguage = true
            LangError.isHidden = true
        }
        checkToEnableButton()
        
        
    }
    
    //text view delegate functions
    func textViewDidChange(_ textView: UITextView) {
        BioFld.clearsOnInsertion = true
        showDobFldError()
        showLanguageFldError()
        showNationalityFldError()
        
        showProfileImageError()
        showMobileFldError()
        showNameFldError()
        showGenderFldError()
        
    }
    func checkToEnableButton(){
        //if all fields  are valid
        let validProfile : Bool = hasValidBio &&
        hasValidDob && hasValidName && hasValidImage && hasValidGender
        && hasValidNationality && hasValidLanguage && hasValidMobileNo
        if(validProfile){
            CreateProfileBtnOutlet.isEnabled = true
        }
        
    }
    
    @IBAction func createProfileBtn(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD/MM/YYYY"
        let newLocation = CLLocation()
        
        
        let newUser = User(name: NameFld.text!, contactNo: mobileFld.text!, dob: dateFormatter.date(from:dobFld.text!)! , nationality:nationalityFld.text!, language: languageFld.text!, gender: GenderFld.text!, emailAddr: userEmail, institution: institutionFld.text ?? nil, bio: BioFld.text!, location: newLocation, occupation: occupationFld.text ?? nil,image: profileImageView.image!)
        //1. add User profile to coredata
        userController.addNewUser(newUser: newUser)
        //2.add User profile to firebase
        let db = Firestore.firestore()
    
        
        let values : Dictionary<String,Any> = ["name":newUser.name,"contactNo":newUser.contactNo!,"dob":newUser.dateOfBirth!.timeIntervalSince1970,"Nationality":newUser.nationality!,"Language":newUser.speakingLanguage!,"Gender":newUser.gender!,"bio":newUser.bio!,"institution":newUser.institution ?? nil,"occupation":newUser.occupation ?? nil,"isOnline":true,"email":newUser.email,"age":newUser.age!,"currentLatitude":0.00,"currentLongitude":0.00]
        //upload image to firebase storage
        db.collection("users").document(referenceDocId).setData(values)
        let storageRef = Storage.storage().reference(withPath: "images/\(newUser.name).jpg")
        
        guard let imageData = profileImageView.image?.jpegData(compressionQuality: 1.0) else{ return }
        let metadata = StorageMetadata.init()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData,metadata: metadata){ (downloadMetaData, error) in
            if (error != nil){
                print("Error uploading Profile Image : \(error!.localizedDescription)")
            }
        }
        
        //segue to tabbarcontroller
        
        let vc = storyboard?.instantiateInitialViewController()
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        
    }
    func retrieveProfileImage(userImageName:String) -> UIImage{
        var profileImage:UIImage?
        let storageRef = Storage.storage().reference(withPath: "images/\(userImageName).jpg")
        storageRef.getData(maxSize: 4 * 1024 * 1024, completion: { data,error in
            if let error = error {
                print("Error retrieving Image: \(error.localizedDescription)")
                
            }
            else{
                profileImage = UIImage(data: data!)!
            }
        })
        return profileImage!
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        BioFld.text = nil
        BioFld.textColor = UIColor.black
       
        
    }
    
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if BioFld.text.isEmpty {
            BioFld.text = bioRecommendations!
            BioFld.textColor = UIColor.lightGray
            BioError.isHidden = false
            hasValidBio = false //re-assign if user edits and deletes to bypass validation
        }
        else{
            hasValidBio = true
            BioError.isHidden = true
            
        }
        //throw validation errors
        showDobFldError()
        showNameFldError()
        showMobileFldError()
        showGenderFldError()
        showNationalityFldError()
        showProfileImageError()
        showLanguageFldError()
        
        checkToEnableButton()
    }
    
    //country picker,gender picker delegate functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 2){
            return appDelegate!.genderList.count
        }
        else if (pickerView.tag == 3){
            return self.countryList.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 2){
            return appDelegate!.genderList[row]
        }
        else if (pickerView.tag == 3){
        return self.countryList[row]
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 2){
            GenderFld.text = appDelegate!.genderList[row]
        
        }
        else if (pickerView.tag == 3){
            nationalityFld.text = countryList[row]
        }
    }
    
    
    //touch gesture recognizer methods
    @objc func dateChanged(datePicker:UIDatePicker){ //event listener for selecting a Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        dobFld.text = dateFormatter.string(from:datePicker.date)
        //Calculate age
        let calendar = Calendar.current
    
        let birthdateComponent = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
        let now = calendar.dateComponents([.year, .month, .day], from: Date())
        let ageComponents = calendar.dateComponents([.year], from: birthdateComponent, to: now)
        let age = ageComponents.year!
        ageFld.text = String(age)
    }
    @objc func viewTapped(gestureRecognizer : UIGestureRecognizer){
        self.view.endEditing(true)
        
    }
    @objc func closeKeyboard(){
        
        self.view.endEditing(true)
    }
    struct Response:Codable{
        var name:String
    }
}
extension UITextField{
    func setBottomBorderOnlyWith(color: CGColor) {
            self.borderStyle = .none
            self.layer.masksToBounds = false
            self.layer.shadowColor = color
            self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 0.0
        }
    
}
extension String{
    func isValidPhoneNumber() -> Bool {
          let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"

          let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
          return phoneCheck.evaluate(with: self)
      }
}

