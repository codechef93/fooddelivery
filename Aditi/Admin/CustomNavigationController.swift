//
//  CustomNavigationController.swift
//  AditiAdmin
//
//  Created by macbook on 25/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    var statusBarStyle = UIStatusBarStyle.lightContent { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
