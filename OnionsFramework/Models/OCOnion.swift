//
//  OCOnion.swift
//  OnionsFramework
//
//  Created by Benjamin Gordon on 12/14/15.
//  Copyright © 2015 subvertllc. All rights reserved.
//

import Parse

class OCOnion: PFObject, PFSubclassing {
    // MARK: - Properties
    @NSManaged var onionTitle : String
    @NSManaged var onionInfo : String
    @NSManaged var iterations : Int
    @NSManaged var userId : String
    @NSManaged  var onionVersion : Int
    
    
    // MARK: - Initialization
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "OCOnion"
    }
    
    
    // MARK: - Data
    func dropData() -> Void {
        self.onionTitle = ""
        self.onionInfo = ""
        self.userId = ""
    }
    
    func decrypt() -> Bool {
        if let t = OCSecurity.decrypt(self.onionTitle), let i = OCSecurity.decrypt(self.onionInfo) {
            self.onionTitle = t
            self.onionInfo = i
            return true
        }
        
        return false
    }
    
    func saveOnion(completion: SuccessClosure) -> Void {
        if let user = PFUser.currentUser() {
            let origTitle = self.onionTitle
            let origInfo = self.onionInfo
            if let encryptedTitle = OCSecurity.encrypt(origTitle), let encryptedInfo = OCSecurity.encrypt(origInfo) {
                self.onionTitle = encryptedTitle
                self.onionInfo = encryptedInfo
                self.iterations = OCSecurity.DefaultIterations
                self.onionVersion = OCSecurity.Version
                self.userId = user.objectId!
                
                saveInBackgroundWithBlock({ success, error in
                    if (!success) {
                        print("OCOnion->saveOnion() failed saving to the server.")
                    }
                    
                    self.onionTitle = origTitle
                    self.onionInfo = origInfo
                    completion(success: success)
                })
                return
            }
            
            print("OCOnion->saveOnion() failed while encrypting data.")
            completion(success: false)
        }
        
        print("OCOnion->saveOnion() failed because the current user was nil.")
        completion(success: false)
    }
}
