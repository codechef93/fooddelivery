import UIKit
import FirebaseFirestore
import CodableFirebase
import QuartzCore

class AddSubOptionVC: UIViewController, ImagePickerPresenting, UITextFieldDelegate {
    
    
    @IBOutlet weak var titleField : UITextField!
    @IBOutlet weak var descField : UITextField!
    @IBOutlet weak var categoryField : UITextField!
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var saveBtn : UIButton!
    
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var discountField: UITextField!
    
    @IBOutlet weak var stockField: UITextField!
    
   
    var isEdit = false
    var imagePicked = false
    
    //For Products
    var main_product : Product?
    var product : Product?
    var sub_product_name = ""
    var sub_cat_weight = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK:- BIND VIEW
    func setupView(){
        title = NSLocalizedString("新增選項", comment: "")
        
        imgView.layer.cornerRadius = 16
        imgView.layer.borderColor = UIColor.lightGray.cgColor
        imgView.layer.borderWidth = 1
        
        discountField.delegate = self
        categoryField.delegate = self
        
        applyBorderToField(textField: titleField)
        applyBorderToField(textField: categoryField)
        applyBorderToField(textField: priceField)
        applyBorderToField(textField: discountField)
        applyBorderToField(textField: descField)
        applyBorderToField(textField: stockField)

        if isEdit { bindData() }
    }
    
    func applyBorderToField(textField : UITextField){
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 4
    }
    
    func bindData(){
        title = NSLocalizedString("更改選項", comment: "")
        titleField.text = product?.title
        descField.text = product?.desc
        imgView.setImage(with: URL(string:product!.image))
        priceField.text = product?.price
        stockField.text = product?.stock
        var discount = product?.discount ?? ""
        if discount.count > 0 {
            discount = discount + "%"
        }
        discountField.text = discount
        addDeleteButton()
    }
    
    func addDeleteButton(){
        let bbi = UIBarButtonItem(image: UIImage(named: "trashBbi"), style: .done, target: self, action: #selector(deletePressed(_:)))
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func deletePressed(_ bbi : UIBarButtonItem){
        if let p = product {
            deleteProduct(p: p)
        }
    }
    
    func deleteProduct(p : Product){
        alertWithChoices(message: NSLocalizedString("deleteProductMsg", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: { [weak self] in
            UIApplication.showLoader()
            productsCol.document(self!.main_product!.id).collection("sub_products").document(p.id).delete { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription, delay: 1)
                }else{
                    UIApplication.showSuccess(message: "Product Removed", delay: 1)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }) {}
    }
    
    @IBAction func pickImage(_ gesture : UITapGestureRecognizer){
        presentImagePicker { (image) in
            if let i = image {
                self.imgView.image = i
                self.imagePicked = true
            }else{
                self.imagePicked = false
            }
        }
    }
    
    @IBAction func save(_ btn : UIButton){
       isEdit ? editProduct() : addProduct()
    }
    
}

//MARK:- PRODUCT CRUD

extension AddSubOptionVC {
    func addProduct(){
        guard let title = titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , title.count > 0 else {
            UIApplication.showError(message: Errors.invalidTitleErr)
            return
        }
        guard let price = priceField.text , Int(price) != nil, Int(price)! >= 0 else {
            UIApplication.showError(message: Errors.invalidPrice)
            return
        }
        guard let stock = stockField.text , Int(stock) != nil, Int(stock)! >= 0 else {
            UIApplication.showError(message: Errors.invalidStock)
            return
        }
        if !imagePicked {
            UIApplication.showError(message: Errors.pickImage)
            return
        }
        if AppDelegate.noInternet() {return}
        UIApplication.showLoader()
        
        let name = "\(Date().timeIntervalSince1970).jpg"
        let doc = productsCol.document(main_product!.id).collection("sub_products").document()
        let path = "\(productsCol.path)/\(doc.documentID)/\(name)"
        let discount = self.discountField.text?.replacingOccurrences(of: "%", with: "") ?? ""
        
        let sub_catId = "\(sub_product_name)=@=\(sub_cat_weight)"
        
        Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
            if let url = url {
                let new = Product.data(title: title,
                                       desc: self?.descField.text,
                                       imgUrl: url,
                                       id: doc.documentID,
                                       discount: discount,
                                       price: price,
                                       catId: sub_catId,
                                       stock: stock
                )
                doc.setData(new) { (error) in
                    if let e = error {
                        UIApplication.showError(message: e.localizedDescription)
                    }else{
                        UIApplication.showSuccess(message: Messages.productAdded)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    func editProduct(){
        if let product = product {
            guard let title = titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , title.count > 0 else {
                UIApplication.showError(message: Errors.invalidTitleErr)
                return
            }
            guard let price = priceField.text , Int(price) != nil, Int(price)! >= 0 else {
                UIApplication.showError(message: Errors.invalidPrice)
                return
            }
            guard let stock = stockField.text , Int(stock) != nil, Int(stock)! >= 0 else {
                UIApplication.showError(message: Errors.invalidStock)
                return
            }
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            
            let doc = productsCol.document(main_product!.id).collection("sub_products").document(product.id)
            let name = "\(Int(Date().timeIntervalSince1970)).jpg"
            let path = "\(productsCol.path)/\(product.id)/\(name)"
            let discount = self.discountField.text?.replacingOccurrences(of: "%", with: "") ?? ""
            
            let sub_catId = "\(sub_product_name)=@=\(sub_cat_weight)"
            
            var data = ["updatedAt" : FieldValue.serverTimestamp(),
                        "title" : title,
                        "desc" : self.descField.text ?? "",
                        "price" : price,
                        "catId" : sub_catId,
                        "stock" : stock,
                        "discount" : discount] as [String : Any]
            if imagePicked {
                Uploader.uploadImage(image: imgView.image!, path: path) { [weak self] (url) in
                    if let url = url {
                        data["image"] = url
                        doc.updateData(data, completion: { (error) in
                            if let e = error {
                                UIApplication.showError(message: e.localizedDescription)
                            }else{
                                UIApplication.showSuccess(message: Messages.productUpdated)
                                self?.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                }
            }else{
                
                doc.updateData(data, completion: { [weak self] (error) in
                    if let e = error {
                        UIApplication.showError(message: e.localizedDescription)
                    }else{
                        UIApplication.showSuccess(message: Messages.productUpdated)
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
}
