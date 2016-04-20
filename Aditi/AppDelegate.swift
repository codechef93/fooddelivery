//
//  AppDelegate.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import CodableFirebase
import FirebaseFirestore
import Reachability
import NotificationBannerSwift
import Stripe
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var fcmToken : String?
    static let shared = UIApplication.shared.delegate as! AppDelegate
    let reachability = try! Reachability()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupReachability()
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        UIApplication.setupUpNavBar()
        UIApplication.setupHud()
        
        let setting = FirestoreSettings()
        setting.isPersistenceEnabled = true
        db.settings = setting
        setupNotifications()

        Stripe.setDefaultPublishableKey(Constants.stripePbKey)
        return true
    }
    
    func setupNotifications(){
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {(bool, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}

}


extension AppDelegate : UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error while registering APNS : \(error.localizedDescription)")
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let action = userInfo["action"] as? String {
            if action == "chat" {
                if !UIApplication.topViewController().isKind(of: ChatViewController.self){
                    completionHandler([.alert,.badge,.sound])
                }
            }
            else{
                completionHandler([.alert,.badge,.sound])
            }
        }else{
            completionHandler([.alert,.badge,.sound])
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let action = userInfo["action"] as? String {
            if action == "chat" {
                let channelId = userInfo["channelId"] as! String
                if !UIApplication.topViewController().isKind(of: ChatViewController.self){
                    showChat(channelId: channelId)
                }
            }
            else if action == "order"{
                let orderId = userInfo["orderId"] as! String
                showOrder(orderId: orderId)
            }
        }
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func showChat(channelId: String){
        if AppDelegate.noInternet() { return }
        channelsCol.document(channelId).getDocument { (docSnap, err) in
            if let data = docSnap?.data() {
                let channel = Channel(document: data)
                let chatVc : ChatViewController = UIStoryboard(storyboard: .chat).instantiateViewController()
                chatVc.channel = channel
                UIApplication.topViewController().navigationController?.pushViewController(chatVc, animated: true)
            }else{
                print("Invalid channel id")
            }
        }
    }
    func showOrder(orderId: String){
        if AppDelegate.noInternet() { return }
        ordersCol.document(orderId).getDocument { (docSnap, err) in
            if let data = docSnap?.data() ,
                let order = try? FirestoreDecoder().decode(Order.self, from: data) {
                let vc : OrderDetailsController = UIStoryboard(storyboard: .riders).instantiateViewController()
                vc.order = order
                UIApplication.topViewController().navigationController?.pushViewController(vc, animated: true)
            }else{
                print("Invalid order id")
            }
        }
    }
}
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcm : \(fcmToken)")
        AppDelegate.fcmToken = fcmToken
        User.shared?.updateFcm(fcm: fcmToken!)
    }
}
//MARK:- REACHABILITY
extension AppDelegate {
    static var hasInternet : Bool { return AppDelegate.shared.reachability.connection != .unavailable }
    func setupReachability(){
        let banner = StatusBarNotificationBanner(title: Errors.noInternet, style: .info, colors: CustomBannerColors())
        banner.autoDismiss = false
        if !UIDevice.current.hasNotch{
            banner.bannerHeight =  64
        }else{
            banner.bannerHeight =  88
        }
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            Firestore.firestore().enableNetwork(completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                banner.dismiss()
            })
            NotificationCenter.default.post(name: .internet, object: nil)
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            Firestore.firestore().disableNetwork(completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                banner.show()
            })
            NotificationCenter.default.post(name: .internet, object: nil)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    class func noInternet() -> Bool {
        if AppDelegate.shared.reachability.connection != .unavailable {
            return false
        }
        UIApplication.showError(message: Errors.noInternet, delay: 1)
        return true
    }
}

//MARK:- BANNER COLOR CLASS

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
            case .info:        // Your custom .info color
                return .red
        default:
            return Constants.goldenColor
        }
    }
}
