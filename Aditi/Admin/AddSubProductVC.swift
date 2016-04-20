import UIKit
import CodableFirebase
import FirebaseFirestore
import DZNEmptyDataSet

class AddSubProductVC: UIViewController {

    
    @IBOutlet weak var sub_pname: UITextField!
    @IBOutlet weak var sub_cat_weight: UITextField!
    @IBOutlet weak var sub_options_tv: ContentSizedTableView!
    
    var subProducts = [Product]()
    var sub_product_name = ""
    var cat_weight = ""
    var isEdit = false
    var main_product : Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEdit {
            title = NSLocalizedString("更改選項產品", comment: "")
            addDeleteButton()
        }
        else {
            title = NSLocalizedString("新增選項產品", comment: "")
        }
        
        
        let nib = UINib(nibName: "SubProductCell1", bundle: nil)
        sub_options_tv.register(nib, forCellReuseIdentifier: "SubProductCell1")
        sub_options_tv.delegate = self
        sub_options_tv.dataSource = self

        sub_pname.text = sub_product_name
        sub_cat_weight.text = cat_weight
        reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reload()
    }
    
    
    @IBAction func onSavePressed(_ sender: Any) {
        view.endEditing(true)
        if isEdit {
            if sub_pname.text! == "" {
                UIApplication.showError(message: "輸入標題!")
                sub_pname.text = sub_product_name
                return
            }
            if sub_cat_weight.text! == "" {
                UIApplication.showError(message: "輸入重量!")
                sub_cat_weight.text = cat_weight
                return
            }
            let old_catId = "\(sub_product_name)=@=\(cat_weight)"
            let new_catId = "\(sub_pname.text!)=@=\(sub_cat_weight.text!)"
            
            updateCategory(p_id: main_product!.id, old_cat: old_catId, new_cat: new_catId)
        }
        else {
            sub_product_name = sub_pname.text!
            cat_weight = sub_cat_weight.text!
            reload()
        }
    }
    
    @IBAction func onAddSubOption(_ sender: Any) {
        if sub_product_name == "" {
            UIApplication.showError(message: "輸入標題!")
            return
        }
        if cat_weight == "" {
            UIApplication.showError(message: "輸入重量!")
            return
        }
        let vc : AddSubOptionVC = storyboard!.instantiateViewController()
        vc.sub_product_name = sub_product_name
        vc.sub_cat_weight = cat_weight
        vc.main_product = main_product
        vc.isEdit = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reload(){
        let sub_catId = "\(sub_product_name)=@=\(cat_weight)"
        let filtered_items = Appdata.shared.subPlist.filter{ $0.catId == sub_catId}
        subProducts = filtered_items.sorted(by: { $0.title < $1.title })
        sub_options_tv.reloadData()
    }
    
    func addDeleteButton(){
        let bbi = UIBarButtonItem(image: UIImage(named: "trashBbi"), style: .done, target: self, action: #selector(deletePressed(_:)))
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func deletePressed(_ bbi : UIBarButtonItem){
        let sub_catId = "\(sub_product_name)=@=\(cat_weight)"
        deleteSucCategoryt(p_id: main_product!.id, cat_id: sub_catId)
    }
}

extension AddSubProductVC : UITableViewDataSource , UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SubProductCell1 = sub_options_tv.dequeueReusableCell(withIdentifier: "SubProductCell1", for: indexPath) as! SubProductCell1
        let item = subProducts[indexPath.row]
        cell.setProduct(product: item)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = subProducts[indexPath.row]
        let vc : AddSubOptionVC = storyboard!.instantiateViewController()
        vc.sub_product_name = sub_product_name
        vc.sub_cat_weight = cat_weight
        vc.main_product = main_product
        vc.product = item
        vc.isEdit = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}


//MARK:- FIRESTORE CALLS
extension AddSubProductVC {
    
    func updateCategory(p_id : String, old_cat : String, new_cat : String) {
        UIApplication.showLoader()
        productsCol.document(p_id).collection("sub_products").whereField("catId", isEqualTo: old_cat).getDocuments { (snap, err) in
            guard let snap = snap else {
                UIApplication.showError(message: err!.localizedDescription)
                return
            }
            
            let batch = db.batch()
            snap.documents.forEach { (doc) in
                if doc.metadata.hasPendingWrites {return}
                let data = doc.data()
                guard var product = try? FirestoreDecoder().decode(Product.self, from: data) else{
                    print("Error while decoding Order")
                    return
                }
                product.catId = new_cat
               
                batch.updateData(["catId" : new_cat], forDocument: productsCol.document(p_id).collection("sub_products").document(product.id))
            }
            
            batch.commit() { err in
                UIApplication.hideLoader()
                if let err = err {
                    print("Error writing batch \(err)")
                    UIApplication.showError(message: "Error writing batch \(err)")
                } else {
                    self.sub_product_name = new_cat
                }
            }
            
        }
    }
    
    func deleteSucCategoryt(p_id : String, cat_id : String){
        UIApplication.showLoader()
        productsCol.document(p_id).collection("sub_products").whereField("catId", isEqualTo: cat_id)
        .getDocuments { (snap, err) in
            guard let snap = snap else {
                UIApplication.showError(message: err!.localizedDescription)
                return
            }
            
            let batch = db.batch()
            snap.documents.forEach { (doc) in
                if doc.metadata.hasPendingWrites {return}
                let data = doc.data()
                guard let product = try? FirestoreDecoder().decode(Product.self, from: data) else{
                    print("Error while decoding Order")
                    return
                }
                
                batch.deleteDocument(productsCol.document(p_id).collection("sub_products").document(product.id))
            }
            
            batch.commit() { err in
                UIApplication.hideLoader()
                if let err = err {
                    print("Error writing batch \(err)")
                    UIApplication.showError(message: "Error writing batch \(err)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
    
     
}
