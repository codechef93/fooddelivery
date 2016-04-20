
import Foundation
import UIKit

class SubCategCell: UITableViewCell {
    @IBOutlet weak var sub_categ_name: UILabel!
    
    func setName(name : String){
        sub_categ_name.text = name
    }
}
