//
//  Authenticator.swift
//  AditiAdmin
//
//  Created by macbook on 23/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CodableFirebase
import UIKit

class Authenticator {
    
    static var shared : Authenticator?
    
    var phoneNumber : String!
    var verificationID : String?
    var verificationCode : String?
    var params = [String:Any]()
    var isSignup = false
    
    init(phoneNumber : String) {
        self.phoneNumber = phoneNumber
    }
    
    func sendCode(completion: @escaping(_ success: Bool) -> Void){
        UIApplication.showLoader()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) {[weak self] (verificationID, error) in
            guard let weakSelf = self else {return}
            if let _ = error {
                UIApplication.showError(message: error?.localizedDescription)
                completion(false)
                return
            }
            weakSelf.verificationID = verificationID
            completion(true)
        }
    }
    
    func signIn(code : String){
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: code)
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let weakSelf = self else{return}
            if let _ = error {
                UIApplication.showError(message: Errors.invalidOtp, delay: 1)
                return
            }else if let uid = authResult?.user.uid {
                if weakSelf.isSignup {
                    weakSelf.saveUserInfo(uid: uid, collection: Constants.getUserCollection())
                }else{
                    Router.login()
                }
            }
        }
    }
    func saveUserInfo(uid: String,collection:String){
        params["id"] = uid
        #if User || Internal
        params["notifications"] = true
        #endif
        db.collection(collection).document(uid).setData(params) { (error) in
            if let e = error{
                UIApplication.showLoader(message: e.localizedDescription)
            }else{
                Router.login()
            }
        }
    }
}
