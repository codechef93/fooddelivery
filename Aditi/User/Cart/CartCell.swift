//
//  CartCell.swift
//  AditiAdmin
//
//  Created by macbook on 14/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

protocol CartCellDelegate : class {
    func add(cartItem : CartItem)
    func sub(cartItem : CartItem)
    func delete(cartItem : CartItem)
}

class CartCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var sublist_stackview: UIStackView!
    
    var item : CartItem!
    weak var delegate : CartCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setup(item : CartItem, delegate : CartCellDelegate){
        self.item = item
        self .delegate = delegate
        titleLbl.text = "\(item.quantity)x " + item.product.title
        priceLbl.text = "$" + item.product.totalAmount
        
        for v in sublist_stackview.subviews{
           v.removeFromSuperview()
        }
        
        var i = 0
        item.subProducts.forEach{ item in
            var subPView = SubPCell()
            let tmpArr = item.catId.components(separatedBy: "=@=")
            subPView.p_name.text = tmpArr[0] + " / " + item.title
            subPView.p_price.text = "+ $\(item.totalAmount)"
            let yy = i * 42
            let w = sublist_stackview.frame.width
            subPView.frame =  CGRect(x: 0,y: yy , width: Int(w), height: 42)
            sublist_stackview.addSubview(subPView)
            i = i + 1
        }
        // note
        if item.note != nil && item.note != "" {
            var subPView = SubPCell()
            subPView.p_name.numberOfLines = 0
            subPView.p_name.text = item.note!
            
            subPView.p_price.isHidden = true
            let yy = i * 42
            let w = sublist_stackview.frame.width
//            let h = estimatedHeightOfLabel(superview: sublist_stackview, text: item.note!)
            subPView.frame =  CGRect(x: 0,y: yy , width: Int(w), height: 42)
            sublist_stackview.addSubview(subPView)
        }
    }
    
    func estimatedHeightOfLabel(superview: UIView, text: String) -> CGFloat {

        let size = CGSize(width: superview.frame.width - 50, height: 1600)

        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height

        return rectangleHeight
    }
    
    @IBAction func deleteBtn(_ sender: UIButton) {
        self.delegate.delete(cartItem: item)
    }
}
