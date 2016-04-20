//
//  TabbarController.swift
//  伴百味
//
//  Created by Shezu on 22/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class UserTabbarController: UITabBarController , UITabBarControllerDelegate {
    
    var categories = [Category]()
    var products = [Product]()
    
    var categoryListener :  ListenerRegistration?
    var productListener  :  ListenerRegistration?
    var contentListener  :  ListenerRegistration?
    
    var showingLoader = true
    static var shared : UserTabbarController?
//    var notes : String?
//    var banner : String?
//    var cities : [String:String]?
//    var deliveryTime : String?

//    var statusBarStyle = UIStatusBarStyle.lightContent {
//        didSet { setNeedsStatusBarAppearanceUpdate()}
//    }
//    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    var impInfo : ImpInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = Constants.goldenColor
        self.tabBar.backgroundColor = Constants.navBarColor
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = Constants.navBarColor
        self.delegate = self
        UserTabbarController.shared = self
        UIApplication.showLoader()
        getContent()
        loadCategories()
        loadProducts()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
    
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if User.shared != nil {return true}
        
        guard let index = self.viewControllers?.firstIndex(of: viewController) else {return true}
        if index == 1 || index == 3 {
            alertWithChoices(with: nil, message: NSLocalizedString("loginSignup", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: {
                Router.logout()
            }, noaction: {})
            return false
        }
        return true
    }
    
    
    @objc func reload(){
        if AppDelegate.hasInternet {
            products = []
            categories = []
            productListener?.remove()
            contentListener?.remove()
            categoryListener?.remove()
            
            getContent()
            loadCategories()
            loadProducts()
        }
    }
    
    func loadCategories(){
        categoryListener = categoriesCol.order(by: "title", descending: false).addSnapshotListener { [weak self] (snap, err) in
            guard let snap = snap else {
                print("error while getting categories")
                return
            }
            snap.documentChanges.forEach { (diff) in
                if diff.document.metadata.hasPendingWrites {return}
                let data = diff.document.data()
                let id = diff.document.documentID
                let category = Category(document: data, docId: id)
                
                if diff.type == .added {
                    self?.categories.append(category)
                }
                if diff.type == .modified {
                    if let i = self?.categories.firstIndex(where: { $0.id ==  category.id}) {
                        self?.categories[i] = category
                    }else{
                        self?.categories.append(category)
                    }
                }
                if diff.type == .removed {
                    if let i = self?.categories.firstIndex(where: { $0.id ==  category.id}) {
                        self?.categories.remove(at: i)
                    }
                }
            }
            NotificationCenter.default.post(name: .productsLoaded, object: nil)
        }
    }
    func loadProducts(){
        productListener = productsCol.order(by: "title", descending: false).addSnapshotListener { [weak self] (snap, err) in
            guard let snap = snap else {
                print("error while getting categories")
                return
            }
            snap.documentChanges.forEach { (diff) in
                if diff.document.metadata.hasPendingWrites {return}
                let data = diff.document.data()
                let id = diff.document.documentID
                let product = Product(document: data, docId: id)
                
                if diff.type == .added {
                    self?.products.append(product)
                }
                if diff.type == .modified {
                    if let i = self?.products.firstIndex(where: { $0.id ==  product.id}) {
                        self?.products[i] = product
                    }else{
                        self?.products.append(product)
                    }
                }
                if diff.type == .removed {
                    if let i = self?.products.firstIndex(where: { $0.id ==  product.id}) {
                        self?.products.remove(at: i)
                    }
                }
            }
            NotificationCenter.default.post(name: .productsLoaded, object: nil)
            if self?.showingLoader == true {
                UIApplication.hideLoader()
            }
        }
    }
    
    func getContent(){
        contentListener = contentsCol.addSnapshotListener{ [weak self] (snap, err) in
            guard let snap = snap else {
                print("error while getting contents")
                return
            }
            snap.documentChanges.forEach { (diff) in
                let doc = diff.document.data()
                if diff.document.documentID == Content.notes.rawValue{
//                    if let notes = doc["text"] as? String , notes != "" {
//                        self?.notes = notes
//                    }else{
//                        self?.notes = nil
//                    }
//                    self?.banner = doc["banner"] as? String
//                    self?.cities = doc["cities_map"] as? [String:String]
//                    self?.deliveryTime = doc["deliveryTime"] as? String
                    
                    guard let imp_info = try? FirestoreDecoder().decode(ImpInfo.self, from: doc) else{
                        print("Error while decoding Order")
                        return
                    }
                    self!.impInfo = imp_info
                    NotificationCenter.default.post(name: .contentUpdated, object: nil)
                }
            }
        }
    }
    
    deinit {
        categoryListener?.remove()
        productListener?.remove()
        contentListener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
}
