//
//  OrderDetailsController.swift
//  AditiInternal
//
//  Created by macbook on 18/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class OrderDetailsController: UIViewController, QrScannerVcDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton : UIButton!
    @IBOutlet weak var totalLbl: UILabel!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var customerNameView: UIView!
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var phoneNoView: UIView!
    @IBOutlet weak var phoneNoLbl: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var orderQtyLbl: UILabel!
    
    @IBOutlet weak var customerStack: UIStackView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView : UIScrollView!
    
    @IBOutlet weak var dateTitleLbl: UILabel!
    @IBOutlet weak var timeTitleLbl: UILabel!
    @IBOutlet weak var paymentType: UILabel!
    
    var order : Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "訂單詳細"
        let nib = UINib(nibName: "OrderDetailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderDetailCell")
        tableView.separatorColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableViewHeight.constant = 1000
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height

        
        #if User
        confirmButton.isHidden = true
        customerStack.isHidden = true
        addQRButton()
        #elseif Admin
        confirmButton.isHidden = true
        #else
        timeView.isHidden = false
        #endif
        if order.status == .new {
            confirmButton.setTitle("接受", for: .normal)
        }
        if order.status == .inprogress {
            confirmButton.setTitle("完成交付", for: .normal)
        }
        if order.status == .completed {
            confirmButton.isHidden = true
            dateTitleLbl.text = "完成日期"
            timeTitleLbl.text = "完成時間"
        }
        totalLbl.text = "$"+order.total.replacingOccurrences(of: ".0", with: "")
        
        
        if(order.order_date != nil)
        {
            dateLbl.text = Date(timeIntervalSince1970: Double(order.order_date! / 1000)).toStringwith(format: DateFormats.onlyDate)
            timeLbl.text = Date(timeIntervalSince1970: Double(order.order_date! / 1000)).toStringwith(format: DateFormats.onlyTime)
        }
        else {
            dateLbl.text = ""
            timeLbl.text = ""
        }
        var address_txt = ""
        if (order.customer.address != nil)
        {
            address_txt = address_txt + order.customer.address! + ", "
        }
        if (order.customer.city != nil)
        {
            address_txt = address_txt + order.customer.city! + ", "
        }
        if (order.customer.region != nil)
        {
            address_txt = address_txt + order.customer.region! + ", "
        }
        if (order.customer.area != nil)
        {
            address_txt = address_txt + order.customer.area!
        }
        
        customerNameLbl.text = order.customer.displayName
        phoneNoLbl.text = order.customer.phone
        addressLbl.text = address_txt
        orderNoLbl.text = order.cellTitle
        orderQtyLbl.text = order.itemsQty
        paymentType.text = order.cod == true ? "貨到付款" : "卡"
    }

    @IBAction func confirmPressed(_ sender: AppColorBgButton) {
//        let vc = QRscannerViewController()
//        vc.scanner_delegate = self
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.modalTransitionStyle = .crossDissolve
//        present(vc, animated: true, completion: nil)
        let vc = QRscannerViewController()
        vc.scanner_delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func qrcodeCaptured(qrcode: String) {
        if AppDelegate.noInternet() {return}
        
        var qr_string = "\(order!.id)=\(order!.status.rawValue)"
        if (qr_string != qrcode) {
            let ac = UIAlertController(title: "Warning!", message: "This order does not mismatch with the scanned qrcode!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        var statusUpdate = OrderStatus.inprogress.rawValue
        if order.status == .inprogress {
            statusUpdate = OrderStatus.completed.rawValue
        }
        let update = ["status" : statusUpdate,
                      "driver" : User.shared!.firestoreBody,
                      "updatedAt" : FieldValue.serverTimestamp()] as [String : Any]
        UIApplication.showLoader()
        ordersCol.document(order.id).updateData(update) { [weak self] (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription, delay: 1)
            }else{
                if self?.order.status == .new {
                    UIApplication.showSuccess(message: Messages.orderAccepted, delay: 1)
                }else{
                    UIApplication.showSuccess(message: Messages.orderCompleted, delay: 1)
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func errorFromScanner(error: String) {
        let ac = UIAlertController(title: error, message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func addQRButton(){
        #if User
        let bbi = UIBarButtonItem(image: UIImage(named: "qrc_icon"), style: .done, target: self, action: #selector(qrPressed))
        
        navigationItem.rightBarButtonItem = bbi
        #endif
    }

    @objc func qrPressed(_ bbi : UIBarButtonItem){
        #if User
        let vc : QRcodeViewController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        vc.order = order
        navigationController?.pushViewController(vc, animated: true)
        #endif
    }
    
}
extension OrderDetailsController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell", for: indexPath) as! OrderDetailCell
        cell.selectionStyle = .none
        let cartItem = order.products[indexPath.row]
        cell.setupWithOrder(cartItem: cartItem)
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        var h = 50 + CGFloat(order.products[indexPath.row].subProducts.count) * 42
        if order.products[indexPath.row].note != nil && order.products[indexPath.row].note != "" {
            h = h + estimatedHeightOfLabel(text: order.products[indexPath.row].note!) + 20
        }
        return h
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {

        let size = CGSize(width: view.frame.width - 50, height: 1600)

        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height

        return rectangleHeight
    }
    
}

