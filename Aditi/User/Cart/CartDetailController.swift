//
//  CartDetailController.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CartDetailController: UIViewController, CheckoutVcDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var productLbl: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var discountValueLbl: UILabel!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponTop: NSLayoutConstraint!
    @IBOutlet weak var couponHeight: NSLayoutConstraint!
    @IBOutlet weak var deliveryTimeLbl : UILabel!
    @IBOutlet weak var changeBtn: UIButton!
    
    var date : Date!
    var coupon : Coupon?
    var isCod = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "確認訂單"
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         addressLbl.text = User.shared!.address
    }
    func setupView(){
        dateLbl.text = date.toStringwith(format: "dd-MM-yyyy")
        timeLbl.text = date.toStringwith(format: "hh:mm a")
        addressLbl.text = User.shared!.address
        productLbl.text = "\(Cart.shared.allItemsCount) 項目"
        subTotal.text = "$\(Cart.shared.subTotal)"
        orderTotal.text = "$\(Cart.shared.total(coupon: coupon))"
        discountValueLbl.text = "$-\(Cart.shared.getDiscountAmount(coupon: coupon))"
        couponView.isHidden = coupon == nil
        if couponView.isHidden {
            couponTop.constant = 0
            couponHeight.constant = 0
        }
        deliveryTimeLbl.text = UserTabbarController.shared?.impInfo?.deliveryTime ?? ""
//        let attrTitle = NSAttributedString(string: "Change", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
//                                                                          NSAttributedString.Key.foregroundColor : UIColor.goldenColor
//        ])
//        changeBtn.setAttributedTitle(attrTitle, for: .normal)
    }
    @IBAction func changeAddrBtn(_ sender: Any) {
        let vc : AddressViewController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pay(_ sender: UIButton) {
        let user = User.shared

        if (user == nil || user!.city == nil || user!.city == "" || user!.region == nil || user!.region == "" || user!.area == nil || user!.area == "")
        {
            UIApplication.showError(message: "Your location is not valid, please set valid location!", delay: 4)
           return
        }
        let cities_level1 = UserTabbarController.shared?.impInfo?.cities_level1
        let cities_level2 = UserTabbarController.shared?.impInfo?.cities_level2
        let cities_level3 = UserTabbarController.shared?.impInfo?.cities_level3
        
        if( cities_level1 == nil || cities_level2 == nil || cities_level3 == nil)
        {
            UIApplication.showError(message: "Your location is not valid, please set valid location!", delay: 4)
            return
        }
        if( cities_level1!.filter ({ $0.name == user!.city}).isEmpty ||
            cities_level2!.filter ({ $0.name == user!.region}).isEmpty ||
            cities_level3!.filter ({ $0.name == user!.area}).isEmpty)
        {
           UIApplication.showError(message: "Your location is not valid, please set valid location!", delay: 4)
            return
        }
        
        if isCod {
            addOrder(token: nil)
        }else{
            if Cart.shared.subTotal < 4 {
                UIApplication.showError(message: "Sorry, we can't make an order which is under $4.", delay: 4)
            }
            else {
                let vc : CheckoutViewController = self.storyboard!.instantiateViewController()
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                present(vc, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func tokenCreated(token: String) {
        addOrder(token: token)
    }
    
    func errorFromStripe(error: String) {
        UIApplication.showError(message: error, delay: 3)
    }
    
    func addOrder(token : String?){
        if AppDelegate.noInternet() {return}
        var data = [
            "date"      : date!.toStringUTCwith(format: DateFormats.postFormat),
            "customer"  : User.shared!.postBody,
            "total"     : "\(Cart.shared.subTotal)",
            "subTotal"  : "\(Cart.shared.total(coupon: coupon))",
            "products"  : Cart.shared.items.map{ $0.postBody },
            "status"    : OrderStatus.new.rawValue,
            "amount"    : Int(Cart.shared.subTotal) * 100
            ] as [String : Any]
        
        if let c = coupon {
            data["coupon"] = c.postBody
        }
        if let token = token {
            data["token"] = token
        }
        if isCod {
            data["cod"] = true
        }
        data["order_date"] = UInt64(Date().timeIntervalSince1970 * 1000)
        UIApplication.showLoader()
        NetworkManager.createOrder(params: data) { [weak self] (success, msg, statusCode) in
            if success {
                Cart.shared = nil
                UIApplication.showSuccess(message: msg, delay: 1)
                if let c = self?.coupon {
                    self?.updateCouponUsed(coupon: c)
                }
                self?.navigationController?.popToRootViewController(animated: true)
            }else{
                if statusCode == 404 {
                    Cart.shared = nil
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                UIApplication.showError(message: msg, delay: 3)
            }
        }
    }
    
    func updateCouponUsed(coupon : Coupon){
        couponsCol.document(coupon.id).updateData([ "usedBy" : FieldValue.arrayUnion([User.shared?.id ?? ""]) ])
    }
}
