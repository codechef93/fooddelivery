//
//  OrderDetailCell.swift
//  AditiInternal
//
//  Created by macbook on 18/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class OrderDetailCell: UITableViewCell {
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemQty: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var detail_sub_area: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWithOrder(cartItem : CartItem){
        itemName.text = cartItem.product.title.capitalized
        itemQty.text = "\(cartItem.quantity)x"
        itemPrice.text = "$" + cartItem.product.totalAmount
        
        var i = 0
        cartItem.subProducts.forEach{ item in
            var subPView = SubPCell()
            let tmpArr = item.catId.components(separatedBy: "=@=")
            subPView.p_name.text = tmpArr[0] + " / " + item.title
            subPView.p_price.text = "+ $\(item.totalAmount)"
            let yy = i * 42
            let w = self.frame.width - 12
            subPView.frame =  CGRect(x: 0,y: yy , width: Int(w), height: 42)
            detail_sub_area.addSubview(subPView)
            i = i + 1
        }
        // note
        if cartItem.note != nil && cartItem.note != "" {
            var subPView = SubPCell()
            subPView.p_name.numberOfLines = 0
            subPView.p_name.text = cartItem.note!
            
            subPView.p_price.isHidden = true
            let yy = i * 42
            let w = self.frame.width - 12
            subPView.frame =  CGRect(x: 0,y: yy , width: Int(w), height: 42)
            detail_sub_area.addSubview(subPView)
        }
    }
    
}
