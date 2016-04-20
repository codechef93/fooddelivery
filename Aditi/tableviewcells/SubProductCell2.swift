import Foundation
import UIKit

protocol SubProductCell2Delegate : class {
    func buyProduct(p: Product, status : Bool)
}

class SubProductCell2: UITableViewCell {
   
    @IBOutlet weak var pImg: UIImageView!
    @IBOutlet weak var pname: UILabel!
    @IBOutlet weak var pprice: UILabel!
    @IBOutlet weak var isBuy: CheckBox!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var sub_detail_area: UIStackView!
    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detail_price: UILabel!
    @IBOutlet weak var detail_discount: UILabel!
    @IBOutlet weak var detail_desc: UITextView!
    
    
    var cur_product : Product?
    var buy_delegate : SubProductCell2Delegate?
    var isOpened = false
    
    func setProduct(product : Product){
        cur_product = product
        pImg.setImage(with: URL(string: product.image), placeholderImage: Constants.imgPlaceholder)
        pname.text = product.title
        pprice.text = "$ \(product.totalAmount)"
        
        let tmpArr = product.catId.components(separatedBy: "=@=")
        category.text = tmpArr[0]
        
        detailImg.setImage(with: URL(string: product.image), placeholderImage: Constants.imgPlaceholder)
        detailTitle.text = product.title
        detail_discount.text = "$ \(product.totalAmount)"
        detail_desc.text = product.desc
        detail_price.isHidden = true
        
        isBuy.borderStyle = .square
        isBuy.style = .tick
        
    }
    
    @IBAction func buyChange(_ sender: Any) {
        buy_delegate?.buyProduct(p: cur_product!, status: isBuy.isChecked)
    }
    
}
