//
//  TranslationController.swift
//  MainAffinity
//
//  Created by Mahshukurrahman on 7/2/22.
//

import Foundation

import UIKit

class TranslationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
//        let url = URL(string: "https://translation.googleapis.com/language/translate/v2/languages")
//        let api_key:String = "AIzaSyCmwEeBh2PW8fRFiapGS47X1mge4S1IlSA"
//
//        var request = URLRequest(url: url!)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = [ "key":api_key, "target":"en"]
//        let task = URLSession.shared.dataTask(with: request!) { d,response,error in
//            if let response = response as? HTTPURLResponse{
//                print(response.statusCode)
//
//            }
//            if let d = d {
//                    if let lang = try? JSONDecoder().decode([Languages].self, from: d) { //
//                    print(lang)
//                }
//                else{
//                    print("Invalid error")
//                }
//            }
//            else if let error = error {
//                print("Error returning response \(error.localizedDescription)")
//            }
//        }
//        task.resume()
//        let postData = NSMutableData(data: "q=Hello, world!".data(using: String.Encoding.utf8)!)
//        postData.append("&target=es".data(using: String.Encoding.utf8)!)
//        postData.append("&source=en".data(using: String.Encoding.utf8)!)
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://google-translate1.p.rapidapi.com/language/translate/v2")! as URL,
//                                                cachePolicy: .useProtocolCachePolicy,
//                                            timeoutInterval: 10.0)
//
//
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print(error?.localizedDescription)
//            } else {
//                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
//            }
//        })
//
//        dataTask.resume()
        translateText(sourceLanaguageCode: "en", targetLanguageCode: "ar", translateText: "hello , world")
        //getAllTranslationLanguages()
       
        
//        if let htmldata = htmlString.dataUsingEncoding(NSUTF8StringEncoding), let attributedString = try? NSAttributedString(data: htmldata, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
//            let finalString = attributedString.string
//            print(finalString)
//            //output: test北京的test
//        }
    }
    func getAllTranslationLanguages() -> [Languages]{ //return all languages supported by Translate API
        var languageList : [Languages] = []
        let api_key = "AIzaSyCmwEeBh2PW8fRFiapGS47X1mge4S1IlSA"
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2/languages?key=\(api_key)&target=en")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        //request.allHTTPHeaderFields = [ "key":api_key, "target":"en"]
        let task = URLSession.shared.dataTask(with: request) { data,response,error in
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
                        print(languageOption)
                        languageList.append(languageOption)
                    }
                    
                }
            }
            else if (error != nil) {
                print("Error returning response \(error!.localizedDescription)")
            }
        }
        task.resume()
        return languageList
    }
    func translateText(sourceLanaguageCode:String,targetLanguageCode:String,translateText:String){
        let api_key = "AIzaSyCmwEeBh2PW8fRFiapGS47X1mge4S1IlSA"
       
        let postData = NSMutableData(data: "q=\(translateText)".data(using: String.Encoding.utf8)!)
        postData.append("&target=\(sourceLanaguageCode)".data(using: String.Encoding.utf8)!)
        postData.append("&source=\(targetLanguageCode ?? "en")".data(using: String.Encoding.utf8)!)
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
                let httpResponse = response as! HTTPURLResponse
                do{
 
                    //let output = String(data: data!, encoding: .utf8)
                    var output : translatedData?
                    output = try! JSONDecoder().decode(translatedData.self, from: data!)
//                   let output = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    print(String(data: output!.data.translations[0].translatedText as! Data, encoding: .utf8))
                    print(String(output!.data.translations[0].translatedText))
                    
                    
                }
                catch{
                    
                    print("Error translation text : \(error.localizedDescription)")
                }
            }
        })
        task.resume()
    }

}
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

struct translatedData : Codable{
    let data:translationList
}
struct translationList: Codable{
    let translations:[Output]
}
struct Output : Codable{
    let translatedText:String
}
