import Foundation
import UIKit

protocol CityCheckCellDelegate : class {
    func onSelectCity(city : CityItem, status : Bool)
}

class CityCheckCell: UITableViewCell {
   
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var name: UILabel!
    
    var city : CityItem?
    var check_delegate : CityCheckCellDelegate?
    
    func setCity(cityItem : CityItem, delegate : CityCheckCellDelegate){
        city = cityItem
        name.text = city?.name
        checkbox.borderStyle = .square
        checkbox.style = .tick
        
        check_delegate = delegate
    }
    
    @IBAction func onSelectCity(_ sender: Any) {
        check_delegate?.onSelectCity(city: city!, status: checkbox.isChecked)
    }
}
