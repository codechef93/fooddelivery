//
//  RiderTabBarController.swift
//  AditiInternal
//
//  Created by macbook on 18/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class RiderTabBarController: UITabBarController {
    
//    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
//    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

//    var cities = ["所有" : "所有"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = Constants.goldenColor
        self.tabBar.backgroundColor = Constants.navBarColor
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = Constants.navBarColor
        addSettingVc()
    }
    func addSettingVc(){
        var viewControllers = self.viewControllers
        let nav = viewControllers?.last as? CustomNavigationController
        let settingsVc : SettingViewController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        nav?.viewControllers = [settingsVc]
        _ = viewControllers?.popLast()
        viewControllers?.append(nav!)
        self.viewControllers = viewControllers
    }

}
