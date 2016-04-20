import UIKit

class AddNoticeViewController: UIViewController  {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    var notice : NoticeListItem?
    
    @IBOutlet weak var titleField: CustomField!
    @IBOutlet weak var message: UITextView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "發放通知"
        
        setupViews()
    }
    
    func setupViews(){
        message?.layer.borderWidth = 0.5
        message?.layer.borderColor = UIColor.black.cgColor
        message?.layer.cornerRadius = 4
        saveBtn.isHidden = false
        
        if notice != nil{
            titleField.text = notice?.title
            message.text = notice?.message
            titleField.isEnabled = false
            message.isEditable = false
            saveBtn.isHidden = true
            
            addDeleteButton()
        }
    }
    
    func addDeleteButton(){
        let bbi = UIBarButtonItem(image: UIImage(named: "trashBbi"), style: .done, target: self, action: #selector(deletePressed(_:)))
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func deletePressed(_ bbi : UIBarButtonItem){
        if let n = notice {
            UIApplication.showLoader()
            noticesCol.document(n.id!).delete { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription, delay: 1)
                }else{
//                    UIApplication.showSuccess(message: "Message Removed", delay: 1)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    
    @IBAction func save(_ sender: Any) {

        guard let titleValue = titleField.text else {
            UIApplication.showError(message: "輸入題目")
            return
        }
        guard let messageValue = message.text else {
            UIApplication.showError(message: "輸入內容")
            return
        }

        if AppDelegate.noInternet() {return}
        let data = ["id" : "",
                "title" : titleValue,
                "message" : messageValue,
                "time" : UInt64(Date().timeIntervalSince1970 * 1000)
        ] as [String : Any]
        
        UIApplication.showLoader()
        NetworkManager.sendPush(params: data) { [weak self] (success, msg, statusCode) in
            if success {
                UIApplication.showSuccess(message: msg, delay: 1)
                self?.navigationController?.popViewController(animated: true)
            }else{
                if statusCode == 404 {
                    self?.navigationController?.popViewController(animated: true)
                }
                UIApplication.showError(message: msg, delay: 3)
            }
        }
    }
    
}
