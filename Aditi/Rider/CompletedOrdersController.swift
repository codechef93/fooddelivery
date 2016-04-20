//
//  CompletedOrdersController.swift
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

class CompletedOrdersController: UIViewController, IndicatorInfoProvider  {
    
    @IBOutlet weak var tableView : UITableView!
    var orders = [Order]()
    var listener: ListenerRegistration?
    var cityName : String?
    
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
        navigationItem.title = "完成訂單"
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
            
            var query = ordersCol.whereField("driver.id", isEqualTo: User.shared?.id)
                .whereField("status", isEqualTo: OrderStatus.completed.rawValue)
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
extension CompletedOrdersController : UITableViewDataSource , UITableViewDelegate, OrderCellDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderRiderCell", for: indexPath) as! OrderRiderCell
        cell.setupForOrder(order: orders[indexPath.row], delegate: self)
//        cell.acceptBtn.backgroundColor = .green
//        cell.acceptBtn.setTitle("完成", for: .normal)
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
    func changeStatus(order: Order) {
        
    }
}

extension CompletedOrdersController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noOrders", comment: ""))
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
