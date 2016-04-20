//
//  Router.swift
//  Aditi
//
//  Created by macbook on 23/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class Router {
    static var listener : ListenerRegistration?
    static func login(){
        if let uid = Auth.auth().currentUser?.uid {
            if !AppDelegate.hasInternet {
                showTabs()
                return
            }
            UIApplication.showLoader()
            db.collection(Constants.getUserCollection()).document(uid).getDocument { (snap, err) in
                guard let document = snap?.data() else {
                    if snap?.exists == false {
                        UIApplication.showError(message: Errors.userDeleted)
                        try? Auth.auth().signOut()
                        logout()
                    }else{
                        showTabs()
                        UIApplication.hideLoader()
                    }
                    return
                }
                do {
                    User.shared = try FirestoreDecoder().decode(User.self, from: document)
                    if let fcm = AppDelegate.fcmToken {
                        User.shared?.updateFcm(fcm: fcm)
                    }
                    showTabs()
                }catch {
                    print(error)
                    UIApplication.showError(message: error.localizedDescription)
                    logout()
                }
            }
        }else{
            logout()
        }
    }
    
    static func getCities (completion :  @escaping () -> Void) {
        contentsCol.getDocuments{(snap, err) in
            if snap != nil {
                snap!.documents.forEach { (snap) in
                    let doc = snap.data()
                    if snap.documentID == Content.notes.rawValue{
                        
                        guard let imp_info = try? FirestoreDecoder().decode(ImpInfo.self, from: doc) else{
                            print("Error while decoding Order")
                            return
                        }
                        User.shared?.impInfo = imp_info
                        
                    }
                }
            }
            completion()
        }
    }
    
    static func showTabs(){
        getCities() {
            #if Admin
            let adminHomeVc = UIStoryboard(storyboard: .admin).instantiateInitialViewController()!
            UIApplication.shared.setRootVc(vc: adminHomeVc)
            UIApplication.hideLoader()
            #elseif User
            let userTab = UIStoryboard(storyboard: .usertabbar).instantiateInitialViewController()!
            UIApplication.shared.setRootVc(vc: userTab)
            #else
            let riderTab = UIStoryboard(storyboard: .riders).instantiateInitialViewController() as! RiderTabBarController
            UIApplication.shared.setRootVc(vc: riderTab)
            #endif
        }
    }
    #if Internal
    static func showRiderTab(){
        DispatchQueue.main.async {
            let riderTab = UIStoryboard(storyboard: .riders).instantiateInitialViewController() as! RiderTabBarController
            UIApplication.shared.setRootVc(vc: riderTab)
        }
    }
    #endif
    static func logout(){
        DispatchQueue.main.async {
            let vc : ViewController = UIStoryboard(storyboard: .main).instantiateViewController()
            UIApplication.shared.setRootVc(vc: vc)
        }
    }
}
