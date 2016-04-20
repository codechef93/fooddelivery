//
//  AddressViewController.swift
//  伴百味
//
//  Created by Shezu on 28/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var laneField: CustomField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var regionField: UITextField!
    @IBOutlet weak var areaField: UITextField!
    
    var regions = [String : [String]]()
    
    let city_picker = UIPickerView()
    let region_picker = UIPickerView()
    let area_picker = UIPickerView()
    
    var cities_level1 = UserTabbarController.shared?.impInfo?.cities_level1
    var cities_level2 = UserTabbarController.shared?.impInfo?.cities_level2
    var cities_level3 = UserTabbarController.shared?.impInfo?.cities_level3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "送貨地址"
        setupViews()
    }
    
    func setupViews(){
        
        applyBorder(textField: cityField)
        applyBorder(textField: regionField)
        applyBorder(textField: areaField)
        
        
        city_picker.delegate = self
        city_picker.dataSource = self
        region_picker.delegate = self
        region_picker.dataSource = self
        area_picker.delegate = self
        area_picker.dataSource = self
        
        cityField.inputView = city_picker
        regionField.inputView = region_picker
        areaField.inputView = area_picker
        
        regionField.delegate = self
        cityField.delegate = self
        areaField.delegate = self
        
        bindData()
        
    }
    
    func bindData(){
        laneField.text = User.shared?.address

        updateCityPicker()
    }
    
    func updateCityPicker() {
        city_picker.reloadAllComponents()
        if let city = User.shared?.city, let city_code = cities_level1?.first(where: {$0.name! == city })?.city_code{
            cityField.text = city
            
            updateRegionPicker(city: city_code, selFirstItemFlag: false)
        }else{
            cityField.text = ""
        }
    }
    
    func updateRegionPicker(city : String, selFirstItemFlag : Bool) {
        cities_level2 = UserTabbarController.shared?.impInfo?.cities_level2.filter({$0.parent_city == city})
        region_picker.reloadAllComponents()
        if let region = User.shared?.region, let city_code = cities_level2?.first(where: {$0.name! == region})?.city_code{
            regionField.text = region
            
            updateAreaPicker(region: city_code, selFirstItemFlag: selFirstItemFlag)
        }else{
            if cities_level2 != nil && selFirstItemFlag == true
            {
                regionField.text = cities_level2!.first == nil ? "" : cities_level2!.first!.name
                let code = cities_level2!.first == nil ? "" : cities_level2!.first!.city_code
                updateAreaPicker(region: code!, selFirstItemFlag: selFirstItemFlag)
            }
            else {
                regionField.text = ""
            }
        }
    }
    func updateAreaPicker(region : String, selFirstItemFlag : Bool) {
        cities_level3 = UserTabbarController.shared?.impInfo?.cities_level3.filter({$0.parent_city == region})
        area_picker.reloadAllComponents()
        let area = User.shared?.area
        let ccode = cities_level3?.first(where: {$0.name! == area})
        if let area = User.shared?.area, let city_code = cities_level3?.first(where: {$0.name! == area})?.city_code{
            areaField.text = area
            
        }else{
            if cities_level3 != nil && selFirstItemFlag == true
            {
                areaField.text = cities_level3!.first == nil ? "" : cities_level3!.first!.name
            }
            else {
                areaField.text = ""
            }
        }
    }
    
    func applyBorder(textField : UITextField?)
    {
        textField?.layer.borderWidth = 0.5
        textField?.layer.borderColor = UIColor.black.cgColor
        textField?.layer.cornerRadius = 4
    }
    
    
    //MARK:- BUTTON ACTIONS
    @IBAction func save(_ btn : UIButton){
        
        guard let lane = laneField.text, lane.count > 3 else {
            UIApplication.showError(message: Errors.invalidAddress)
            return
        }

        guard let city = cityField.text else {
            UIApplication.showError(message: Errors.invalidCityName)
            return
        }
        guard let region = regionField.text else {
            UIApplication.showError(message: Errors.invalidCityName)
            return
        }
        guard let area = areaField.text else {
            UIApplication.showError(message: Errors.invalidCityName)
            return
        }
        
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        let data = ["address" : lane,
                    "city" : city,
                    "region" : region,
                    "area" : area
        ]
        User.shared?.ref.updateData(data, completion: { [weak self] (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription)
            }else{
                User.shared?.updateData(data: data)
                UIApplication.showSuccess(message: Messages.infoUpdated, delay: 1)
                self?.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    //MARK:- UITextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let picker = textField.inputView as? UIPickerView else{return}
        picker.reloadAllComponents()
        
        var items = cities_level1
        if(textField == regionField)
        {
            items = cities_level2
        }
        else if(textField == areaField)
        {
            items = cities_level3
        }
        if(items != nil)
        {
            if let index = items!.firstIndex(where: { $0.name == textField.text }){
                picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
    }
    
    //MARK:- PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == city_picker)
        {
            return cities_level1 == nil ? 0 : cities_level1!.count
        }
        else if (pickerView == region_picker)
        {
            return cities_level2 == nil ? 0 : cities_level2!.count
        }
        else
        {
            return cities_level3 == nil ? 0 : cities_level3!.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if (pickerView == city_picker)
       {
        return cities_level1![row].name
       }
       else if (pickerView == region_picker)
       {
           return cities_level2![row].name
       }
       else
       {
           return cities_level3![row].name
       }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == city_picker)
        {
            if row >= cities_level1!.count { return }
            cityField.text = cities_level1![row].name
            updateRegionPicker(city: cities_level1![row].city_code!, selFirstItemFlag: true)
        }
        else if (pickerView == region_picker)
        {
            if row >= cities_level2!.count { return }
            regionField.text = cities_level2![row].name
            updateAreaPicker(region: cities_level2![row].city_code!, selFirstItemFlag: true)
        }
        else if (pickerView == area_picker)
        {
            if row >= cities_level3!.count { return }
            areaField.text = cities_level3![row].name
        }
    }
}
