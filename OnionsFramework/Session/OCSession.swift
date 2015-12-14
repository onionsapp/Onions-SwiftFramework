//
//  OCSession.swift
//  OnionsFramework
//
//  Created by Benjamin Gordon on 12/14/15.
//  Copyright © 2015 subvertllc. All rights reserved.
//

import Foundation
import Parse

class OCSession: NSObject {
    // MARK: - Properties
    static var allOnions : [OCOnion] = []
    static var username : String = ""
    static let maxTitleCharacterCount : Int = 30
    static let maxInfoCharacterCount : Int = 2500
    
    // MARK: - Initialize
    static func initializeOnions(appId: String, clientKey: String) -> Void {
        OCOnion.registerSubclass()
        Parse.setApplicationId(appId, clientKey: clientKey)
    }
    
    // MARK: - Login
    static func login(username: String, password: String, completion: SuccessClosure) -> Void {
        let stretchedUsername = OCSecurity.stretchedCredential(username)
        let stretchedPassword = OCSecurity.stretchedCredential(password + username)
        
        PFUser.logInWithUsernameInBackground(stretchedUsername, password: stretchedPassword, block: { (user, error) in
            self.username = username
            OCSecurity.setAccountEncryptionKey(password)
            completion(success: user != nil)
        })
    }
    
    // MARK: - Logout
    static func logout(completion: SuccessClosure) -> Void {
        // Drop all data
        for onion in self.allOnions {
            onion.dropData()
        }
        self.allOnions = []
        
        // Reset encryption key
        self.username = ""
        OCSecurity.setAccountEncryptionKey(nil)
        
        // Logout user
        PFUser.logOut()
        
        // Run completion
        completion(success: true)
    }
    
    // MARK: - Delete Account
    static func deleteAccount(completion: SuccessClosure) -> Void {
        PFObject.deleteAllInBackground(self.allOnions, block: { oSuccess, oError in
            if (!oSuccess) {
                print("OCSession->deleteAccount() - could not delete all onions tied to account. Proceeding to user.")
            }
            
            PFUser.currentUser()?.deleteInBackgroundWithBlock({ aSuccess, aError in
                if (!aSuccess) {
                    print("OCSession->deleteAccount() - could not delete user.")
                }
                
                completion(success: aSuccess && oSuccess)
            })
        })
    }
    
    // MARK: - Register Account
    static func registerNewAccount(username: String, password: String, completion: SuccessClosure) -> Void {
        let stretchedUsername = OCSecurity.stretchedCredential(username)
        let stretchedPassword = OCSecurity.stretchedCredential(password + username)
        
        let user = PFUser()
        user.username = stretchedUsername
        user.password = stretchedPassword
        user.saveInBackgroundWithBlock({ success, error in
            self.username = username
            OCSecurity.setAccountEncryptionKey(password)
            completion(success: success)
        })
    }
    
    // MARK: - Onions
    static func loadOnions(completion: SuccessClosure) -> Void {
        if let user = PFUser.currentUser() {
            if let userId = user.objectId {
                let query = OCOnion.query()
                query?.whereKey("userId", equalTo: userId).orderByAscending("createdAt")
                query?.findObjectsInBackgroundWithBlock( { objects, error in
                    // Check error
                    if (error != nil) {
                        print("OCSession->loadOnions() failed while retrieving onions from the server.")
                        completion(success: false)
                        return
                    }
                    
                    // Assign allOnions if it exists
                    if let onions = objects as? [OCOnion] {
                        self.allOnions = onions
                        completion(success: true)
                        return
                    }
                })
            }
        }
        
        // Something failed
        print("OCSession->loadOnions() failed - no current user.")
        completion(success: false)
    }
    
    static func decryptOnions(completion: SuccessClosure) -> Void {
        if let _ = PFUser.currentUser() {
            // Decrypt each onion, and determine if any have failed
            var hasFailed = false
            for onion in self.allOnions {
                if (!onion.decrypt()) {
                    hasFailed = true
                }
            }
            
            completion(success: !hasFailed)
        }
        
        // Something failed
        print("OCSession->decryptOnions() failed - no current user.")
        completion(success: false)
    }
    
    static func createOnion(title: String?, info: String?, completion: SuccessClosure) -> Void {
        if let oTitle = title, oInfo = info {
            let onion = OCOnion()
            onion.onionTitle = oTitle
            onion.onionInfo = oInfo
            
            onion.saveOnion({ success in
                if (success) {
                    self.allOnions.append(onion)
                } else {
                    print("OCSession->createOnion() failed - saving onion failed.")
                }
                
                completion(success: success)
            })
        }
        
        // Failed
        print("OCSession->createOnion() failed - title or info were blank")
        completion(success: false)
    }
    
    static func deleteOnion(atIndex: Int, completion: SuccessClosure) -> Void {
        if (self.allOnions.count > atIndex || atIndex < 0) {
            print("OCSession->deleteOnion() failed - index was not an accurate value.")
            completion(success: false)
            return
        }
        
        let onion = self.allOnions[atIndex]
        onion.deleteInBackgroundWithBlock({ success, error in
            if (success) {
                self.allOnions.removeAtIndex(atIndex)
            } else {
                print("OCSession->deleteOnion() failed - could not delete onion from server.")
            }
            
            completion(success: success)
        })
    }
}
