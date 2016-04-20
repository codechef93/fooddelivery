//
//  DiscountViewController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class DiscountViewController: UIViewController  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var notesLbl: UILabel!
    
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsCountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    var selectedIndex = 0
    var products : [Product]{
        return UserTabbarController.shared!.products.filter({ $0.discount != "0"  })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addRightBarBtns()
        updateCartView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadNotes()
        collectionView.emptyDataSetSource = nil
        collectionView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotes), name:  .contentUpdated, object: nil)
        navigationItem.title = "優惠"
//        addTitleLogo()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .productsLoaded, object: nil)
    }
    
    @objc func reload(){
        collectionView.emptyDataSetSource = self
        collectionView.reloadData()
    }
    
    @objc func reloadNotes(){
        notesLbl.text = UserTabbarController.shared?.impInfo?.text
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension DiscountViewController : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
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
        let product = products[indexPath.row]
        vc.product = product
        if let category =  UserTabbarController.shared?.categories.first(where: { $0.id == product.catId }) {
            vc.category = category
            navigationController?.pushViewController(vc, animated: true)
        }else{
            print("Invalid category")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 160)
    }

    
}
extension DiscountViewController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noDiscounts", comment: ""))
        return attrStr
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: "")
        return attrStr
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty_orders")!
    }
}
