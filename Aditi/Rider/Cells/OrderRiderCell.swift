//
//  OrderRiderCell.swift
//  AditiInternal
//
//  Created by Shezu on 28/07/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class OrderRiderCell: UITableViewCell {

        @IBOutlet weak var orderNoLbl: UILabel!
        @IBOutlet weak var orderNameLbl: UILabel!
        @IBOutlet weak var priceLbl: UILabel!
        @IBOutlet weak var acceptBtn: AppColorBgButton!
        @IBOutlet weak var phoneBtn: UIButton!
        @IBOutlet weak var chatBtn: UIButton!
        @IBOutlet weak var deleteCatBtn: UIButton!
        @IBOutlet weak var qrscabBtn: UIButton!
    
        var category : Category?
        var product : Product?
        var order : Order?
        weak var delegate : OrderCellDelegate?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            self.selectionStyle = .none
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

        }
        
//
//        func setupForCategory(category : Category, delegate : OrderCellDelegate?){
//            priceLbl.isHidden = true
//            self.category = category
//            orderNoLbl.text = category.title
//            orderNameLbl.text = category.desc
//            #if Admin
//    //        deleteCatBtn.isHidden = false
//            self.delegate = delegate
//            #endif
//            phoneBtn.isHidden = true
//            chatBtn.isHidden = true
//        }
//        func setupForProduct(product : Product){
//            priceLbl.text = "$" + product.totalAmount
//            self.product = product
//            orderNoLbl.text = product.title
//            orderNameLbl.text = product.desc
//            phoneBtn.isHidden = true
//            chatBtn.isHidden = true
//        }
        func setupForOrder(order :Order, isHistory : Bool = false, delegate : OrderCellDelegate){
            self.delegate = delegate
            self.order = order
            
            if(order.order_date != nil)
            {
                let aa = order.order_date!
                let bb = Date(timeIntervalSince1970: Double(order.order_date! / 1000))
                let cc = bb.timeIntervalSince1970
                let ee = bb.toStringwith(format: DateFormats.dateAndTime, timezone: TimeZone(abbreviation: "UTC+2"))
                let dd = bb.toStringwith(format: DateFormats.dateAndTime)
                priceLbl.text = Date(timeIntervalSince1970: Double(order.order_date! / 1000)).toStringwith(format: DateFormats.dateAndTime)
            }
            else {
                priceLbl.text = ""
            }
            if order.status == .completed {
                qrscabBtn.isHidden = true
            }
            orderNoLbl.text = order.cellTitle
            orderNameLbl.text = "$\(order.total)".replacingOccurrences(of: ".0", with: "")
            phoneBtn.isHidden = true // isHistory
            chatBtn.isHidden = true  //isHistory
            acceptBtn.isHidden = true
            orderNoLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        @IBAction func changeStatus(_ button : UIButton){
            
        }
        @IBAction func call(_ button : UIButton){
            if let url = URL(string: "tel://\(order?.customer.phone ?? "")"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                UIApplication.showError(message: Errors.invalidDriverNumber, delay: 1)
            }
        }
        @IBAction func msg(_ button : UIButton){
            if let phone = order?.driver?.phone {
                let sms: String = "sms:\(phone)&body="
                let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
            }else{
                UIApplication.showError(message: Errors.invalidDriverNumber, delay: 1)
            }
        }
        
        @IBAction func deleteCategory(_ sender: UIButton) {
//            delegate?.deleteCatPressed(category: category!)
            if let url = URL(string: "tel://\(order?.customer.phone ?? "")"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                UIApplication.showError(message: Errors.invalidDriverNumber, delay: 1)
            }
        }
    
        @IBAction func onQrScan(_ sender: Any) {
            delegate?.changeStatus(order: self.order!)
        }
    
    }
