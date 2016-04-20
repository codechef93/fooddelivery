//
//  UIAlertcontroller.swift
//  share-food
//
//  Created by Invision-040 on 1/15/19.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func actionableAlert(with message: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            action()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func alertWithChoice(title : String? = nil, message: String, yesBtnTitle: String, noBtnTitle: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let back = UIAlertAction(title: yesBtnTitle, style: .default) { (_) in
            action()
        }
        let cancel = UIAlertAction(title: noBtnTitle, style: .cancel)
        alert.addAction(back)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func alertWithChoices(with title : String? = nil, message: String, yesBtnTitle: String, noBtnTitle: String, yesaction: @escaping () -> Void,noaction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let back = UIAlertAction(title: yesBtnTitle, style: .default) { (_) in
            yesaction()
        }
        let cancel = UIAlertAction(title: noBtnTitle, style: .default){ (_) in
            noaction()
        }
        alert.addAction(cancel)
        alert.addAction(back)
        present(alert, animated: true)
    }
    
    func locationAlert() {
        let alert = UIAlertController(title: "Location Access Pending", message: "It will enable us to show you available meals around you", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true)
    }
    
    func alertWithTextField(with title:String? = nil,
                            message: String,
                            yesBtnTitle: String,
                            noBtnTitle: String,
                            yesaction: @escaping (_ text : String?) -> Void,
                            noaction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let back = UIAlertAction(title: yesBtnTitle, style: .default) { [weak alert] (_) in
            yesaction(alert?.textFields?.first?.text)
        }
        let cancel = UIAlertAction(title: noBtnTitle, style: .default){ (_) in
            noaction()
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Time(In Minutes)"
            textField.keyboardType = .numberPad
        }
        alert.addAction(back)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
    func setStatusBar(backgroundColor: UIColor) {
        var statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        statusBarFrame.size.height = 20
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
}
