//
//  AccountViewController.swift
//  伴百味
//
//  Created by Shezu on 28/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var usernameField: CustomField!
    @IBOutlet weak var phoneNumberField: CustomField!
    @IBOutlet weak var emailField: CustomField!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var permission_area: UIView!
    @IBOutlet weak var driver_panel: UIStackView!
    
    @IBOutlet weak var canAdmin: CheckBox!
    @IBOutlet weak var canCateg: CheckBox!
    @IBOutlet weak var canProduct: CheckBox!
    @IBOutlet weak var canChat: CheckBox!
    @IBOutlet weak var canOrder: CheckBox!
    @IBOutlet weak var canCoupon: CheckBox!
    @IBOutlet weak var canContent: CheckBox!
    @IBOutlet weak var canDriver: CheckBox!
    @IBOutlet weak var canCity: CheckBox!
    @IBOutlet weak var canFcm: CheckBox!
    
    @IBOutlet weak var radio_level1: CheckBox!
    @IBOutlet weak var radio_level2: CheckBox!
    @IBOutlet weak var radio_level3: CheckBox!
    
    @IBOutlet weak var cityField: CustomField!
    @IBOutlet weak var regionField: CustomField!
    @IBOutlet weak var areaField: CustomField!
    
    // param
    var isAdminDetail = false
    var admin : AdminListItem?
    var forDriver = false
    
    // private variables
    let city_picker = UIPickerView()
    let region_picker = UIPickerView()
    let area_picker = UIPickerView()
    
    var cities_level1 = User.shared?.impInfo?.cities_level1
    var cities_level2 = User.shared?.impInfo?.cities_level2
    var cities_level3 = User.shared?.impInfo?.cities_level3
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.text = User.shared?.name
        phoneNumberField.text = User.shared?.phone
        emailField.text = User.shared?.email
        usernameField.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
        
        permission_area.isHidden = true
        driver_panel.isHidden = true
        if isAdminDetail {
            title = forDriver ? "驅動細節" : "管理員詳細資料"
            usernameField.isUserInteractionEnabled = false
            phoneNumberField.isUserInteractionEnabled = false
            emailField.isUserInteractionEnabled = false
            
            saveBtn.setTitle("確定", for: .normal)
            saveBtn.isEnabled = true
            saveBtn.isHidden = true
            
            #if Admin
            
            if admin?.superAdmin != true && User.shared?.superAdmin == true && forDriver == false {
                permission_area.isHidden = false
                addDeleteButton()
                
                setStyleCheckBox(chbx: canAdmin)
                setStyleCheckBox(chbx: canCateg)
                setStyleCheckBox(chbx: canProduct)
                setStyleCheckBox(chbx: canChat)
                setStyleCheckBox(chbx: canOrder)
                setStyleCheckBox(chbx: canCoupon)
                setStyleCheckBox(chbx: canContent)
                setStyleCheckBox(chbx: canDriver)
                setStyleCheckBox(chbx: canCity)
                setStyleCheckBox(chbx: canFcm)
                
                canAdmin.isChecked = admin?.can_admins == true
                canCateg.isChecked = admin?.can_category == true
                canProduct.isChecked = admin?.can_product == true
                canChat.isChecked = admin?.can_chat == true
                canOrder.isChecked = admin?.can_order == true
                canCoupon.isChecked = admin?.can_coupon == true
                canContent.isChecked = admin?.can_content == true
                canDriver.isChecked = admin?.can_drivers == true
                canCity.isChecked = admin?.can_city == true
                canFcm.isChecked = admin?.can_fcm == true
            }
            if forDriver {
                driver_panel.isHidden = false
                saveBtn.isHidden = false
                addDeleteButton()
                
                radio_level1.borderStyle = .rounded
                radio_level1.style = .circle
                
                radio_level2.borderStyle = .rounded
                radio_level2.style = .circle
                
                radio_level3.borderStyle = .rounded
                radio_level3.style = .circle
                
                radio_level1.isChecked = admin?.level == "level1"
                radio_level2.isChecked = admin?.level == "level2"
                radio_level3.isChecked = admin?.level == "level3"
                
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
                
                updateCityPicker()
            }
            
            #endif
            
            usernameField.text = admin?.name
            phoneNumberField.text = admin?.phone
            emailField.text = admin?.email
        }else{
            title = "帳戶資料"
        }
    }

    func addDeleteButton(){
        let bbi = UIBarButtonItem(image: UIImage(named: "trashBbi"), style: .done, target: self, action: #selector(deletePressed(_:)))
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func deletePressed(_ bbi : UIBarButtonItem){
        let forDriver = self.forDriver
        let title = forDriver ? NSLocalizedString("deleteDriver", comment: "") : NSLocalizedString("deleteAdmin", comment: "")
        let msg = forDriver ? NSLocalizedString("driver", comment: "") : NSLocalizedString("admin", comment: "")
        let col = forDriver ? driversCol : adminsCol
        alertWithChoices(with: title, message: "\(NSLocalizedString("areYouSure", comment: "")) \(msg)?", yesBtnTitle: "Yes", noBtnTitle: "Cancel", yesaction: { [weak self] in
            guard let weakSelf = self else{return}
            UIApplication.showLoader()
            
            col.document(weakSelf.admin!.id).delete { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription, delay: 1)
                }else{
                    UIApplication.showSuccess(message:  forDriver ? Messages.driverDel : Messages.adminDel, delay: 1)
                    if weakSelf.admin!.id == User.shared!.id {
                        User.shared?.logout()
                    }else{
                        weakSelf.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }, noaction: {})
    }
    
    @objc func fieldChanged(_ textField : UITextField){
        saveBtn.isEnabled = true
    }

    @IBAction func savePressed(_ sender: UIButton) {
        
        if isAdminDetail && forDriver {
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
            var level = ""
            if radio_level1.isChecked {
                level = "level1"
            }
            if radio_level2.isChecked {
                level = "level2"
            }
            if radio_level3.isChecked {
                level = "level3"
            }
            if level == "" {
                UIApplication.showError(message: "Please set valid level")
                return
            }
            
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            let data = [
                        "city" : city,
                        "region" : region,
                        "area" : area,
                        "level" : level
            ]
            
            driversCol.document(admin!.id).updateData(data, completion: { [weak self]  (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription)
                }else{
                    User.shared?.updateData(data: data)
                    UIApplication.showSuccess(message: Messages.profileUpdated, delay: 1)
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            
            return
        }
        
        
        guard let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), username.count > 3 else{
            UIApplication.showError(message: Errors.invalidUsername)
            return
        }
        guard let email = emailField.text , email.isValidEmail() else{
            UIApplication.showError(message: Errors.emailErr)
            return
        }
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        User.shared?.ref.updateData(["name": username,"email":email], completion: { [weak self]  (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription)
            }else{
                User.shared?.email = email
                User.shared?.name = username
                UIApplication.showSuccess(message: Messages.profileUpdated, delay: 1)
                self?.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func setStyleCheckBox (chbx : CheckBox) {
        chbx.borderStyle = .square
        chbx.style = .tick
    }
    // permissions
    @IBAction func onAdmin(_ sender: Any) {
        updatePermission(perm: ["can_admins": canAdmin.isChecked])
    }
    @IBAction func onChat(_ sender: Any) {
        updatePermission(perm: ["can_chat": canChat.isChecked])
    }
    @IBAction func onContent(_ sender: Any) {
        updatePermission(perm: ["can_content": canContent.isChecked])
    }
    @IBAction func onCateg(_ sender: Any) {
        updatePermission(perm: ["can_category": canCateg.isChecked])
    }
    @IBAction func onOrder(_ sender: Any) {
        updatePermission(perm: ["can_order": canOrder.isChecked])
    }
    @IBAction func onDriver(_ sender: Any) {
        updatePermission(perm: ["can_drivers": canDriver.isChecked])
    }
    @IBAction func onProduct(_ sender: Any) {
        updatePermission(perm: ["can_product": canProduct.isChecked])
    }
    @IBAction func onCoupon(_ sender: Any) {
        updatePermission(perm: ["can_coupon": canCoupon.isChecked])
    }
    @IBAction func onCity(_ sender: Any) {
        updatePermission(perm: ["can_city": canCity.isChecked])
    }
    @IBAction func onFcm(_ sender: Any) {
        updatePermission(perm: ["can_fcm": canFcm.isChecked])
    }
    
    @IBAction func onLevel1(_ sender: Any) {
        radio_level1.isChecked = true
        radio_level2.isChecked = false
        radio_level3.isChecked = false
    }
    @IBAction func onLevel2(_ sender: Any) {
        radio_level1.isChecked = false
        radio_level2.isChecked = true
        radio_level3.isChecked = false
    }
    @IBAction func onLevel3(_ sender: Any) {
        radio_level1.isChecked = false
        radio_level2.isChecked = false
        radio_level3.isChecked = true
    }
    
    
    func updatePermission(perm : [String : Any]) {
        UIApplication.showLoader()
        db.collection(Constants.getUserCollection()).document(admin!.id).updateData(perm, completion: { (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription)
                UIApplication.hideLoader()
            }else{
                UIApplication.hideLoader()
            }
        })
    }
}

extension AccountViewController : UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate {
    
    func updateCityPicker() {
        city_picker.reloadAllComponents()
        if let city = admin?.city, let city_code = cities_level1?.first(where: {$0.name! == city })?.city_code{
            cityField.text = city
            
            updateRegionPicker(city: city_code, selFirstItemFlag: false)
        }else{
            cityField.text = ""
        }
    }
    
    func updateRegionPicker(city : String, selFirstItemFlag : Bool) {
        cities_level2 = User.shared?.impInfo?.cities_level2.filter({$0.parent_city == city})
        region_picker.reloadAllComponents()
        if let region = admin?.region, let city_code = cities_level2?.first(where: {$0.name! == region})?.city_code{
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
        cities_level3 = User.shared?.impInfo?.cities_level3.filter({$0.parent_city == region})
        area_picker.reloadAllComponents()
 
        if let area = admin?.area, let city_code = cities_level3?.first(where: {$0.name! == area})?.city_code{
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
