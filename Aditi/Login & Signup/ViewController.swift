//
//  ViewController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var skipbtn: AppColorBgButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        #if User
        skipbtn.isHidden = false
        #endif
    }
    
    @IBAction func skip(_ sender: UIButton) {
        let userTab = UIStoryboard(storyboard: .usertabbar).instantiateInitialViewController()!
        UIApplication.shared.setRootVc(vc: userTab)
    }
    @IBAction func showSignup(_ sender: WhiteBgButton) {
        
    }
    @IBAction func showLogin(_ sender: UITapGestureRecognizer) {
        let vc : PhoneNumberVc = UIStoryboard(storyboard: .main).instantiateViewController()
        present(vc, animated: true, completion: nil)
    }
}

