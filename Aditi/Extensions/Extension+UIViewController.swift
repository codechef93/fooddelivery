//
//  Extension+UIViewController.swift
//  伴百味
//
//  Created by Shezu on 22/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//


import Foundation
import UIKit
//import MaterialComponents.MDCTabBar
import FirebaseFirestore
extension UIViewController {
    
    func setStatusBarColor(color : UIColor = UIColor.statusBar){
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.windows.first?.windowScene?.statusBarManager?.statusBarFrame .size.height ?? 0

            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
            statusbarView.backgroundColor = color
            view.addSubview(statusbarView)
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
        }
    }
    
    func addShadowUnderNav(){
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
    }
    
//    func                                                                                                     (tabBar : MDCTabBar){
//        tabBar.selectedItemTitleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
//        tabBar.unselectedItemTitleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
//
//        tabBar.itemAppearance = .titles
//        tabBar.alignment = .justified
//        tabBar.tintColor = Constants.goldenColor
//        tabBar.barTintColor = .clear // selected bar color
//        tabBar.titleTextTransform = .none
//        tabBar.rippleColor = Constants.goldenColor
//        tabBar.setTitleColor(.darkGray, for: .normal)
//        tabBar.setTitleColor(Constants.goldenColor, for: .selected)
//        tabBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
//        tabBar.bottomDividerColor = .clear
//        tabBar.sizeToFit()
//        tabBar.backgroundColor = UIColor.lightText
//    }
    
    func setNavBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        navigationItem.leftBarButtonItem?.title = ""
    }
    
    func addSideMenuIcon(){
        let bbi = UIBarButtonItem(image: UIImage(named: "home_menu_icon"), style: .done, target: self, action: #selector(self.openSideMenu))
        navigationItem.leftBarButtonItem = bbi
    }
    
    @objc func openSideMenu(){
//        present(UIApplication.menu, animated: true, completion: nil)
    }
    
    func addTitleLogo(){
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let titleImageView = UIImageView(image: UIImage(named: "Logo"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: titleView.frame.width, height: titleView.frame.height)
        titleImageView.contentMode = .scaleAspectFit
        titleView.addSubview(titleImageView)
        navigationItem.titleView = titleView
    }
    
    func addRightBarBtns(){
        if User.shared == nil {return}
        let chatIcon = UIBarButtonItem(image: UIImage(named: "Icon simple-hipchat"), style: .done, target: self, action: #selector(self.chat))
        self.navigationItem.rightBarButtonItems = [chatIcon]
    }
    
    func addChatBtn(){
        if User.shared == nil {return}
        let chatIcon = UIBarButtonItem(image: UIImage(named: "Icon simple-hipchat"), style: .done, target: self, action: #selector(chat))
        navigationItem.rightBarButtonItems = [chatIcon]
    }
    
    func getCartBbi() -> UIBarButtonItem{
        let badgeCount = UILabel(frame: CGRect(x: 22, y: -05, width: 20, height: 20))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        badgeCount.backgroundColor = Constants.goldenColor
        badgeCount.text = "\(Cart.shared.items.count)"


        let rightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        rightBarButton.setImage(UIImage(named: "cart_icon"), for: .normal)
        rightBarButton.addTarget(self, action: #selector(self.cart), for: .touchUpInside)
        rightBarButton.addSubview(badgeCount)
        rightBarButton.tintColor = .white
        
        let bbi = UIBarButtonItem(customView: rightBarButton)
        bbi.tintColor = .white
        return bbi
    }
    
    @objc func cart(){
        let cartVc : CartViewController = UIStoryboard(storyboard: .cart).instantiateViewController()
        self.navigationController?.pushViewController(cartVc, animated: true)
    }
    @objc func chat(){
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        channelsCol
            .whereField("member.id", isEqualTo: User.shared!.id)
            .whereField("active", isEqualTo: true)
            .getDocuments { [weak self] (querySnap, err) in
                guard let snap = querySnap else {
                    UIApplication.showError(message: err!.localizedDescription, delay: 1)
                    return
                }
                if let data = snap.documents.first?.data() {
                    let channel = Channel(document: data)
                    self?.moveToChat(channel: channel)
                }else{
                    self?.createChannel()
                }
        }
    }
    
    func memberType() -> MemberType {
        #if Admin
        return MemberType.admin
        #elseif Internal
        return MemberType.driver
        #else
        return MemberType.customer
        #endif
    }
    
    func createChannel(){
        let channelId = channelsCol.document().documentID
        let member = ["id" : User.shared!.id, "name":User.shared!.name, "type" : memberType().rawValue ]
        let messageId = messagesCol.document().documentID
        let messageText = memberType() == .customer ?
        "Admin will be assigned to you shortly!":"Hi Admin"
        
        let msgType = memberType() == .customer ? "10" : "1"
        let message = ["id" : messageId ,
                       "date": FieldValue.serverTimestamp(),
                       "message" : messageText,
                       "channelId" : channelId,
                       "senderId" : User.shared!.id,
                       "senderName" : User.shared!.name,
                       "msgType" : msgType,
                       "senderType" : ChatViewModel.msgSenderType()] as [String : Any]
        let channel = [
            "active":true,
            "id" : channelId,
            "member" : member,
            "read" : false,
            "message" : message
            ] as [String : Any]
        
        UIApplication.showLoader()
        let batch = db.batch()
        let channelRef = channelsCol.document(channelId)
        let msgRef = messagesCol.document(messageId)
        batch.setData(channel, forDocument: channelRef)
        batch.setData(message, forDocument: msgRef)
        batch.commit { [weak self] (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription, delay: 1)
            }else{
                self?.chat()
            }
        }
    }
    
    func moveToChat(channel : Channel) {
        let vc : ChatViewController = UIStoryboard(storyboard: .chat).instantiateViewController()
        vc.channel = channel
        navigationController?.pushViewController(vc, animated: true)
    }
}
//extension UIViewController {
//    open override func awakeFromNib() {
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//    }
//}
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
