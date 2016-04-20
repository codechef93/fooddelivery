//
//  CategoryBannerVc.swift
//  AditiAdmin
//
//  Created by macbook on 15/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import XLPagerTabStrip
class CategoryBannerVc: UIViewController, IndicatorInfoProvider {
   
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var collectionView : UICollectionView!
    
    var selectedIndex = 0
    var selectedCategory : Category {
        return UserTabbarController.shared!.categories[selectedIndex]
    }
    var products : [Product]{
        return UserTabbarController.shared!.products.filter{ $0.catId == selectedCategory.id }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addRightBarBtns()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .productsLoaded, object: nil)
    }
    
    @objc func reload(){
        self.collectionView.reloadData()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: selectedCategory.title.uppercased())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CategoryBannerVc :  UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rectangle", for: indexPath)
        let lbl = cell.viewWithTag(1) as! UILabel
        let imgView = cell.viewWithTag(2) as! UIImageView
        let desclbl = cell.viewWithTag(3) as! UILabel
        let stocklbl = cell.viewWithTag(4)?.viewWithTag(5) as? UILabel
        let pricelbl = cell.viewWithTag(6) as! UILabel
        
        let p = products[indexPath.row]
        lbl.text = p.title
        imgView.setImage(with: URL(string: p.image))
        desclbl.text = p.desc
        if let stock = Int(p.stock) , stock <= 0 {
            stocklbl?.text = "暫時售罄"
        }else{
            stocklbl?.text = "庫存量: "+p.stock
        }
        pricelbl.text = p.totalAmount
        cell.viewWithTag(4)?.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc : ItemDetailController = storyboard!.instantiateViewController()
        vc.product = products[indexPath.row]
        vc.category = selectedCategory
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 160)
    }
}

extension CategoryBannerVc : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noProducts", comment: ""))
        return attrStr
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: "")
        return attrStr
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage()
    }
}
