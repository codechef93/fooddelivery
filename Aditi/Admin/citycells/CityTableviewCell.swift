

import UIKit

protocol City1CellDelegate : class {
    func deletePressed(cityItem : CityItem)
}

class CityTableviewCell: UITableViewCell {
    
    @IBOutlet weak var cityname: UILabel!
    
    var city_item : CityItem?
    var delegate : City1CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(cityItem : CityItem, _delegate : City1CellDelegate){
        city_item = cityItem
        if city_item != nil {
            cityname.text = "\(city_item!.name!) (\(city_item!.city_code!))"
        }
        delegate = _delegate
    }
    
    @IBAction func onDel(_ sender: Any) {
        if city_item == nil { return }
        delegate?.deletePressed(cityItem: city_item!)
    }
}
