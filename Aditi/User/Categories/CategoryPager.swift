//
//  CategoryPager.swift
//  AditiAdmin
//
//  Created by macbook on 25/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class CategoryPager: ButtonBarPagerTabStripViewController {
    var isReload = false
    var index = 0
    
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsCountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    
    override func viewDidLoad() {
        settings.style.selectedBarBackgroundColor = UIColor(hexString: "006930")
        settings.style.buttonBarItemTitleColor = UIColor(hexString: "006930")
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.selectedBarHeight = 2.5
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarItemLeftRightMargin = 10
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        super.viewDidLoad()
        DispatchQueue.main.async {
            if self.index != 0 {
                self.moveToViewController(at: self.index)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCartView()
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
            }
            //            }
        }
        priceLbl.text = "$\(Cart.shared.total())"
        itemsCountLbl.text = "\(Cart.shared.allItemsCount)"
    }
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childs = [CategoryBannerVc]()
        UserTabbarController.shared!.categories.forEach { (category) in
            if let index = UserTabbarController.shared!.categories.firstIndex(where: { $0.id == category.id }) {
                let vc : CategoryBannerVc = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
                vc.selectedIndex = index
                childs.append(vc)
            }
        }
        guard isReload else {
            return childs
        }
    
        
        var childViewControllers = childs
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
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
    @IBAction func showCart(_ sender: UITapGestureRecognizer) {
        let cartVc : CartViewController = UIStoryboard(storyboard: .cart).instantiateViewController()
        self.navigationController?.pushViewController(cartVc, animated: true)
    }
}
