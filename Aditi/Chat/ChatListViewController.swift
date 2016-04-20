//
//  ChatListViewController.swift
//  Aditi
//
//  Created by macbook on 19/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import DZNEmptyDataSet

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    var channels = [Channel]()
    var listener : ListenerRegistration?
    
    var historyChannels = [Channel]()
    var historyListener : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "通訊"
        tableView.emptyDataSetSource = self
        tableView.separatorColor = .clear
        getChats()
        getHistoryChats()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
    }
    
    @objc func reload(){
        channels = [Channel]()
        historyChannels = [Channel]()
        listener?.remove()
        historyListener?.remove()
        getChats()
        getHistoryChats()
    }
    
    func getChats(){
        var showingLoader = true
        UIApplication.showLoader()
        listener = channelsCol
//            .whereField("admin.id", isEqualTo: User.shared!.id)
//            .whereField("active", isEqualTo: true)
            .order(by: "message.date", descending: true)
            .addSnapshotListener { [weak self] (querySnap, err) in
                guard let snap = querySnap else {
                    self?.tableView.reloadData()
                    return
                }
                var tmpchannels = [Channel]()
                snap.documents.forEach { doc in
                    if doc.metadata.hasPendingWrites {return}
                    let data = doc.data()
                    let channel = Channel(document: data)
                    tmpchannels.append(channel)
                }
                self?.channels = tmpchannels
                self?.tableView.reloadData()
                if showingLoader == false {return}
                if self?.channels.count == 0 {
                    showingLoader = false
                    UIApplication.showError(message: Errors.noChatsFound, delay: 1)
                }else{
                    showingLoader = false
                    UIApplication.hideLoader()
                }
        }
    }
    func getHistoryChats(){
        historyListener = channelsCol
            .whereField("admin.id", isEqualTo: User.shared!.id)
            .whereField("active", isEqualTo: false)
            .order(by: "message.date", descending: false)
            .addSnapshotListener { [weak self] (querySnap, err) in
                guard let snap = querySnap else {return}
                
                snap.documentChanges.forEach { (diff) in
                    if diff.document.metadata.hasPendingWrites {return}
                    let data = diff.document.data()
                    let channel = Channel(document: data)
                    if diff.type == .added {
                        self?.historyChannels.append(channel)
                    }
                    if diff.type == .modified {
                        if let index = self?.historyChannels.firstIndex(where: { $0.id == channel.id }){
                            self?.historyChannels[index] = channel
                        }else{
                            self?.historyChannels.append(channel)
                        }
                    }
                    if diff.type == .removed {
                        if let index = self?.historyChannels.firstIndex(where: { $0.id == channel.id }){
                            self?.historyChannels.remove(at: index)
                        }
                    }
                }
                self?.tableView.reloadData()
        }
    }
    deinit {
        historyListener?.remove()
        listener?.remove()
    }
}

extension ChatListViewController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return channels.count}
        return historyChannels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let username = cell.viewWithTag(1) as! UILabel
        let lastMsg = cell.viewWithTag(2) as! UILabel
        let date = cell.viewWithTag(3) as! UILabel
        let time = cell.viewWithTag(4) as! UILabel
        let onlineView = cell.viewWithTag(5)!
        
        let channel = indexPath.section == 0 ? channels[indexPath.row] : historyChannels[indexPath.row]
        username.text = channel.member.name
        lastMsg.text = channel.message.message
        date.text = channel.message.date.dateValue().toStringwith(format: DateFormats.onlyDate)
        time.text = channel.message.date.dateValue().toStringwith(format: DateFormats.onlyTime)
        onlineView.isHidden = channel.read
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "" : "History"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : historyChannels.count == 0 ? 0 : 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = indexPath.section == 0 ? channels[indexPath.row] : historyChannels[indexPath.row]
        let vc : ChatViewController = storyboard!.instantiateViewController()
        vc.channel =  channel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
extension ChatListViewController : DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrStr = NSAttributedString(string: NSLocalizedString("noChats", comment: ""))
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
