//
//  AddContentViewController.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class AddContentViewController: UIViewController , UITextViewDelegate {
    
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var saveBtn : UIButton!
    
    var type : Content = .privacy
    let placeholder = "在這裡輸入"
    var viewOnly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString(type.rawValue, comment: "")
        textView.text = placeholder
        textView.delegate = self
        //        if type != .aboutUs {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 12
        //        }
        if viewOnly {
            textView.isEditable = false
            textView.isSelectable = false
        }
        #if User
        saveBtn.isHidden = true
        #endif
        UIApplication.showLoader()
        
        if type == .deliveryTime {
            db.collection("Contents").document(Content.notes.rawValue).getDocument { [weak self] (snap, err) in
                UIApplication.hideLoader()
                guard let doc = snap?.data() else {
                    return
                }
                self?.textView.text = doc["deliveryTime"] as? String
            }
        }else{
            db.collection("Contents").document(type.rawValue).getDocument { [weak self] (snap, err) in
                UIApplication.hideLoader()
                guard let snap = snap?.data(), let text = snap["text"] as? String else {
                    return
                }
                self?.textView.text = text
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {textView.text = ""}
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" { textView.text = placeholder }
    }
    
    @IBAction func save(_ btn : UIButton){
        let text = textView.text == placeholder ? "" : textView.text
        if type == .deliveryTime {
            db.collection("Contents").document(Content.notes.rawValue).updateData(["deliveryTime" : text ?? ""])
            UIApplication.showSuccess(message: "外賣速遞時間更新!", delay: 2)
        }else{
            db.collection("Contents").document(type.rawValue).setData(["text" : text ?? ""])
        }
        navigationController?.popViewController(animated: true)
    }
}
