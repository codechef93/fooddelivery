//
//  MenuViewController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CategoryGridVc: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var notesLbl: InsetLabel!
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsCountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addRightBarBtns()
        updateCartView()
        navigationItem.title = "菜單"
//        addTitleLogo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .productsLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContent), name:  .contentUpdated, object: nil)
    }
    
    @objc func reload(){
        collectionView.emptyDataSetSource = self
        self.collectionView.reloadData()
    }
    @objc func reloadContent(){
        notesLbl.text = UserTabbarController.shared?.impInfo?.text
        
        if let bannerUrl = UserTabbarController.shared?.impInfo?.banner ,
            let url = URL(string: bannerUrl) {
            banner.setImage(with: url, placeholderImage: Constants.imgPlaceholder) { [weak self] (img) in
                if let _ = img {
                    let h = (self?.view.frame.size.height ?? 0) * 0.25
                    self?.reloadBannerHeight(height: h)
                }else{
                    self?.reloadBannerHeight(height: 0)
                }
            }
        }
    }
    func reloadBannerHeight(height : CGFloat){
        UIView.animate(withDuration: 0.3) {
            self.bannerHeight.constant = height
            self.view.layoutIfNeeded()
        }
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
    @IBAction func showCart(_ sender: UITapGestureRecognizer) {
        let cartVc : CartViewController = UIStoryboard(storyboard: .cart).instantiateViewController()
        self.navigationController?.pushViewController(cartVc, animated: true)
    }
    
    @IBAction func showSearchProducts(_ sender : UIButton){
        let listSearchVc : ListAndSearchVc = UIStoryboard(storyboard: .admin).instantiateViewController()
        listSearchVc.type = .product
        listSearchVc.openKeyboard = true
        navigationController?.pushViewController(listSearchVc, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CategoryGridVc : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserTabbarController.shared!.categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "square", for: indexPath)
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        
        let lbl = cell.viewWithTag(1) as! UILabel
        let imgView = cell.viewWithTag(2) as! UIImageView
        
        let category = UserTabbarController.shared!.categories[indexPath.row]
        lbl.text = category.title
        imgView.setImage(with: URL(string: category.image))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc : CategoryPager = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        vc.index = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let square = ((collectionView.frame.size.width / 2) - 8)
        return CGSize(width: square, height: square)
    }
}

extension CategoryGridVc : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noCategories", comment: ""))
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
