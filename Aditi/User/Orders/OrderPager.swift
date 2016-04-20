//
//  OrderPager.swift
//  AditiUser
//
//  Created by macbook on 27/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

import UIKit
import XLPagerTabStrip


class OrderPager: ButtonBarPagerTabStripViewController {
    var isReload = false
    @IBOutlet weak var notesLbl: UILabel!
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsCountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notesLbl.text = UserTabbarController.shared?.impInfo?.text
        updateCartView()
        navigationItem.title = "訂單"
//        addTitleLogo()
    }
    
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
    
    func updateCartView(){
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.white.cgColor
        
        if Cart.shared.items.count > 0 {
            //            UIView.animate(withDuration: 0.3) {
            self.cartViewHeight.constant = 50
            self.view.layoutIfNeeded()
            //            }
        }else{
            if cartViewHeight.constant != 0 {
                //                UIView.animate(withDuration: 0.3) {
                self.cartViewHeight.constant = 0
                self.view.layoutIfNeeded()
                //                }
            }
        }
        priceLbl.text = "$\(Cart.shared.total())"
        itemsCountLbl.text = "\(Cart.shared.allItemsCount)"
    }
    @IBAction func showCart(_ sender: UITapGestureRecognizer) {
        let cartVc : CartViewController = UIStoryboard(storyboard: .cart).instantiateViewController()
        self.navigationController?.pushViewController(cartVc, animated: true)
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let orders : OrderViewController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        let history : OrderViewController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        history.isHistory = true
        
        guard isReload else {
            return [orders,history]
        }
        
        /*var childViewControllers = [orders,history]
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)*/
        return [orders,history]
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
}
