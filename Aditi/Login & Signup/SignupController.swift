//
//  SignupController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import IQKeyboardManagerSwift

class SignupController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var registerBtn: AppColorBgButton!
    @IBOutlet weak var policyCheck: CheckBox!
    @IBOutlet weak var promotionCheck: CheckBox!
    @IBOutlet weak var skipBtn: AppColorBgButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        #if Admin
//        usernameField.text = "Shahzaib"
//        phoneField.text = "+923363173039"
//        emailField.text = "shahzaibahmed2009@live.com"
//        #elseif User
//        usernameField.text = "Shezu93Customer"
//        phoneField.text = "+923232428834"
//        emailField.text = "shezuu93@gmail.com"
//        #else
//        usernameField.text = "Shezu93Rider"
//        phoneField.text = "+923332428834"
//        emailField.text = "shahzaibahmed@rocketmail.com"
//        #endif
//        policyCheck.isSelected = true
        
        #if User
        skipBtn.isHidden = false
        #endif
        
        policyCheck.style = .tick
        promotionCheck.style = .tick
        policyCheck.borderStyle = .square
        promotionCheck.borderStyle = .square
    }
    
    //MARK:- BUTTONS
    @IBAction func skipBtnPressed(_ sender: AppColorBgButton) {
        let userTab = UIStoryboard(storyboard: .usertabbar).instantiateInitialViewController()!
        UIApplication.shared.setRootVc(vc: userTab)
    }
    
    @IBAction func policyCheck(_ sender: CheckBox) {
//        sender.isChecked = !sender.isChecked
    }
    
    @IBAction func promotionCheck(_ sender: CheckBox) {
//        sender.isChecked = !sender.isChecked
    }
    
    @IBAction func signupPressed(_ sender: UIButton) {
      
        guard let username = usernameField.text, username.count > 4 else {
            UIApplication.showError(message: Errors.usernameErr)
            return
        }
        guard var phone = phoneField.text , phone.count > 5 , phone.count < 20 else{
            UIApplication.showError(message: Errors.phoneErr)
            return
        }
        guard let email = emailField.text , email.isValidEmail() else {
            UIApplication.showError(message: Errors.emailErr)
            return
        }
        if !policyCheck.isChecked {
            UIApplication.showError(message: Errors.policyErr)
            return
        }
        
        view.resignFirstResponder()
        view.endEditing(true)
        if AppDelegate.noInternet() {return}
        if !phone.hasPrefix("+852") {
            phone = "+852" + phone
        }
        
        Authenticator.shared = Authenticator.init(phoneNumber: phone)
        Authenticator.shared?.isSignup = true
        Authenticator.shared?.sendCode(completion: { [weak self] (success) in
            guard let weakSelf = self else{return}
            if success {
                Authenticator.shared?.params = [
                    "createdAt" :   FieldValue.serverTimestamp(),
                    "email"     :   weakSelf.emailField.text!,
                    "name"      :   weakSelf.usernameField.text!,
                    "online"    :   true,
                    "phone"     :   weakSelf.phoneField.text!,
                    "platform"  :   "iOS",
                    "token"     :   ""
                    ] as [String : Any]
                let verificationVc : VerificationViewController = weakSelf.storyboard!.instantiateViewController()
                weakSelf.present(verificationVc, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func dismissToLogin(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
}
