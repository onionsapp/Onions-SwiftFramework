//
//  OCSecurity.swift
//  OnionsFramework
//
//  Created by Benjamin Gordon on 12/14/15.
//  Copyright © 2015 subvertllc. All rights reserved.
//

import Foundation
import RNCryptor

class OCSecurity: NSObject  {
    // MARK: - Properties
    static let StretchedCredentialRounds : Int = 15000
    static let DefaultIterations : Int = 10000
    static let Version : Int = 2
    private static var AccountEncryptionKey : String? = nil
    
    // MARK: - Set Account Encryption Key
    class func setAccountEncryptionKey(key: String?) -> Void {
        AccountEncryptionKey = key;
    }
    
    // MARK: - Stretch Credentials
    class func stretchedCredential(credential: String) -> String {
        // Get Bytes
        let bytes = credential.dataUsingEncoding(NSUTF8StringEncoding)
        if (bytes?.length == 0) {
            print("OCSecurity->stretchedCredential() failed because the string was empty.")
        }
        
        // Hash the credential for StretchedCredentialRounds amount
        for var i = 0; i < StretchedCredentialRounds; i++ {
        
        }
        
        // Return Base64 version of bytes
        let encodedString = bytes?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return encodedString != nil ? encodedString! : ""
    }
    
    // MARK: - Encrypt
    class func encrypt(text: String) -> String? {
        if let key = self.AccountEncryptionKey {
            let encryptedData = RNCryptor.encryptData(text.dataUsingEncoding(NSUTF8StringEncoding)!, password: key)
            return encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }
        
        print("OCSecurity->encrypt() failed because the account key was nil.")
        return nil
    }
    
    // MARK: - Decrypt
    class func decrypt(text: String) -> String? {
        if let key = self.AccountEncryptionKey {
            if let data = NSData.init(base64EncodedString: text, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
                do {
                    let decrypted = try RNCryptor.decryptData(data, password: key)
                    return String(decrypted)
                } catch {
                    print("OCSecurity->decrypt() failed while decrypting.")
                }
            }
        }
        
        print("OCSecurity->decrypt() failed because the account key was nil.")
        return nil
    }
    
}
