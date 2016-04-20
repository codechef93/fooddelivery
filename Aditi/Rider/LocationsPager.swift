//
//  LocationsPager.swift
//  AditiInternal
//
//  Created by macbook on 29/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CodableFirebase

class LocationsPager: ButtonBarPagerTabStripViewController {
    var isReload = false
    
    var cities_level1 = User.shared?.impInfo?.cities_level1
    var cities_level2 = User.shared?.impInfo?.cities_level2
    var cities_level3 = User.shared?.impInfo?.cities_level3
    
    override func viewDidLoad() {
        settings.style.selectedBarBackgroundColor = .black
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.selectedBarHeight = 2.5
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        db.collection(Constants.getUserCollection()).document(User.shared!.id).getDocument { (snap, err) in
            guard let document = snap?.data() else {
                if snap?.exists == false {
                    UIApplication.showError(message: Errors.userDeleted)
                }else{
                }
                return
            }
            
            do {
                User.shared = try FirestoreDecoder().decode(User.self, from: document)
                
                self.reloadPagerTabStripView()
            }catch {
                print(error)
                UIApplication.showError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var vcs = [NewOrdersController]()
        
        if (User.shared!.level == "level1")
        {
            // hide tab bar
            showTabBar(flag: false)
            ///
            let allOrdersVc : NewOrdersController = UIStoryboard(storyboard: .riders).instantiateViewController()
            allOrdersVc.cityName = User.shared?.city
            vcs.append(allOrdersVc)
        }
        else if (User.shared!.level == "level2")
        {
            // show tab bar
            showTabBar(flag : true)
            
            let allOrdersVc : NewOrdersController = UIStoryboard(storyboard: .riders).instantiateViewController()
            allOrdersVc.cityName = "所有"
            vcs.append(allOrdersVc)

            var cities = cities_level3?.filter({$0.parent_city == User.shared?.region })
            if cities == nil { return vcs }
            cities!.sort(by: {$0.name! > $1.name! })
            
            cities!.forEach({
                 let orders : NewOrdersController = UIStoryboard(storyboard: .riders).instantiateViewController()
                 orders.cityName = $0.name
                 vcs.append(orders)
            })
        }
        else
        {
            // hide tab bar
            showTabBar(flag: false)
            
            settings.style.buttonBarHeight = 0
            let allOrdersVc : NewOrdersController = UIStoryboard(storyboard: .riders).instantiateViewController()
            allOrdersVc.cityName = User.shared?.area
            vcs.append(allOrdersVc)
        }
        
        
        guard isReload else {
            return vcs
        }
        
        return vcs
    }
    
    func showTabBar(flag : Bool) {
        if let constraint = (self.buttonBarView.constraints.filter{$0.firstAttribute == .height}.first) {
        constraint.constant = flag == true ? 43 : 0
        }
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    deinit {
        print("deiniting locations pager")
    }
}
