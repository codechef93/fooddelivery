//
//  Extension+UIApplication.swift
//  伴百味
//
//  Created by Shezu on 22/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension UIApplication {

    static func setupUpNavBar(){
    
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        
        if #available(iOS 13.0, *) {
            
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                    .font : UIFont.systemFont(ofSize: 16, weight: .heavy)]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white,
                                                               .font : UIFont.systemFont(ofSize: 16, weight: .heavy)]
            navBarAppearance.backgroundColor = Constants.navBarColor
            
            let backButtonImage = UIImage(named: "arrow_back")!.withRenderingMode(.alwaysOriginal)
            navBarAppearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
            
            //Hide back button text
            let back = UIBarButtonItemAppearance()
            back.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            navBarAppearance.backButtonAppearance = back
            
            let buttonAppearance = UIBarButtonItemAppearance()
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor : Constants.goldenColor]
            buttonAppearance.normal.titleTextAttributes = titleTextAttributes
            navBarAppearance.buttonAppearance = buttonAppearance
            
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }else{
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().backgroundColor = UIColor.black
            UINavigationBar.appearance().barTintColor = .white
        }
    }
    
    func setupStatusBarWithColor(color : UIColor){
        if #available(iOS 13.0, *) {
            let statusBar =  UIView()
            
            let width = UIScreen.main.bounds.width
            let f = CGRect(x: 0, y: 0, width: width, height: 20)
            
            statusBar.frame =    UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame ?? f
            statusBar.backgroundColor = color
            UIApplication.shared.windows.first?.addSubview(statusBar)
            
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
        }
    }
    
    func setRootVc(vc : UIViewController){
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        window.rootViewController = vc
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
        { completed in
            // maybe do something on completion here
        })
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) ->
        UIViewController {
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller!
    }
    
    class func getTabBar(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) ->
        UITabBarController? {
            
            if let tabController = controller as? UITabBarController {
                return tabController
            }
            
            return nil
    }
}
//MARK:- LOADER
extension UIApplication {
    static func setupHud(){
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setMaximumDismissTimeInterval(1)
    }
    static func showLoader(message : String? = nil){
        DispatchQueue.main.async {
            if let msg = message{
                SVProgressHUD.show(withStatus: NSLocalizedString(msg, comment: ""))
            }else{
                SVProgressHUD.show(withStatus: message)
            }
        }
    }
    static func hideLoader(delay : Int = 0){
        DispatchQueue.main.async {
            SVProgressHUD.dismiss(withDelay: TimeInterval(delay))
        }
    }
    static func showSuccess(message : String? = nil, delay : Int? = nil){
        DispatchQueue.main.async {
            if let msg = message{
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString(msg, comment: ""))
            }else{
                SVProgressHUD.showSuccess(withStatus: message)
            }
            if let delay = delay { hideLoader(delay: delay) }
        }
    }
    static func showError(message : String? = nil, delay : Int? = nil){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            if let msg = message{
                SVProgressHUD.showError(withStatus: NSLocalizedString(msg, comment: ""))
            }else{
                SVProgressHUD.showError(withStatus: message)
            }
            if let delay = delay { hideLoader(delay: delay) }
        })
    }
}


