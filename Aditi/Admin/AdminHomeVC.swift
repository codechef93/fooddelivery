//
//  AdminHomeVC.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseAuth

class AdminHomeVC: UIViewController, UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var tableView : UITableView!
    let uiswitch = MJMaterialSwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
    
//    var items = ["管理員", "類別", "產品", "聊天", "訂單", "優惠碼", "內容", "Drivers", "地區", "上線", "登出"]
//    var items_chinese = ["管理員", "類別", "產品", "通訊", "訂單", "優惠碼", "內容", "送遞員", "地區", "上線", "登出"]
    
    var enabled_items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("adminPanel", comment: "")
        getEnabledItems()
    }
    
    override func chat() {
        let chatListVC : ChatListViewController = UIStoryboard(storyboard: .chat).instantiateViewController()
        navigationController?.pushViewController(chatListVC, animated: true)
    }
    
    func getEnabledItems() {
        if User.shared?.superAdmin == true {
            enabled_items = ["管理員", "類別", "產品", "通訊", "訂單", "優惠碼", "內容", "送遞員", "地區", "發放通知", "上線", "登出"]
            tableView.reloadData()
            return
        }
        if User.shared?.can_admins == true {
            enabled_items.append("管理員")
        }
        if User.shared?.can_category == true {
            enabled_items.append("類別")
        }
        if User.shared?.can_product == true {
            enabled_items.append("產品")
        }
        if User.shared?.can_chat == true {
            enabled_items.append("通訊")
        }
        if User.shared?.can_order == true {
            enabled_items.append("訂單")
        }
        if User.shared?.can_coupon == true {
            enabled_items.append("優惠碼")
        }
        if User.shared?.can_content == true {
            enabled_items.append("內容")
        }
        if User.shared?.can_drivers == true {
            enabled_items.append("送遞員")
        }
        if User.shared?.can_city == true {
            enabled_items.append("地區")
        }
        if User.shared?.can_fcm == true {
            enabled_items.append("發放通知")
        }
        
        enabled_items.append("上線")
        enabled_items.append("登出")
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enabled_items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let item = enabled_items[indexPath.row]
        let label = cell.viewWithTag(1) as? UILabel
        label?.text = item
        
        cell.accessoryType = .none
        if item == "上線" { //Online
            cell.accessoryType = .none
            uiswitch.isRippleEnabled = true
            uiswitch.isUserInteractionEnabled = true
            uiswitch.isOn = User.shared?.online ?? false
            uiswitch.setStatus()
            uiswitch.removeTarget(self, action: #selector(updateOnlineStatus(_:)), for: .valueChanged)
            uiswitch.addTarget(self, action: #selector(updateOnlineStatus(_:)), for: .valueChanged)
            cell.accessoryView = uiswitch
        }
        cell.selectionStyle = .none
        return cell
    }
    @objc func updateOnlineStatus(_ uiSwitch : MJMaterialSwitch){
        
        let msg = (User.shared?.online ?? false) == true ? NSLocalizedString("goOffline", comment: "") : NSLocalizedString("goOnline", comment: "")
        alertWithChoices(with: NSLocalizedString("changeStatus", comment: ""), message: msg, yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle:  NSLocalizedString("no", comment: ""), yesaction: {
            UIApplication.showLoader()
            User.shared?.toggleOnline(online: uiSwitch.isOn, completion: { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription)
                }else{
                    UIApplication.hideLoader()
                }
            })
        }, noaction: { [weak self] in
            self?.tableView.reloadData()
        })
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = enabled_items[indexPath.row]
        if item == "管理員" {
            let adminList = AdminListController()
            adminList.forDrivers = false
            navigationController?.pushViewController(adminList, animated: true)
        }
        if item == "類別" {
            let listSearchVc : ListAndSearchVc = UIStoryboard(storyboard: .admin).instantiateViewController()
            navigationController?.pushViewController(listSearchVc, animated: true)
        }
        if item == "產品" {
            let listSearchVc : ListAndSearchVc = UIStoryboard(storyboard: .admin).instantiateViewController()
            listSearchVc.type = .product
            navigationController?.pushViewController(listSearchVc, animated: true)
        }
        if item == "通訊" {
            let chatVc : ChatListViewController = UIStoryboard(storyboard: .chat).instantiateViewController()
            navigationController?.pushViewController(chatVc, animated: true)
        }
        if item == "訂單" {
            let ordersList : OrdersAdminViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
            navigationController?.pushViewController(ordersList, animated: true)
        }
        if item == "優惠碼" {
            let listSearchVc : ListAndSearchVc = UIStoryboard(storyboard: .admin).instantiateViewController()
            listSearchVc.type = .coupon
            navigationController?.pushViewController(listSearchVc, animated: true)
        }
        if item == "內容" { //Content
            let content = ContentViewController()
            navigationController?.pushViewController(content, animated: true)
        }
        if item == "送遞員" {
            let adminList = AdminListController()
            adminList.forDrivers = true
            navigationController?.pushViewController(adminList, animated: true)
        }
        if item == "地區" {
            let vc : CitiesViewController = self.storyboard!.instantiateViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if item == "發放通知" {
            let noticeList = NoticeListController()
            navigationController?.pushViewController(noticeList, animated: true)
        }
        if item == "登出" { //Logout
            alertWithChoices(with:  NSLocalizedString("logout", comment: ""), message:  NSLocalizedString("logoutMsg", comment: ""), yesBtnTitle:  NSLocalizedString("yes", comment: ""), noBtnTitle:  NSLocalizedString("no", comment: ""), yesaction: {
                User.shared?.logout()
            }, noaction: {})
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
