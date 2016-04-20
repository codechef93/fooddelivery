//
//  LandingViewController.swift
//  Aditi
//
//  Created by macbook on 23/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(internetStatus), name: .internet, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func internetStatus(){
        Router.login()
    }
}
