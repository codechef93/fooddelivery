import UIKit
import FirebaseFirestore
import CodableFirebase
import DZNEmptyDataSet

struct NoticeListItem : Codable {
    var id: String?
    var title : String?
    var message : String?
    var time: UInt64?
}

class NoticeListController: UITableViewController {

    var notices = [NoticeListItem]()
    var forDrivers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "發放通知"
        tableView.showsVerticalScrollIndicator = false
        tableView.emptyDataSetSource = self
        tableView.separatorColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .internet, object: nil)
        addAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNoticeList()
    }
    
    @objc func reload(){
        notices = [NoticeListItem]()
        getNoticeList()
    }
    
    func addAddButton(){
//        let moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
//        moreButton.setImage(UIImage(named: "plus"), for: .normal)
//        moreButton.tintColor =  UIColor.white
//        moreButton.addTarget(self, action: #selector(deletePressed(_:)), for: .touchUpInside)
//        let menuBarItem = UIBarButtonItem(customView: moreButton)
//        menuBarItem.tintColor =  UIColor.white
//        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
//        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
//        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        navigationItem.rightBarButtonItem = menuBarItem
        let bbi = UIBarButtonItem(image: UIImage(named: "ic_menu_add"), style: .done, target: self, action: #selector(addPush(_:)))
        
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func addPush(_ bbi : UIBarButtonItem){
         let vc : AddNoticeViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
         navigationController?.pushViewController(vc, animated: true)
     }
    
    func getNoticeList(){
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        notices = []
        
        noticesCol.getDocuments { [weak self] (querySnap, err) in
            UIApplication.hideLoader()
            guard let snap = querySnap else {
                return
            }
            snap.documents.forEach({
                if let notice = try? FirestoreDecoder().decode(NoticeListItem.self, from: $0.data()){
                    self?.notices.append(notice)
                }
            })
            self?.tableView.reloadData()
        }
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

extension NoticeListController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let notice = notices[indexPath.row]
        
        cell.textLabel?.text = notice.title

        if(notice.time != nil)
        {
            cell.detailTextLabel?.text =  Date(timeIntervalSince1970: Double(notice.time! / 1000)).toStringwith(format: DateFormats.dateAndTime)
        }
        else {
            cell.detailTextLabel?.text = ""
        }
        
//        cell.accessoryView = view
        cell.selectionStyle = .default
        cell.detailTextLabel?.textColor =  .lightGray
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : AddNoticeViewController = UIStoryboard(storyboard: .admin).instantiateViewController()
        vc.notice = notices[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
extension NoticeListController : DZNEmptyDataSetSource {
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
