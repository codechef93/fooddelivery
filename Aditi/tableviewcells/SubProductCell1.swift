
import Foundation
import UIKit

class SubProductCell1: UITableViewCell {
   
    @IBOutlet weak var pImg: UIImageView!
    @IBOutlet weak var pname: UILabel!
    @IBOutlet weak var pprice: UILabel!
    
    func setProduct(product : Product){
        pImg.setImage(with: URL(string: product.image), placeholderImage: Constants.imgPlaceholder)
        pname.text = product.title
        pprice.text = "$ \(product.totalAmount)"
    }
}
