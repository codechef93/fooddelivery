//
//  OrdersAdminViewController.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import CodableFirebase
import FirebaseFirestore
import DZNEmptyDataSet


class OrdersAdminViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var searchField: UITextField!
    
    var allOrders = [Order]()
    var orders = [Order]()
    var selectedIndex = 0
    var listener  : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("orders", comment: "")
        setupViews()
        getOrders()
        tableView.emptyDataSetSource = self
        tableView.separatorColor = .clear
        searchField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
    }
    
    @objc func reload(){
        orders = []
        allOrders = []
        listener?.remove()
        getOrders()
    }
    func setupViews(){
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        textField.inputView = picker
        picker.reloadAllComponents()
        textField.delegate = self
        selectOrderStatus(index: 0)
    }
    func getOrders(){
        UIApplication.showLoader()
        listener = ordersCol.addSnapshotListener { [weak self] (querySnap, err) in
            UIApplication.hideLoader()
            guard let snap = querySnap, let weakSelf = self else {return}
            snap.documentChanges.forEach { diff in
                let data = diff.document.data()
                do {
                    let order = try FirestoreDecoder().decode(Order.self, from: data)
                    if (diff.type == .added) || (diff.type == .modified) {
                        if let index =  weakSelf.allOrders.firstIndex(where: { $0.id == order.id }) {
                            weakSelf.allOrders[index] = order
                        }else{
                            weakSelf.allOrders.append(order)
                        }
                    }
                }catch{
                    print(error)
                }
            }
            weakSelf.selectOrderStatus(index: weakSelf.selectedIndex)
        }
    }
    deinit {
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
}

extension OrdersAdminViewController : UIPickerViewDataSource , UIPickerViewDelegate, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return OrderStatus.allCases.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return OrderStatus.allCases[row].title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectOrderStatus(index: row)
    }
    func selectOrderStatus(index : Int){
        selectedIndex = index
        textField.text = OrderStatus.allCases[index].title
        var orders = allOrders
        if let text = searchField.text , text.count > 0 {
            orders = orders.filter({ $0.cellTitle.lowercased().contains(text.lowercased()) })
        }
        orders = orders.filter({ $0.status.rawValue == selectedIndex })
        orders = orders.sorted(by: { (order1, order2) -> Bool in
            if let up1 = order1.updatedAt?.dateValue(), let up2 = order2.updatedAt?.dateValue() {
                return up1 > up2
            }
            return order1.createdAt.dateValue() > order2.createdAt.dateValue()
        })
        self.orders = orders
        tableView.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    @objc func textChanged(_ textField : UITextField){
        tableView.reloadData()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableView.reloadData()
    }
}

extension OrdersAdminViewController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let order = orders[indexPath.row]
        
        let orderNoLbl   = cell.viewWithTag(1) as! UILabel
        let cityNameLbl = cell.viewWithTag(2) as! UILabel
        let dateLbl     = cell.viewWithTag(3) as! UILabel
        let priceLbl    = cell.viewWithTag(4) as! UILabel
        
        if(order.order_date != nil)
        {
            dateLbl.text =  Date(timeIntervalSince1970: Double(order.order_date! / 1000)).toStringwith(format: DateFormats.dateAndTime)
        }
        else {
            dateLbl.text = ""
        }
        
        orderNoLbl.text = order.cellTitle
        cityNameLbl.text = order.customer.city
        priceLbl.text = "$\(order.total)".replacingOccurrences(of: ".0", with: "")
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        let vc : OrderDetailsController = UIStoryboard(storyboard: .riders).instantiateViewController()
        vc.order = order
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
extension OrdersAdminViewController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrStr = NSAttributedString(string: NSLocalizedString("noOrders", comment: ""))
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
