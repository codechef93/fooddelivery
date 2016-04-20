//
//  VerificationViewController.swift
//  AditiAdmin
//
//  Created by macbook on 22/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class VerificationViewController: UIViewController {

    @IBOutlet weak var otpField : UITextField!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var resendBtn: AppColorBgButton!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var appTitleLbl: UILabel!
    
    var verificationID : String!
    var isSignup = false
    var params = [String:Any]()
    var timer : Timer?
    var time = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        otpField.delegate = self
        
        #if Admin
        appTitleLbl.text = "Aditi Admin"
        #elseif User
        appTitleLbl.text = "Aditi User"
        #else
        appTitleLbl.text = "Aditi Internal"
        #endif
        resendBtn.isHidden = true
        otpField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    @objc func textDidChange(_ textField : UITextField){
        if let text = textField.text , text.count == 6 {
            textField.endEditing(true)
            verify(self.verifyBtn)
        }
    }
    func startTimer(){
        time = 60
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
    }

    @objc func updateLabel(){
        if time > 0 {
            resendBtn.isHidden = true
            time -= 1
        }else{
            timer?.invalidate()
            timer = nil
            resendBtn.isHidden = false
        }
        timeLbl.text = "00:\(String(format: "%02d", time))"
    }
    
    @IBAction func resend(_ sender: AppColorBgButton) {
        if AppDelegate.noInternet() {return}
        sender.isHidden = true
        Authenticator.shared?.sendCode(completion: { [weak self] (success) in
            if success {
                UIApplication.hideLoader()
                self?.startTimer()
            }
        })
    }
    
    @IBAction func verify(_ sender: UIButton) {
        guard let text = otpField.text , text.count == 6 else{
            UIApplication.showError(message: Errors.phoneErr)
            return
        }
        Authenticator.shared?.signIn(code: text)
    }
    
}
extension VerificationViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {return true}
        if (textField.text ?? "").count == 6 {
            return false
        }
        return true
    }
}
