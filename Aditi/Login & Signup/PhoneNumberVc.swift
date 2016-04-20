//
//  PhoneNumberVc.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class PhoneNumberVc: UIViewController {
    
    @IBOutlet weak var phoneNumberField : UITextField!
    @IBOutlet weak var skipBtn: AppColorBgButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        #if Admin
//        phoneNumberField.text = "+923363173039"
//        #elseif User
//        phoneNumberField.text = "+923232428834"
//        #else
//        phoneNumberField.text = "+923332428834"
//        #endif
        #if User
        skipBtn.isHidden = false
        #endif
    }
    
    @IBAction func skipBtnPressed(_ sender: AppColorBgButton) {
        let userTab = UIStoryboard(storyboard: .usertabbar).instantiateInitialViewController()!
        UIApplication.shared.setRootVc(vc: userTab)
    }
    
    @IBAction func login(_ sender : UIButton){
        guard var text = phoneNumberField.text, text.count > 7 else {
            UIApplication.showError(message: Errors.phoneErr)
            return
        }
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        phoneNumberField.endEditing(true)
        
        if !text.hasPrefix("+852") && text != "+923232428834" {
            text = "+852" + text
        }

        db.collection(Constants.getUserCollection())
            .whereField("phone", isEqualTo: text)
            .getDocuments { (querySnap, err) in
                if let _ = err {
                    UIApplication.showError(message: Errors.userNotFound, delay: 1)
                    return
                }
                guard let snap = querySnap , snap.documents.count > 0 else{
                    UIApplication.showError(message: Errors.userNotFound, delay: 1)
                    return
                }
                
                Authenticator.shared = Authenticator.init(phoneNumber: text)
                Authenticator.shared?.isSignup = false
                Authenticator.shared?.sendCode(completion: { [weak self] (success) in
                    guard let weakSelf = self else{return}
                    if success {
                        let verificationVc : VerificationViewController = weakSelf.storyboard!.instantiateViewController()
                        weakSelf.present(verificationVc, animated: true, completion: nil)
                    }
                })
        }
    }
}
