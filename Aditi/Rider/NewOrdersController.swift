//
//  NewOrdersController.swift
//  AditiInternal
//
//  Created by macbook on 18/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CodableFirebase
import FirebaseFirestore
import XLPagerTabStrip

class NewOrdersController: UIViewController, IndicatorInfoProvider{

    @IBOutlet weak var tableView : UITableView!
    var orders = [Order]()
    var listener : ListenerRegistration?
    var cityName : String?
    var curQrOrder : Order!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "OrderRiderCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderRiderCell")
        tableView.separatorColor = .clear
        tableView.emptyDataSetSource = nil
        tableView.reloadData()
        navigationItem.title = "最新訂單"
        addChatBtn()
        getOrders()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
    }
    
    
    
    @objc func reload(){
        if AppDelegate.hasInternet {
            listener?.remove()
            getOrders()
        }
    }
    
    func getOrders(){
        var showingLoader = true
        
        var query = ordersCol.whereField("status", isEqualTo: OrderStatus.new.rawValue)
            
        if (User.shared!.level == "level1")
        {
            query = query.whereField("customer.city", isEqualTo: User.shared?.city)
        }
        else if (User.shared!.level == "level2")
        {
            query = query.whereField("customer.city", isEqualTo: User.shared?.city)
                .whereField("customer.region", isEqualTo: User.shared?.region)
            if cityName != "所有" {
                query = query.whereField("customer.area", isEqualTo: cityName)
            }
        }
        else if (User.shared!.level == "level3")
        {
            query = query.whereField("customer.city", isEqualTo: User.shared?.city)
            .whereField("customer.region", isEqualTo: User.shared?.region)
                .whereField("customer.area", isEqualTo: User.shared?.area)
        }
        else {
            return
        }
        
        UIApplication.showLoader()
        
        listener = query
            .addSnapshotListener { [weak self] (querySnap, err) in
                if showingLoader {
                    showingLoader = false
                    UIApplication.hideLoader()
                }
                self?.tableView.emptyDataSetSource = self
                guard let snap = querySnap else {return}
                
                self!.orders.removeAll()
                snap.documentChanges.forEach { diff in
                    let data = diff.document.data()
                    do {
                        let order = try FirestoreDecoder().decode(Order.self, from: data)
                        self?.orders.append(order)
//                        if (diff.type == .added) || (diff.type == .modified) {
//                            if let index =  self?.orders.firstIndex(where: { $0.id == order.id }) {
//                                self?.orders[index] = order
//                            }else{
//                                self?.orders.append(order)
//                            }
//                        }
//                        if (diff.type == .removed) {
//                            if let index =  self?.orders.firstIndex(where: { $0.id == order.id }) {
//                                self?.orders.remove(at: index)
//                            }
//                        }
                    }catch{
                        print(error)
                    }
                }
                self?.orders = self?.orders.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue()  }) ?? []
                self?.tableView.reloadData()
        }
    }
    deinit {
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: cityName)
    }
}

extension NewOrdersController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderRiderCell", for: indexPath) as! OrderRiderCell
        let order = orders[indexPath.row]
        cell.setupForOrder(order: order, delegate: self)
//        cell.acceptBtn.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVc : OrderDetailsController = storyboard!.instantiateViewController()
        detailVc.order = orders[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}


extension NewOrdersController : OrderCellDelegate {
    func changeStatus(order : Order){
        curQrOrder = order
        let vc = QRscannerViewController()
        vc.scanner_delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NewOrdersController : QrScannerVcDelegate {
    func qrcodeCaptured(qrcode: String) {
        
        let qr_string = "\(curQrOrder.id)=\(curQrOrder.status.rawValue)"
        if (qr_string != qrcode) {
            let ac = UIAlertController(title: "Warning!", message: "This order does not mismatch with the scanned qrcode!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        let update = [
            "status" : OrderStatus.inprogress.rawValue,
            "driver" : User.shared!.firestoreBody,
            "updatedAt" : FieldValue.serverTimestamp()
            ] as [String : Any]
        ordersCol.document(curQrOrder.id).updateData(update) { (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription, delay: 1)
            }else{
                UIApplication.showSuccess(message: Messages.orderAccepted, delay: 1)
            }
        }
    }
    
    func errorFromScanner(error: String) {
        let ac = UIAlertController(title: error, message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension NewOrdersController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string:NSLocalizedString("noOrders", comment: ""))
        return attrStr
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: "")
        return attrStr
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty_orders")!
    }
}
