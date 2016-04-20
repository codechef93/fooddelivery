//
//  CitiesViewController.swift
//  AditiAdmin
//
//  Created by macbook on 20/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import DZNEmptyDataSet
class Cities2ViewController: UIViewController , UITableViewDataSource , UITableViewDelegate, City1CellDelegate {
    
    @IBOutlet weak var cityField : UITextField!
    @IBOutlet weak var addbtn : UIButton!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var cityCodeField: UITextField!
    
    var parentCity : CityItem?
    var cities = [CityItem]()
    var contentListener : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = parentCity?.name
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.emptyDataSetSource = self
        listenCities()
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        addCity()
    }
    //MARK:- DELEGATES
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CityTableviewCell = tableView.dequeueReusableCell(withIdentifier: "city_1_tvcell", for: indexPath) as! CityTableviewCell
        cell.setupView(cityItem: cities[indexPath.row], _delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func deletePressed(cityItem: CityItem) {
        alertWithChoices(message: NSLocalizedString("areYouSure", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: { [weak self] in

            let cityitem = CityItem.data(parent_city: cityItem.parent_city!, name: cityItem.name!, city_code: cityItem.city_code!)
            UIApplication.showLoader()
            ImpInfo.delCity(level: "cities_level3", cityitem: cityitem) { result , err in
                UIApplication.hideLoader()
                if let e = err {
                    UIApplication.showError(message: e, delay: 1)
                }else{
                    self!.cityField.text = ""
                    self!.cityCodeField.text = ""
                    UIApplication.showSuccess(message: "刪除地區")
                    self!.listenCities()
                }
            }
        }) {}
    }
    
    //MARK:- FIRESTORE CALLS
    func listenCities(){
        UIApplication.showLoader()
        ImpInfo.getInfo() {(data, err) in
            UIApplication.hideLoader()
            guard data != nil else {
                print(err)
                return
            }
            self.cities = data!.cities_level3
            self.cities = self.cities.filter({$0.parent_city == self.parentCity?.city_code })
            self.cities.sort(by: {$0.name! > $1.name! })
            self.tableView.reloadData()
        }
    }
    func addCity(){
        if AppDelegate.noInternet() {return}
        guard let city = cityField.text , city.count > 0 else{
            UIApplication.showError(message: Errors.invalidCityName, delay: 1)
            return
        }
        guard let cityCode = cityCodeField.text , cityCode.count > 0 else{
            UIApplication.showError(message: Errors.invalidCityCide, delay: 1)
            return
        }
        
        if let _ = cities.first(where: { $0.city_code == cityCode }) {
            UIApplication.showError(message: Errors.cityExists, delay: 1)
            return
        }
        
        view.resignFirstResponder()
        
        let cityitem = CityItem.data(parent_city: parentCity!.city_code!, name: city, city_code: cityCode)
        
        UIApplication.showLoader()
        ImpInfo.addCity(level: "cities_level3", cityitem: cityitem) { result , err in
            UIApplication.hideLoader()
            if let e = err {
                UIApplication.showError(message: e, delay: 1)
            }else{
                self.cityField.text = ""
                self.cityCodeField.text = ""
                UIApplication.showSuccess(message: "新增地區")
                self.listenCities()
            }
        }
    }
    deinit {
        contentListener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cityField.endEditing(true)
    }
}
extension Cities2ViewController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noCities", comment: ""))
        return attrStr
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: "")
        return attrStr
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage()
    }
}
