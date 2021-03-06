//
//  DatabaseManager.swift
//  MainAffinity
//
//  Created by Jordan Kwek on 3/2/22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {

    /// Shared instance of class
    public static let shared = DatabaseManager()

    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

}

// Account Management
extension DatabaseManager {

    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {

        /*
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }

            completion(true)
        })
         */
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
                    guard snapshot.value as? [String: Any] != nil else {
                        completion(false)
                        return
                    }

                    completion(true)
                })


    }
    
    /*
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observ
            
            completion(true)
        })
    }
     */
    
    // Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { [weak self] error, _ in

            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }

            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)

                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
                else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]

                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
            })
        })
    }
    // Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
}

extension DatabaseManager {
    
    //Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool)->Void){
        
    
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                        return
                }
         
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_), .linkPreview(_):
                break
            }
            
            let newConversationData: [String: Any] = [
                "id": "conversation_\(firstMessage.messageId)",
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: {
                    error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            
            else{
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: {
                    error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
    }

                    /*
                    

                    

                    let conversationId = "conversation_\(firstMessage.messageId)"

                    let newConversationData: [String: Any] = [
                        "id": "conversation_\(firstMessage.messageId)",
                        "other_user_email": otherUserEmail,
                        //"name": name,
                        "latest_message": [
                            "date": dateString,
                            "message": message,
                            "is_read": false
                        ]
                    ]

                    /*
                    let recipient_newConversationData: [String: Any] = [
                        "id": conversationId,
                        "other_user_email": safeEmail,
                        "name": currentNamme,
                        "latest_message": [
                            "date": dateString,
                            "message": message,
                            "is_read": false
                        ]
                    ]
                     */
                    // Update recipient conversaiton entry
                    /*
                    self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                        if var conversatoins = snapshot.value as? [[String: Any]] {
                            // append
                            conversatoins.append(recipient_newConversationData)
                            self?.database.child("\(otherUserEmail)/conversations").setValue(conversatoins)
                        }
                        else {
                            // create
                            self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                        }
                    })
                     */

                    // Update current user conversation entry
                    if var conversations = userNode["conversations"] as? [[String: Any]] {
                        // conversation array exists for current user
                        
                        conversations.append(newConversationData)
                        userNode["conversations"] = conversations
                        ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            self?.finishCreatingConversation(
                                                             conversationID: conversationId,
                                                             firstMessage: firstMessage,
                                                            completion: completion)
                        })
                    }
                    
                    else {
                        // conversation array does NOT exist
                        // create it
                        userNode["conversations"] = [
                            newConversationData
                        ]

                        ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            self?.finishCreatingConversation(
                                                             conversationID: conversationId,
                                                             firstMessage: firstMessage,
                                                             completion: completion)
                        })
                    }
                })
            }
    */
    
     
     private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool)-> Void)
    {
        //            "id": String,
        //            "type": text, photo, video,
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true/false,
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)

        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_), .linkPreview(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false
            
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
     
    
    
    
    //Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void)
    {
        
    }
    
    
    //Get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void)
    {
        
    }
    
    //Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Bool)-> Void){
        
    }
}

struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
