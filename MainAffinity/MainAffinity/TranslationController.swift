//
//  TranslationController.swift
//  MainAffinity
//
//  Created by Mahshukurrahman on 7/2/22.
//

import Foundation
import UIKit

class TranslationController {
    let api_key = "AIzaSyCmwEeBh2PW8fRFiapGS47X1mge4S1IlSA"
  
    func getAllTranslationLanguages() -> Void{ //return all languages supported by Translate API
        var languageList : [Languages] = []
        
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2/languages?key=\(api_key)&target=en")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request) { data,response,error in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)

            }
            
            if (data != nil) {
                var result:languageData?
                do{
                    result = try JSONDecoder().decode(languageData.self, from: data!)
                   
                }
                
                catch{
                    print("Failed to fetch languages \(error)")
                }
                if (result != nil) {
                    for languageOption in result!.data.languages{
                        appDelegate.supportedLanguageList.append(languageOption)
                        
                    }
                    
                }
            }
            else if (error != nil) {
                print("Error returning response \(error!.localizedDescription)")
            }
        }
        task.resume()
        
    }
    func translateText(sourceLanaguageCode:String,targetLanguageCode:String,translateText:String) -> Void{
        var textOutput :String? //save the final translated output
        
        let postData = NSMutableData(data: "q=\(translateText)".data(using: String.Encoding.utf8)!) //query parameters for POST request
        postData.append("&target=\(targetLanguageCode)".data(using: String.Encoding.utf8)!)
        postData.append("&source=\(sourceLanaguageCode )".data(using: String.Encoding.utf8)!)
        postData.append("&format=text".data(using: String.Encoding.utf8)!)
        postData.append("&key=\(api_key)".data(using: String.Encoding.utf8)!)
         
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = postData as Data

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data,response,error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else if data != nil{
                
                do{
                    var output : translatedData?
                    output = try! JSONDecoder().decode(translatedData.self, from: data!)
                    textOutput = String(output!.data.translations[0].translatedText)
                    
                    
                }
                catch{
                    print(response as! HTTPURLResponse)
                    print("Error translation text : \(error.localizedDescription)")
                }
            }
        })
        task.resume()
        
    }
    
}
//structs for Language API --> return all languages
struct languageData:Codable{
    let data:langList
}
struct langList:Codable{
    let languages:[Languages]
}
struct Languages:Codable{
let language:String
let name:String
}
//struct for translate API --> return the translated text
struct translatedData : Codable{
    let data:translationList
}
struct translationList: Codable{
    let translations:[Output]
}
struct Output : Codable{
    let translatedText:String
}

//struct for detect API --> return the detected language


