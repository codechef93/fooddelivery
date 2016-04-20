//
//  AdminListController.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import DZNEmptyDataSet

struct AdminListItem : Codable {
    let name : String
    let lastSeen : Timestamp?
    let online : Bool
    let id : String
    let phone : String
    let email : String
    let superAdmin : Bool?
    let can_admins : Bool?
    let can_category : Bool?
    let can_product : Bool?
    let can_chat : Bool?
    let can_order : Bool?
    let can_coupon : Bool?
    let can_content : Bool?
    let can_drivers : Bool?
    let can_city : Bool?
    let can_fcm : Bool?
    
    var city: String?
    var region: String?
    var area : String?
    var level : String?
    
    var seen : String? {
        if let time = lastSeen {
            return "最後上線日期 \(time.dateValue().toStringwith(format: "dd/MM/yyyy hh:mm a"))"
        }
        return nil
    }
}

class AdminListController: UITableViewController {

    var admins = [AdminListItem]()
    var forDrivers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = forDrivers ? "通訊" : "管理员"
        tableView.showsVerticalScrollIndicator = false
        tableView.emptyDataSetSource = self
        tableView.separatorColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAdminList()
    }
    
    @objc func reload(){
        admins = [AdminListItem]()
        getAdminList()
    }
    
    func getAdminList(){
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        admins = []
        let col = forDrivers ? driversCol : adminsCol
        col.getDocuments { [weak self] (querySnap, err) in
            UIApplication.hideLoader()
            guard let snap = querySnap else {
                return
            }
            snap.documents.forEach({
                if let admin = try? FirestoreDecoder().decode(AdminListItem.self, from: $0.data()){
                    self?.admins.append(admin)
                }
            })
            self?.tableView.reloadData()
        }
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

extension AdminListController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return admins.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let admin = admins[indexPath.row]
        
        cell.textLabel?.text = admin.name
        cell.detailTextLabel?.text = admin.seen
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        if admin.online {
            view.backgroundColor = UIColor(hexString: "#00b300")
        }else{
            view.backgroundColor = UIColor(hexString: "#cd3232")
        }
        cell.accessoryView = view
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor =  .lightGray
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : AccountViewController = UIStoryboard(storyboard: .usertabbar).instantiateViewController()
        vc.isAdminDetail = true
        vc.admin = admins[indexPath.row]
        vc.forDriver = forDrivers
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
extension AdminListController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: forDrivers ? NSLocalizedString("noDrivers", comment: "") : NSLocalizedString("noAdmins", comment: ""))
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
