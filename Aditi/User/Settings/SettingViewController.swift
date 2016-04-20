//
//  SettingViewController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

enum indicatorType {
    case none
    case arrow
    case uiswitch
}

struct SettingItem {
    let image : String?
    let name : String
    let desc : String?
    let indicatorType : indicatorType
}


class SettingViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var items = [
        SettingItem(image: "info", name: "帳戶資料", desc: "Username, Profile information", indicatorType: .arrow),
        SettingItem(image: "delivery", name: "送貨地址", desc: "Delivery Address", indicatorType: .arrow),
        SettingItem(image: "Terms", name: "條款及細則", desc: "Terms & Conditions", indicatorType: .arrow),
        SettingItem(image: "Privacy Policy", name: "私隱政策", desc: "Privacy Policy", indicatorType: .arrow),
        SettingItem(image: "notification", name: "接收推廣及通知", desc: "", indicatorType: .uiswitch),
        SettingItem(image: "aboutUs", name: "關於我們", desc: "See all coupon", indicatorType: .none),
        SettingItem(image: "logout", name: "登出", desc: "", indicatorType: .none)
    ]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsCountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    var regions = [String : [String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .clear
        tableView.isScrollEnabled = false
        #if Internal
        imgViewHeight.constant = 0
        items.remove(at: 1)
        tableView.reloadData()
        addChatBtn()
        #elseif User
//        tableTop.constant = 0
        getRegions()
        #endif
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.tableView.contentSize.height
        }
        navigationItem.title = "帳戶"
//        addTitleLogo()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateCartView()
        #if User
        addRightBarBtns()
        #endif
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
    }
    
    @objc func reload(){
//        tableView.reloadData()
    }
    func updateCartView(){
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.white.cgColor
        if Cart.shared.items.count > 0 {
            //            UIView.animate(withDuration: 0.3) {
            self.cartViewHeight.constant = 50
            self.view.layoutIfNeeded()
            //            }
        }else{
            if cartViewHeight.constant != 0 {
                //                UIView.animate(withDuration: 0.3) {
                self.cartViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            //            }
        }
        priceLbl.text = "$\(Cart.shared.total())"
        itemsCountLbl.text = "\(Cart.shared.allItemsCount)"
    }
    func getRegions(){
        UIApplication.showLoader()
        contentsCol.document("Important Notes").getDocument { [weak self] (snapshot, err) in
            UIApplication.hideLoader()
            guard let snap = snapshot?.data(), let regions = snap["Regions"] as? [String : [String]] else {
                return
            }
            self?.regions = regions
        }
    }
    @IBAction func showCart(_ sender: UITapGestureRecognizer) {
        let cartVc : CartViewController = UIStoryboard(storyboard: .cart).instantiateViewController()
        UIApplication.topViewController().navigationController?.pushViewController(cartVc, animated: true)
    }
}


extension SettingViewController : UITableViewDataSource , UITableViewDelegate{
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
//        let imageView = cell.viewWithTag(1) as? UIImageView
        let textLabel = cell.viewWithTag(2) as? UILabel
//        imageView?.image = UIImage(named: item.image ?? "")
        textLabel?.text = item.name
        cell.selectionStyle = .none
        textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        if indexPath.row == items.count - 1 {
            textLabel?.textColor = .red
        }
        
        if item.indicatorType == .uiswitch {
            cell.accessoryType = .none
            #if User || Internal
            let uiswitch = MJMaterialSwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
            uiswitch.isRippleEnabled = true
            
            uiswitch.isOn = User.shared?.notifications ?? false
            //            uiswitch.setOn(on: User.shared!.notifications, animated: true)
            uiswitch.removeTarget(self, action: #selector(toggleNotifications(_:)), for: .valueChanged)
            uiswitch.addTarget(self, action: #selector(toggleNotifications(_:)), for: .valueChanged)
            cell.accessoryView = uiswitch
            #endif
        }else if item.indicatorType == .none{
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    #if User || Internal
    @objc func toggleNotifications(_ uiSwitch : MJMaterialSwitch){
        UIApplication.showLoader()
        User.shared?.toggleNotifications(notifications: uiSwitch.isOn, completion: { (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription)
            }else{
                UIApplication.hideLoader()
                let tmp = User.shared
                tmp?.notifications = uiSwitch.isOn
                User.shared = tmp
                
            }
        })
        
    }
    #endif
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if indexPath.row == 0 {
            performSegue(withIdentifier: "profile", sender: self)
        }else if indexPath.row == 1 {
            #if User
            performSegue(withIdentifier: "delivery", sender: self)
            #endif
        }else if item.name == "關於我們" {
            let vc : AddContentViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
            vc.type = .aboutUs
            vc.viewOnly = true
            navigationController?.pushViewController(vc, animated: true)
        }else if item.name == "條款及細則" {
            let vc : AddContentViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
            vc.type = .terms
            vc.viewOnly = true
            navigationController?.pushViewController(vc, animated: true)
        }else if item.name == "私隱政策" {
            let vc : AddContentViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
            vc.type = .privacy
            vc.viewOnly = true
            navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == items.count - 1 {
            alertWithChoices(with: nil, message: NSLocalizedString("logoutMsg", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: {
                User.shared?.logout()
            }, noaction: {})
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddressViewController {
            vc.regions = regions
        }
    }
}
