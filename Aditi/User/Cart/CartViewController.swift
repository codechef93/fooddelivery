//
//  CartViewController.swift
//  AditiAdmin
//
//  Created by macbook on 14/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class CartViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var deliveryField: UITextField!
    @IBOutlet weak var deliveryTime: UITextField!
    @IBOutlet weak var couponField: UITextField!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var cartListHeight: NSLayoutConstraint!
    @IBOutlet weak var couponView: UIView!
    
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var codImg: UIImageView!
    @IBOutlet weak var cardBtn: UIButton!
    @IBOutlet weak var codBtn: UIButton!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var scrollcontentView: UIView!
    
    var coupon : Coupon?
    var date : Date?
    var day : Date?
    var time : Date?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "購物車"
        let nib = UINib(nibName: "CartCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CartCell")
        
        let datePicker = UIDatePicker()
        deliveryTime.inputView = datePicker
        deliveryField.inputView = datePicker
        deliveryField.delegate = self
        deliveryTime.delegate = self
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        
        day = Date()
        deliveryField.text = day?.toStringwith(format: "yyyy/MM/dd")
        
        time = Date()
        deliveryTime.text = time?.toStringwith(format: "hh:mm a")
        
        couponView.layer.borderColor = UIColor.lightGray.cgColor
        couponView.layer.borderWidth = 0.5
        radioBtnTap(cardBtn)
        
        
    }

    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
//        scrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 4000)
    }
    @IBAction func radioBtnTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender == cardBtn {
            if cardBtn.isSelected {
                cardImg.image = UIImage(named: "radioCheck")
                codImg.image = UIImage(named: "radioUncheck")
                codBtn.isSelected = false
            }else{
                cardImg.image = UIImage(named: "radioUncheck")
                codImg.image = UIImage(named: "radioCheck")
                codBtn.isSelected = true
            }
        }else{
            if codBtn.isSelected {
                cardImg.image = UIImage(named: "radioUncheck")
                codImg.image = UIImage(named: "radioCheck")
                cardBtn.isSelected = false
            }else{
                cardImg.image = UIImage(named: "radioCheck")
                codImg.image = UIImage(named: "radioUncheck")
                cardBtn.isSelected = true
            }
        }
    }
    
    func updateCart(){
        Cart.shared.getLatestProductPrices()
        collectionView.reloadData()
        updateHeight()
        totalLbl.text = "$\(Cart.shared.total(coupon: coupon))"
    }
    
    func updateHeight(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.cartListHeight.constant = self.collectionView.contentSize.height
            
            self.scrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 280 + self.cartListHeight.constant)
        })
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == deliveryField , let datePicker = textField.inputView as? UIDatePicker {
            datePicker.datePickerMode = .date
        }
        if textField == deliveryTime , let datePicker = textField.inputView as? UIDatePicker {
            datePicker.datePickerMode = .time
        }
    }
    
    @objc func dateChanged(_ datePicker : UIDatePicker){
        if deliveryField.isFirstResponder {
            day = datePicker.date
            deliveryField.text = day?.toStringwith(format: "yyyy/MM/dd")
        }else if deliveryTime.isFirstResponder {
            time = datePicker.date
            deliveryTime.text = time?.toStringwith(format: "hh:mm a")
        }
    }
    
    @IBAction func proceed(_ btn : UIButton){
        
        if User.shared == nil {
            alertWithChoices(with: nil, message: NSLocalizedString("loginSignup", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: {
                Router.logout()
            }, noaction: {})
            return
        }
        
        if Cart.shared.items.count == 0 {return}
        if AppDelegate.noInternet() {return}
        if day == nil || time == nil {
            UIApplication.showError(message: Errors.invalidDeliveryTime, delay: 1)
            return
        }
        
        if User.shared?.address == nil {
            UIApplication.showError(message: Errors.noAddress, delay: 1)
            return
        }
        if User.shared?.city == nil {
            UIApplication.showError(message: Errors.noCity, delay: 1)
            return
        }
        
        var comps = Calendar.current.dateComponents(in: .current, from: time!)
        comps.setValue(comps.minute, for: .minute)
        comps.setValue(comps.hour, for: .hour)
        comps = Calendar.current.dateComponents(in: .current, from: day!)
        comps.setValue(comps.day, for: .day)
        date = comps.date
        
        if let code = couponField.text, code.count > 3 {
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            couponsCol
                .whereField("code", isEqualTo: code)
                .whereField("to", isGreaterThanOrEqualTo: Date())
                .getDocuments { [weak self] (querySnap, err) in
                    guard let snap = querySnap?.documents.first?.data() else {
                        UIApplication.showError(message: Errors.invalidCode, delay: 1)
                        return
                    }
                    if let coupon = try? FirestoreDecoder().decode(Coupon.self, from: snap) {
                        self?.coupon = coupon
                        if coupon.usedBy?.contains(User.shared!.id) ?? false{
                            UIApplication.showError(message: "此優惠券已使用", delay: 3)
                            return
                        }
                        self?.totalLbl.text = "$\(Cart.shared.total(coupon: coupon))"
                        self?.showCartDetail()
                        UIApplication.hideLoader()
                    }else{
                        UIApplication.showError(message: Errors.invalidCode, delay: 1)
                    }
            }
        }else{
            showCartDetail()
        }
    }
    
    func showCartDetail(){
        let vc : CartDetailController = storyboard!.instantiateViewController()
        vc.coupon = coupon
        vc.date = date!
        vc.isCod = codBtn.isSelected
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension CartViewController : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Cart.shared.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartCell", for: indexPath) as! CartCell
        let item = Cart.shared.items[indexPath.row]
        cell.setup(item: item, delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var h = 50 + CGFloat(Cart.shared.items[indexPath.row].subProducts.count) * 42
        if Cart.shared.items[indexPath.row].note != nil && Cart.shared.items[indexPath.row].note != "" {
            h = h + estimatedHeightOfLabel(text: Cart.shared.items[indexPath.row].note!) + 20
        }
        return CGSize(width: collectionView.frame.size.width, height: h)
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {

        let size = CGSize(width: view.frame.width - 50, height: 1600)

        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height

        return rectangleHeight
    }
}
extension CartViewController : CartCellDelegate {
    func add(cartItem: CartItem) {
        if let p = UserTabbarController.shared?.products.first(where: { $0.id == cartItem.product.id }),
            let c = UserTabbarController.shared?.categories.first(where: { $0.id == cartItem.product.catId }) {
            Cart.shared.addProduct(product: p, catName: c.title, qty: 1, note: "", subProducts: cartItem.subProducts)
        }
        collectionView.reloadData()
        updateHeight()
    }
    func sub(cartItem: CartItem) {
        if let p = UserTabbarController.shared?.products.first(where: { $0.id == cartItem.product.id }){
            Cart.shared.subProduct(product: p)
        }
        collectionView.reloadData()
        updateHeight()
        if Cart.shared.items.count == 0 {
            navigationController?.popViewController(animated: true)
        }
    }
    func delete(cartItem: CartItem) {
        if let p = UserTabbarController.shared?.products.first(where: { $0.id == cartItem.product.id }){
            Cart.shared.deleteProduct(product: p)
        }
        collectionView.reloadData()
        updateHeight()
        if Cart.shared.items.count == 0 {
            navigationController?.popViewController(animated: true)
        }
        totalLbl.text = "$\(Cart.shared.total(coupon: coupon))"
    }
}
