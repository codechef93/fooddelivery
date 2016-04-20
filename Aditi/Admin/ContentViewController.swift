//
//  TermsViewController.swift
//  AditiAdmin
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

enum Content : String , Codable, CaseIterable {
    case terms = "Terms"
    case aboutUs = "About us"
    case privacy = "Privacy Policy"
    case notes = "Important Notes"
    case banner = "Banner"
    case deliveryTime = "Delivery Time"
}

class ContentViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "內容"
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Content.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = NSLocalizedString(Content.allCases[indexPath.row].rawValue, comment: "")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type =  Content.allCases[indexPath.row]
        if AppDelegate.noInternet() {return}
        if type == .banner {
            UIApplication.showLoader()
            contentsCol.document(Content.notes.rawValue).getDocument{
                [weak self] (querySnap, err) in
                UIApplication.hideLoader()
                guard let snap = querySnap else {
                    print("獲取內容時出錯")
                    return
                }
                let doc = snap.data()
                let vc : AddItemViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
                vc.type = .banner
                vc.banner = doc?["banner"] as? String
                vc.isEdit = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let vc : AddContentViewController =  UIStoryboard(storyboard: .admin).instantiateViewController()
            vc.type = type
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
