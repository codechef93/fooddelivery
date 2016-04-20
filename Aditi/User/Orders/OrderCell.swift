//
//  OrderCell.swift
//  AditiAdmin
//
//  Created by macbook on 16/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

protocol OrderCellDelegate : class {
    func changeStatus(order : Order)
    func callPressed(order : Order)
    func msgPressed(order: Order)
    func deleteCatPressed(category : Category)
}
extension OrderCellDelegate {
    func changeStatus(order : Order){}
    func callPressed(order : Order){}
    func msgPressed(order: Order){}
    func deleteCatPressed(category : Category){}
}

class OrderCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var orderNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var acceptBtn: AppColorBgButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var deleteCatBtn: UIButton!
    
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
    
    
    func setupForCategory(category : Category, delegate : OrderCellDelegate?){
        priceLbl.isHidden = true
        self.category = category
        imgView.setImage(with: URL(string:category.image), placeholderImage: Constants.imgPlaceholder)
        orderNoLbl.text = category.title
        orderNameLbl.text = category.desc
        imgView.contentMode = .scaleAspectFill
        #if Admin
//        deleteCatBtn.isHidden = false
        self.delegate = delegate
        #endif
        phoneBtn.isHidden = true
        chatBtn.isHidden = true
    }
    func setupForProduct(product : Product){
        priceLbl.text = "$" + product.totalAmount
        self.product = product
        imgView.setImage(with: URL(string:product.image), placeholderImage: Constants.imgPlaceholder)
        orderNoLbl.text = product.title
        orderNameLbl.text = product.desc
        imgView.contentMode = .scaleAspectFill
        phoneBtn.isHidden = true
        chatBtn.isHidden = true
    }
    func setupForOrder(order :Order, isHistory : Bool = false, delegate : OrderCellDelegate){
        self.delegate = delegate
        self.order = order
//
        if(order.order_date != nil)
        {
            priceLbl.text =  Date(timeIntervalSince1970: Double(order.order_date! / 1000)).toStringwith(format: DateFormats.dateAndTime)
        }
        else {
            priceLbl.text = ""
        }
        
        if let image = order.products.first?.product.image {
            imgView.setImage(with: URL(string: image))
        }
        orderNoLbl.text = order.cellTitle
        orderNameLbl.text = "$\(order.total)".replacingOccurrences(of: ".0", with: "")
        phoneBtn.isHidden = true // isHistory
        chatBtn.isHidden = true  //isHistory
        acceptBtn.isHidden = true
        orderNoLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    @IBAction func changeStatus(_ button : UIButton){
        delegate?.changeStatus(order: self.order!)
    }
    @IBAction func call(_ button : UIButton){
        if let url = URL(string: "tel://\(order?.driver?.phone ?? "")"),
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
        delegate?.deleteCatPressed(category: category!)
    }
}
