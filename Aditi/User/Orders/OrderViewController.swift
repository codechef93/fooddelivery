//
//  OrderViewController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CodableFirebase
import FirebaseFirestore
import XLPagerTabStrip

class OrderViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notesLbl: UILabel!
    var orders = [Order]()
    var isHistory = false
    var listener : ListenerRegistration?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addRightBarBtns()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "OrderCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderCell")
        tableView.separatorColor = .clear
        tableView.emptyDataSetSource = nil
        tableView.reloadData()
        
        if isHistory {
            getOrderHistory()
        }else{
            getCurrentOrders()
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: isHistory ? "訂單紀錄" :  "我的訂單") //History : Myorders
    }
    @IBAction func showCart(_ sender: UITapGestureRecognizer) {
        let cartVc : CartViewController = UIStoryboard(storyboard: .cart).instantiateViewController()
        UIApplication.topViewController().navigationController?.pushViewController(cartVc, animated: true)
    }
    deinit {
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    //MARK:- FIRESTORE CALLS
    func getCurrentOrders(){
        UIApplication.showLoader()
        listener = ordersCol
            .whereField("customer.id", isEqualTo: User.shared!.id)
            .whereField("status", isGreaterThanOrEqualTo: OrderStatus.new.rawValue)
            .whereField("status", isLessThanOrEqualTo: OrderStatus.inprogress.rawValue)
            .addSnapshotListener { [weak self] (querySnap, err) in
                UIApplication.hideLoader()
                self?.tableView.emptyDataSetSource = self
                guard let snap = querySnap else {
                    return
                }
                snap.documentChanges.forEach { (diff) in
                    if diff.document.metadata.hasPendingWrites {return}
                    let data = diff.document.data()
                    guard let order = try? FirestoreDecoder().decode(Order.self, from: data) else{
                        print("Error while decoding Order")
                        return
                    }
                    if diff.type == .added {
                        self?.orders.append(order)
                    }
                    if diff.type == .modified {
                        if let i = self?.orders.firstIndex(where: { $0.id ==  order.id}) {
                            self?.orders[i] = order
                        }else{
                            self?.orders.append(order)
                        }
                    }
                    if diff.type == .removed {
                        if let i = self?.orders.firstIndex(where: { $0.id ==  order.id}) {
                            self?.orders.remove(at: i)
                        }
                    }
                }
                self?.orders = self!.orders.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() })
                self?.tableView.reloadData()
        }
    }
    func getOrderHistory(){
        listener = ordersCol
            .whereField("customer.id", isEqualTo: User.shared!.id)
            .whereField("status", isEqualTo: OrderStatus.completed.rawValue)
            .addSnapshotListener { [weak self] (querySnap, err) in
                self?.tableView.emptyDataSetSource = self
                guard let snap = querySnap else {return}
                snap.documentChanges.forEach { (diff) in
                    if diff.document.metadata.hasPendingWrites {return}
                    let data = diff.document.data()
                    guard let order = try? FirestoreDecoder().decode(Order.self, from: data) else{
                        print("Error while decoding Order")
                        return
                    }
                    if diff.type == .added {
                        self?.orders.append(order)
                    }
                    if diff.type == .modified {
                        if let i = self?.orders.firstIndex(where: { $0.id ==  order.id}) {
                            self?.orders[i] = order
                        }else{
                            self?.orders.append(order)
                        }
                    }
                    if diff.type == .removed {
                        if let i = self?.orders.firstIndex(where: { $0.id ==  order.id}) {
                            self?.orders.remove(at: i)
                        }
                    }
                }
                self?.orders = self!.orders.sorted(by: { (order1, order2) -> Bool in
                    if let up1 = order1.updatedAt?.dateValue(), let up2 = order2.updatedAt?.dateValue() {
                        return up1 > up2
                    }
                    return order1.createdAt.dateValue() > order2.createdAt.dateValue()
                })
                self?.tableView.reloadData()
        }
    }
}

extension OrderViewController : UITableViewDataSource , UITableViewDelegate, OrderCellDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        let order = orders[indexPath.row]
        cell.setupForOrder(order: order , isHistory: isHistory, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        let vc : OrderDetailsController = UIStoryboard(storyboard: .riders).instantiateViewController()
        vc.order = order
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func changeStatus(order: Order) {
        
    }
}

extension OrderViewController : DZNEmptyDataSetSource {
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
