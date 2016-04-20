//
//  ListAndSearchVc.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import CodableFirebase
import DZNEmptyDataSet

enum ListType {
    case category
    case product
    case coupon
    case banner
}

class ListAndSearchVc: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var addButton : UIButton!
    @IBOutlet weak var btnHeight : NSLayoutConstraint!
    var type : ListType = .category
    
    var categories = [Category]()
    var searchedCategories = [Category]()
    
    var products = [Product]()
    var searchedProducts = [Product]()
    
    var coupons = [Coupon]()
    var searchedCoupons = [Coupon]()
    var openKeyboard = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "OrderCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderCell")
        tableView.reloadData()
        tableView.separatorColor = .clear
        tableView.emptyDataSetSource = self
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
        if openKeyboard {
            btnHeight.constant = 0
            textField.becomeFirstResponder()
        }
    }
    
    @objc func reload(){
        setupView()
    }
    
    func setupView(){
        textField.text = ""
        if type == .category {
            title = "類別"
            textField.placeholder = "搜尋類別/"
            addButton.setTitle("新增類別", for: .normal)
        }else if type == .product {
            title = "產品"
            textField.placeholder = "搜尋產品"
            addButton.setTitle("新增產品", for: .normal)
        }else{
            title = "優惠碼"
            textField.placeholder  =  "搜尋優惠碼"
            addButton.setTitle("新增優惠碼", for: .normal)
        }
        categories = [Category]()
        searchedCategories = [Category]()
        
        products = [Product]()
        searchedProducts = [Product]()
        
        coupons = [Coupon]()
        searchedCoupons = [Coupon]()
        getData()
        
        addButton.isHidden = !AppDelegate.hasInternet
        #if User
        addButton.isHidden = true
        #endif
    }
    @objc func textDidChange(_ textField: UITextField){
        guard let text = textField.text else {return}
        if type == .category {
            searchedCategories = categories.filter({ $0.title.lowercased().contains(text) })
        }else if type == .product {
            searchedProducts = products.filter({ $0.title.lowercased().contains(text) })
        }else{
            searchedCoupons = coupons.filter({ $0.title.lowercased().contains(text) })
        }
        tableView.reloadData()
    }
    
    @IBAction func addPressed(_ btn : UIButton){
        let addItemVc : AddItemViewController = storyboard!.instantiateViewController()
        addItemVc.type = type
        navigationController?.pushViewController(addItemVc, animated: true)
    }
    
    func isSearching() -> Bool {
        guard let text = textField.text , text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else{
            return false
        }
        return true
    }
}


extension ListAndSearchVc : UITableViewDataSource , UITableViewDelegate, OrderCellDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == .category {
            return isSearching() ? searchedCategories.count : categories.count
        }
        else if type == .product {
            return isSearching() ? searchedProducts.count : products.count
        }
        return isSearching() ? searchedCoupons.count : coupons.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if type == .coupon {
            let cell = tableView.dequeueReusableCell(withIdentifier: "couponCell")!
            let titleLbl = cell.viewWithTag(1) as! UILabel
            let descLbl = cell.viewWithTag(2) as! UILabel
            let dateLbl = cell.viewWithTag(3) as! UILabel
            let coupon = isSearching() ? searchedCoupons[indexPath.row] : coupons[indexPath.row]
            titleLbl.text = coupon.title
            descLbl.text = coupon.desc
            dateLbl.text = coupon.createdAt.dateValue().toStringwith(format: "dd-MM-yyyy")
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        if type == .category {
            let category = isSearching() ? searchedCategories[indexPath.row] : categories[indexPath.row]
            cell.setupForCategory(category: category,delegate : self)
        }else if type == .product {
            let product = isSearching() ? searchedProducts[indexPath.row] : products[indexPath.row]
            cell.setupForProduct(product : product)
        }
        cell.acceptBtn.isHidden = true
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        #if User
        let vc : ItemDetailController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        vc.product = isSearching() ? searchedProducts[indexPath.row] : products[indexPath.row]
        vc.category = UserTabbarController.shared?.categories.first(where: { $0.id == vc.product.catId })
        navigationController?.pushViewController(vc, animated: true)
        textField.endEditing(true)
        return
        #endif
        
        
        if type == .category {
            let vc : AddItemViewController = storyboard!.instantiateViewController()
            let category = isSearching() ? searchedCategories[indexPath.row] : categories[indexPath.row]
            vc.category = category
            vc.isEdit = true
            navigationController?.pushViewController(vc, animated: true)
        }else if type == .product {
            let vc : AddItemViewController = storyboard!.instantiateViewController()
            let product = isSearching() ? searchedProducts[indexPath.row] : products[indexPath.row]
            vc.product = product
            vc.isEdit = true
            vc.type = .product
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc : AddItemViewController = storyboard!.instantiateViewController()
            let coupon = isSearching() ? searchedCoupons[indexPath.row] : coupons[indexPath.row]
            vc.coupon = coupon
            vc.isEdit = true
            vc.type = .coupon
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if type == .coupon {return 90}
        return 150
    }
    // Order Cell Delegate
    func deleteCatPressed(category: Category) {
        alertWithChoices(message: NSLocalizedString("deleteCategoryMsg", comment: ""), yesBtnTitle:  NSLocalizedString("yes", comment: ""), noBtnTitle:  NSLocalizedString("no", comment: ""), yesaction: { [weak self] in
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
}


//MARK:- FIRESTORE CALLS

extension ListAndSearchVc {
    
    func getData(){
        UIApplication.showLoader()
        if type == .category {
            getCategories()
        }else if type == .product {
            getProducts()
        }else{
            getCoupons()
        }
    }
    
    func getCategories(){
        categories = [Category]()
        categoriesCol.getDocuments { [weak self] (snap, err) in
            UIApplication.hideLoader()
            guard let documents = snap?.documents, let weakSelf = self else {
                self?.tableView.reloadData()
                UIApplication.showSuccess(message: "找不到分類")
                return
            }
            documents.forEach { (snap) in
                if let category = try? FirestoreDecoder().decode(Category.self, from: snap.data()){
                    weakSelf.categories.append(category)
                }else{
                    print("error while decoding")
                }
            }
            weakSelf.tableView.reloadData()
        }
    }
    func getProducts(){
        products = [Product]()
        productsCol.getDocuments { [weak self] (snap, err) in
            UIApplication.hideLoader()
            guard let documents = snap?.documents, let weakSelf = self else {
                self?.tableView.reloadData()
                UIApplication.showSuccess(message: "找不到產品")
                return
            }
            documents.forEach { (snap) in
                if let product = try? FirestoreDecoder().decode(Product.self, from: snap.data()){
                    weakSelf.products.append(product)
                }else{
                    print("error while decoding")
                }
            }
            self!.products = self!.products.sorted(by: { $0.title < $1.title })
            weakSelf.tableView.reloadData()
        }
    }
    func getCoupons(){
        coupons = [Coupon]()
        couponsCol.getDocuments { [weak self] (snap, err) in
            self?.tableView.reloadData()
            UIApplication.hideLoader()
            guard let documents = snap?.documents, let weakSelf = self else {
                UIApplication.showSuccess(message: "找不到優惠券")
                return
            }
            documents.forEach { (snap) in
                if let coupon = try? FirestoreDecoder().decode(Coupon.self, from: snap.data()){
                    weakSelf.coupons.append(coupon)
                }else{
                    print("error while decoding")
                }
            }
            weakSelf.tableView.reloadData()
        }
    }
}

extension ListAndSearchVc : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noItems", comment: ""))
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
