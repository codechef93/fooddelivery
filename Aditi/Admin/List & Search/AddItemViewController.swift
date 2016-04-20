//
//  AddItemViewController.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import QuartzCore

class AddItemViewController: UIViewController, ImagePickerPresenting {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var descView: UIView!
    
    @IBOutlet weak var titleField : UITextField!
    @IBOutlet weak var descField : UITextField!
    @IBOutlet weak var categoryField : UITextField!
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var saveBtn : UIButton!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var imageSuperView: UIView!
    @IBOutlet weak var stockView: UIView!
    
    @IBOutlet weak var discountSettingView: UIView!
    @IBOutlet weak var discountInput: UITextField!
    @IBOutlet weak var radioPercent: CheckBox!
    @IBOutlet weak var radioFixed: CheckBox!
    
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var discountField: UITextField!
    
    @IBOutlet weak var couponField: UITextField!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var stockField: UITextField!
    @IBOutlet weak var removeBannerBtn: UIButton!
    
    @IBOutlet weak var sub_product_area: UIStackView!
    @IBOutlet weak var subCatTableView: ContentSizedTableView!
    
    @IBOutlet weak var locationListArea: UIStackView!
    @IBOutlet weak var locationTableView: ContentSizedTableView!
    
    // For Category
    var type : ListType = .category
    var isEdit = false
    var category : Category?
    var locations = [CityItem]()
    var selectedLocations = [CityItem]()
    //For Products
    var product : Product?
    var selectedCategory : Category?
    var categoryList = [Category]()
    var subCatList = [String]()
    var listener : ListenerRegistration?
    
    //For Coupon
    var coupon : Coupon?
    var toDate : Date?
    var fromDate : Date?
    
    var imagePicked = false
    var banner : String?
    
    var isCouponfixed : Bool = false
    
    deinit {
           listener?.remove()
           NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK:- BIND VIEW
    func setupView(){
        
        imgView.layer.cornerRadius = 16
        imgView.layer.borderColor = UIColor.lightGray.cgColor
        imgView.layer.borderWidth = 1
        
        categoryView.isHidden = true
        couponView.isHidden = true
        durationView.isHidden = true
        discountView.isHidden = true
        priceView.isHidden = true
        stockView.isHidden = true
        discountSettingView.isHidden = true
        removeBannerBtn.isHidden = true
        
        discountField.delegate = self
        
        applyBorderToField(textField: titleField)
        applyBorderToField(textField: categoryField)
        applyBorderToField(textField: priceField)
        applyBorderToField(textField: couponField)
        applyBorderToField(textField: discountField)
        applyBorderToField(textField: descField)
        applyBorderToField(textField: stockField)
        applyBorderToField(textField: toField)
        applyBorderToField(textField: fromField)
        applyBorderToField(textField: discountInput)

        sub_product_area.isHidden = true
        locationListArea.isHidden = true
        if type == .category {
            title = NSLocalizedString("addCat", comment: "")
            
            locations = User.shared?.impInfo?.cities_level1 ?? [CityItem]()
            locationListArea.isHidden = false
            let nib = UINib(nibName: "CityCheckCell", bundle: nil)
            locationTableView.register(nib, forCellReuseIdentifier: "CityCheckCell")
            locationTableView.dataSource = self
            locationTableView.delegate = self
            
        }else if type == .product {
            title = NSLocalizedString("addPro", comment: "")
            categoryView.isHidden = false
            discountView.isHidden = false
            priceView.isHidden = false
            stockView.isHidden = false
            getCategoryList()
            categoryField.delegate = self
            
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            categoryField.inputView = picker
            
            
            #if Admin
            if isEdit {
                getSubProductsList(p_id: product!.id)
                
                sub_product_area.isHidden = false
                let nib = UINib(nibName: "SubCategCell", bundle: nil)
                subCatTableView.register(nib, forCellReuseIdentifier: "SubCategCell")
                subCatTableView.dataSource = self
                subCatTableView.delegate = self
            }
            #endif
            
            
        }else if type == .coupon{
            title = NSLocalizedString("addCou", comment: "")
            couponView.isHidden = false
            durationView.isHidden = false
            imageSuperView.isHidden = true
            discountSettingView.isHidden = false
            
            radioPercent.borderStyle = .rounded
            radioPercent.style = .circle
            radioFixed.borderStyle = .rounded
            radioFixed.style = .circle
            radioPercent.isChecked = true
            radioFixed.isChecked = false
            isCouponfixed = false
            
            toField.delegate = self
            fromField.delegate = self
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            toField.inputView = datePicker
            fromField.inputView = datePicker
            datePicker.minimumDate = Date()
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        }else{
            titleView.isHidden = true
            descView.isHidden = true
        }
        
        if isEdit { bindData() }
    }
    
    func applyBorderToField(textField : UITextField){
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 4
    }
    func bindData(){
        if let c = category {
            titleField.text = c.title
            descField.text = c.desc
            imgView.setImage(with: URL(string:c.image))
            title = NSLocalizedString("updCat", comment: "")
            
            selectedLocations = c.cities ?? [CityItem]()
            locationTableView.reloadData()
            
            addDeleteButton()
        }else if let p = product {
            title = NSLocalizedString("updPro", comment: "")
            titleField.text = p.title
            descField.text = p.desc
            imgView.setImage(with: URL(string:p.image))
            priceField.text = p.price
            stockField.text = p.stock
            var discount = p.discount ?? ""
            if discount.count > 0 {
                discount = discount + "%"
            }
            discountField.text = discount
            addDeleteButton()
        }else if let c = coupon {
            title = NSLocalizedString("updCou", comment: "")
            titleField.text = c.title
            descField.text = c.desc
            couponField.text = c.code
            discountInput.text = c.discount
            if c.fixed == true {
                radioFixed.isChecked = true
                radioPercent.isChecked = false
            }
            else
            {
                radioPercent.isChecked = true
                radioFixed.isChecked = false
            }
            isCouponfixed = c.fixed == true
            
            toDate = c.to.dateValue()
            fromDate = c.from.dateValue()
            toField.text = toDate?.toStringwith(format: "dd/MM/yyyy")
            fromField.text = fromDate?.toStringwith(format: "dd/MM/yyyy")
            
            addDeleteButton()
        }else{
            
            if let banner = banner , let url = URL(string: banner){
                removeBannerBtn.isHidden = false
                imgView.setImage(with: url)
                title = NSLocalizedString("updBan", comment: "")
            }else{
                title = NSLocalizedString("addBan", comment: "")
            }
        }
    }
    
    func addDeleteButton(){
        let bbi = UIBarButtonItem(image: UIImage(named: "trashBbi"), style: .done, target: self, action: #selector(deletePressed(_:)))
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func deletePressed(_ bbi : UIBarButtonItem){
        if let c = category {
            deleteCatPressed(category: c)
        }else if let p = product {
            deleteProduct(p: p)
        }
        else if let cp = coupon {
            deleteCoupon(cp: cp)
        }
    }
    
    func deleteCatPressed(category: Category) {
        
        alertWithChoices(message: NSLocalizedString("deleteCategoryMsg", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: { [weak self] in
            self?.deleteCategory(data: ["id":category.id])
        }) {}
    }
    func deleteCategory(data : [String:Any]){
        UIApplication.showLoader()
        NetworkManager.deleteCategory(params: data) { [weak self] (success, msg) in
            if success {
                UIApplication.showSuccess(message: msg, delay: 1)
                self?.navigationController?.popToRootViewController(animated: true)
            }else{
                UIApplication.showError(message: msg, delay: 1)
            }
        }
    }
    func deleteProduct(p : Product){
        alertWithChoices(message: NSLocalizedString("deleteProductMsg", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: { [weak self] in
            UIApplication.showLoader()
            productsCol.document(p.id).delete { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription, delay: 1)
                }else{
                    UIApplication.showSuccess(message: "Product Removed", delay: 1)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }) {}
    }
    
    func deleteCoupon(cp : Coupon){
        alertWithChoices(message: NSLocalizedString("deleteCouponMsg", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: { [weak self] in
            UIApplication.showLoader()
            couponsCol.document(cp.id).delete { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription, delay: 1)
                }else{
                    UIApplication.showSuccess(message: "Coupon Removed", delay: 1)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }) {}
    }
    
    @IBAction func pickImage(_ gesture : UITapGestureRecognizer){
        presentImagePicker { (image) in
            if let i = image {
                self.imgView.image = i
                self.imagePicked = true
            }else{
                self.imagePicked = false
            }
        }
    }
    
    @IBAction func save(_ btn : UIButton){
        if type == .category {
            isEdit ? editCategory() : addCategory()
        }else if type == .product {
            isEdit ? editProduct() : addProduct()
        }else if type == .coupon{
            addUpdateCoupon()
        }else if imagePicked{
            addUpdateBanner()
        }
    }
    
    @IBAction func removeBannerPressed(_ sender: UIButton) {
        removeBanner()
    }
    
    @IBAction func addSubProduct(_ sender: Any) {
        let vc : AddSubProductVC = storyboard!.instantiateViewController()
        vc.isEdit = false
        vc.sub_product_name = ""
        vc.cat_weight = ""
        vc.main_product = product
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPercentCoupon(_ sender: Any) {
        if radioPercent.isChecked {
            radioFixed.isChecked = false
            isCouponfixed = false
        }
    }
    
    @IBAction func onFixedCoupon(_ sender: Any) {
        if radioFixed.isChecked {
            radioPercent.isChecked = false
            isCouponfixed = true
        }
    }
}

//MARK:- CATEGORY CRUD
extension AddItemViewController {
    
    func addCategory(){
        if type == .category {
            guard let title = titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , title.count > 0 else {
                UIApplication.showError(message: Errors.invalidTitleErr)
                return
            }
            if !imagePicked {
                UIApplication.showError(message: Errors.pickImage)
                return
            }
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            
            let name = "\(Date().timeIntervalSince1970).jpg"
            let doc = categoriesCol.document()
            let path = "\(categoriesCol.path)/\(doc.documentID)/\(name)"
            Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
                if let url = url {
                    let new = Category.data(title: title, desc: self?.descField.text, imgUrl: url, id: doc.documentID, cities: self?.selectedLocations)
                    doc.setData(new) { (error) in
                        if let e = error {
                            UIApplication.showError(message: e.localizedDescription)
                        }else{
                            UIApplication.showSuccess(message: Messages.categoryAdded)
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    func editCategory(){
        if let category = category {
            guard let title = titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , title.count > 0 else {
                UIApplication.showError(message: Errors.invalidTitleErr)
                return
            }
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            
            let doc = categoriesCol.document(category.id)
            let name = "\(Int(Date().timeIntervalSince1970)).jpg"
            let path = "\(categoriesCol.path)/\(doc.documentID)/\(name)"
            var data = ["updatedAt" : FieldValue.serverTimestamp(),
                        "title" : title,
                        "desc" : self.descField.text ?? "",
                        "cities" : selectedLocations.map({$0.postBody})
                ] as [String : Any]
            if imagePicked {
                Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
                    if let url = url {
                        data["image"] = url
                        doc.updateData(data, completion: { (error) in
                            if let e = error {
                                UIApplication.showError(message: e.localizedDescription)
                            }else{
                                UIApplication.showSuccess(message: Messages.categoryUpdated)
                                self?.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                }
            }else{
                doc.updateData(data, completion: { [weak self] (error) in
                    if let e = error {
                        UIApplication.showError(message: e.localizedDescription)
                    }else{
                        UIApplication.showSuccess(message: Messages.categoryUpdated)
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
}

//MARK:- PRODUCT CRUD

extension AddItemViewController {
    func addProduct(){
        guard let title = titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , title.count > 0 else {
            UIApplication.showError(message: Errors.invalidTitleErr)
            return
        }
        guard let price = priceField.text , Int(price) != nil, Int(price)! >= 0 else {
            UIApplication.showError(message: Errors.invalidPrice)
            return
        }
        guard let stock = stockField.text , Int(stock) != nil, Int(stock)! >= 0 else {
            UIApplication.showError(message: Errors.invalidStock)
            return
        }
        guard let c = selectedCategory else {
            UIApplication.showError(message: Errors.selectCategory)
            return
        }
        if !imagePicked {
            UIApplication.showError(message: Errors.pickImage)
            return
        }
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        
        let name = "\(Date().timeIntervalSince1970).jpg"
        let doc = productsCol.document()
        let path = "\(productsCol.path)/\(doc.documentID)/\(name)"
        let discount = self.discountField.text?.replacingOccurrences(of: "%", with: "") ?? ""
        Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
            if let url = url {
                let new = Product.data(title: title,
                                       desc: self?.descField.text,
                                       imgUrl: url,
                                       id: doc.documentID,
                                       discount: discount,
                                       price: price,
                                       catId: c.id,
                                       stock: stock
                )
                doc.setData(new) { (error) in
                    if let e = error {
                        UIApplication.showError(message: e.localizedDescription)
                    }else{
                        UIApplication.showSuccess(message: Messages.productAdded)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    func editProduct(){
        if let product = product {
            guard let title = titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , title.count > 0 else {
                UIApplication.showError(message: Errors.invalidTitleErr)
                return
            }
            guard let price = priceField.text , Int(price) != nil, Int(price)! >= 0 else {
                UIApplication.showError(message: Errors.invalidPrice)
                return
            }
            guard let c = selectedCategory else {
                UIApplication.showError(message: Errors.selectCategory)
                return
            }
            guard let stock = stockField.text , Int(stock) != nil, Int(stock)! >= 0 else {
                UIApplication.showError(message: Errors.invalidStock)
                return
            }
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            
            let doc = productsCol.document(product.id)
            let name = "\(Int(Date().timeIntervalSince1970)).jpg"
            let path = "\(productsCol.path)/\(product.id)/\(name)"
            let discount = self.discountField.text?.replacingOccurrences(of: "%", with: "") ?? ""
            var data = ["updatedAt" : FieldValue.serverTimestamp(),
                        "title" : title,
                        "desc" : self.descField.text ?? "",
                        "price" : price,
                        "catId" : c.id,
                        "stock" : stock,
                        "discount" : discount] as [String : Any]
            if imagePicked {
                Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
                    if let url = url {
                        data["image"] = url
                        doc.updateData(data, completion: { (error) in
                            if let e = error {
                                UIApplication.showError(message: e.localizedDescription)
                            }else{
                                UIApplication.showSuccess(message: Messages.productUpdated)
                                self?.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                }
            }else{
                
                doc.updateData(data, completion: { [weak self] (error) in
                    if let e = error {
                        UIApplication.showError(message: e.localizedDescription)
                    }else{
                        UIApplication.showSuccess(message: Messages.productUpdated)
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
}

//MARK:- COUPON CRUD

extension AddItemViewController {
    
    func addUpdateCoupon(){
        guard let title = titleField.text , title.count > 2 else {
            UIApplication.showError(message: Errors.invalidTitleErr)
            return
        }
        guard let code = couponField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), code.count > 2  else {
            UIApplication.showError(message: Errors.invalidCoupon)
            return
        }
        guard let discount = discountInput.text?.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            (Int(discount) ?? 0) > 0  else {
            UIApplication.showError(message: Errors.invalidDiscount)
            return
        }
        guard let fromDate = self.fromDate else {
            UIApplication.showError(message: Errors.fromDate)
            return
        }
        guard let toDate = self.toDate  else {
            UIApplication.showError(message: Errors.toDate)
            return
        }
        if fromDate > toDate {
            UIApplication.showError(message: Errors.invalidDates)
            return
        }

        if AppDelegate.noInternet() {return}
        var doc : DocumentReference!
        if let c = coupon {
            doc = couponsCol.document(c.id)
        }else{
            doc = couponsCol.document()
        }
        var data = Coupon.data(title: title,
                               desc: descField.text ?? "",
                               id: doc.documentID,
                               discount: discount,
                               fixed: isCouponfixed,
                               to: toDate,
                               from: fromDate,
                               code: code)
        UIApplication.showLoader()
        if isEdit{
            data.removeValue(forKey: "createdAt")
            couponsCol.document(doc.documentID).updateData(data) { [weak self] (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription)
                }else{
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            couponsCol.document(doc.documentID).setData(data) { [weak self] (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription)
                }else{
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

//MARK:- BANNER UPDATE

extension AddItemViewController {
    func addUpdateBanner(){
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        let path = "Contents/banner/banner.jpg"
        let doc = contentsCol.document(Content.notes.rawValue)
        Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
            if let url = url {
                doc.updateData(["banner": url], completion: { (error) in
                    if let e = error {
                        UIApplication.showError(message: e.localizedDescription)
                    }else{
                        UIApplication.showSuccess(message: Messages.bannerUpdated)
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    func removeBanner(){
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        let doc = contentsCol.document(Content.notes.rawValue)
        doc.updateData(["banner": FieldValue.delete()], completion: { [weak self] (error) in
            if let e = error {
                UIApplication.showError(message: e.localizedDescription)
            }else{
                UIApplication.showSuccess(message: Messages.bannerRemoved)
                self?.navigationController?.popViewController(animated: true)
            }
        })
    }
}

extension AddItemViewController : UITableViewDataSource , UITableViewDelegate, CityCheckCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == locationTableView)
        {
            return locations.count
        }
        return subCatList.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == locationTableView)
        {
            let cell = locationTableView.dequeueReusableCell(withIdentifier: "CityCheckCell", for: indexPath) as! CityCheckCell
            
            cell.setCity(cityItem: locations[indexPath.row], delegate: self)
            cell.selectionStyle = .none
            
            let index = selectedLocations.firstIndex(where: {$0.city_code == locations[indexPath.row].city_code })
            if index != nil {
                cell.checkbox.isChecked = true
            }
            else {
                cell.checkbox.isChecked = false
            }
            
            return cell
        }
        
        let cell = subCatTableView.dequeueReusableCell(withIdentifier: "SubCategCell", for: indexPath) as! SubCategCell
        let tmpArr = subCatList[indexPath.row].components(separatedBy: "=@=")
        cell.setName(name: tmpArr[0])
        cell.selectionStyle = .gray
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == locationTableView)
        {
            return
        }
        let vc : AddSubProductVC = storyboard!.instantiateViewController()
        vc.isEdit = true
        vc.main_product = product
        
        let subCat = subCatList[indexPath.row]
        let tmpArr = subCat.components(separatedBy: "=@=")
        vc.sub_product_name = tmpArr[0]
        vc.cat_weight = tmpArr.count > 1 ? tmpArr[1] : ""
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == locationTableView)
        {
            return 55
        }
        return 60
    }
 
    func onSelectCity(city: CityItem, status: Bool) {
        if status {
            selectedLocations.append(city)
        }
        else {
            let index = selectedLocations.firstIndex(where: {$0.city_code == city.city_code })
            if index != nil {
                selectedLocations.remove(at: index!)
            }
        }
        
    }
}
