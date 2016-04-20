//
//  ItemDetailController.swift
//  伴百味
//
//  Created by Shezu on 22/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import CodableFirebase

class ItemDetailController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceWithoutDiscountLbl: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var qtyLbl: UILabel!
    @IBOutlet weak var addToCartBtn : UIButton!
    @IBOutlet weak var subBtn: UIButton!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var sub_products_area: ContentSizedTableView!
    @IBOutlet weak var noteTxtField: UITextView!
    
    @IBOutlet weak var qtySettingView: UIView!
    @IBOutlet weak var permTxt: UILabel!
    
    
    var product : Product!
    var sub_products = [Product]()
    var buy_sub_products = [Product]()
    var category : Category!
    var count =  1
    var noStock = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addRightBarBtns()
        setCartBottomView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTxtField.layer.borderWidth = 1
        noteTxtField.layer.borderColor = UIColor.black.cgColor
        noteTxtField.layer.cornerRadius = 8
        
        qtySettingView.isHidden = true
        addToCartBtn.isHidden = true
        permTxt.isHidden = true
        setupView()
    }
   
    func setupView(){
        productNameLbl.text = product.title
        priceLbl.text = "$" + product.totalAmount
        descTextView.text = product.desc
        qtyLbl.text = "\(count)"
        priceWithoutDiscountLbl.attributedText = product.discountAttrString
        descTextView.isEditable = false
         productImg.setImage(with: URL(string: product.image))
        
        if Int(product.stock) ?? 0 <= 0 {
            noStock = true
            addToCartBtn.setTitle("暫時售罄", for: .normal)
            addToCartBtn.isEnabled = false
            count = 0
            qtyLbl.text = "\(count)"
        }
        
        let nib = UINib(nibName: "SubProductCell2", bundle: nil)
        sub_products_area.register(nib, forCellReuseIdentifier: "SubProductCell2")
        sub_products_area.dataSource = self
        sub_products_area.delegate = self
        sub_products_area.estimatedRowHeight = 80;
        sub_products_area.rowHeight = UITableView.automaticDimension;
        
        getSubProductsList(p_id: product.id)
        
//        productImg.kf.indicatorType = .activity
//        if let url = URL(string: product.image) {
//            if let height = UserDefaults.standard.value(forKey: url.absoluteString) as? CGFloat{
//                productImg.setImage(with: URL(string: product.image))
//                imageHeight.constant = height
//                view.layoutIfNeeded()
//            }else{
//                productImg.kf.indicator?.startAnimatingView()
//                KingfisherManager.shared.downloader.downloadImage(with: url, options: .none) { [weak self] (result) in
//                    switch result {
//                    case .success(let result):
//                        guard let weakSelf = self else {return}
//                        let image = UIImage(data: result.originalData) ?? UIImage()
//                        let aspectRatio = image.size.height/image.size.width
//                        weakSelf.productImg.image = image
//                        weakSelf.imageHeight.constant = weakSelf.view.frame.size.width * aspectRatio
//                        UserDefaults.standard.set(weakSelf.imageHeight.constant, forKey: url.absoluteString)
//                        weakSelf.view.layoutIfNeeded()
//                    case .failure(let err):
//                        print(err.localizedDescription)
//                        self?.productImg.image = UIImage(named: "discountImage")
//                    }
//                    self?.productImg.kf.indicator?.stopAnimatingView()
//                }
//            }
//        }
    }
    
    func setCartBottomView() {
        qtySettingView.isHidden = true
        addToCartBtn.isHidden = true
        permTxt.isHidden = true
        
        categoriesCol.document(product.catId).getDocument { (snap, err) in
            guard let document = snap?.data() else {
                return
            }
            do {
                let thisCategory = try FirestoreDecoder().decode(Category.self, from: document)
                let allowedCity = thisCategory.cities?.first(where: {$0.name == User.shared?.city })
                if allowedCity == nil {
                    self.permTxt.isHidden = false
                }
                else {
                    self.qtySettingView.isHidden = false
                    self.addToCartBtn.isHidden = false
                }
            }catch {
                print(error)
                UIApplication.showError(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func addToCart(_ sender: AppColorBgButton) {
        if count == 0 {return}
        Cart.shared.addProduct(product: product, catName: category.title, qty: count, note: noteTxtField.text, subProducts: buy_sub_products)
        setupView()
        navigationController?.popViewController(animated: true)
    }
    @IBAction func add(_ sender: UIButton) {
        if User.shared == nil {
            alertWithChoices(with: nil, message: NSLocalizedString("loginSignup", comment: ""), yesBtnTitle: NSLocalizedString("yes", comment: ""), noBtnTitle: NSLocalizedString("no", comment: ""), yesaction: {
                Router.logout()
            }, noaction: {})
            return
        }
        count += 1
        setupView()
    }
    
    @IBAction func sub(_ sender: UIButton) {
        if count == 0 {return}
        count -= 1
        setupView()
    }
}

var isOpened = [Bool]()
extension ItemDetailController : UITableViewDataSource , UITableViewDelegate, SubProductCell2Delegate {
    func buyProduct(p: Product, status: Bool) {
        if status {
            buy_sub_products.append(p)
        }
        else {
            var tmp_ps = [Product]()
            buy_sub_products.forEach{item in
                if item.id != p.id {
                    tmp_ps.append(item)
                }
            }
            buy_sub_products = tmp_ps
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sub_products.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sub_products_area.dequeueReusableCell(withIdentifier: "SubProductCell2", for: indexPath) as! SubProductCell2
        cell.setProduct(product: sub_products[indexPath.row])
        cell.selectionStyle = .gray
        cell.buy_delegate = self
        cell.sub_detail_area.isHidden = !isOpened[indexPath.row]
        cell.isOpened = isOpened[indexPath.row]
        cell.isBuy.isChecked = isBuyProduct(p: sub_products[indexPath.row])
        
        if (indexPath.row > 0 && sub_products[indexPath.row - 1].catId == sub_products[indexPath.row].catId)
        {
            cell.categoryView.isHidden = true
        }
        else {
            cell.categoryView.isHidden = false
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SubProductCell2
        cell.isOpened = !cell.isOpened
        isOpened[indexPath.row] = cell.isOpened
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeight(index: indexPath.row)
    }

    func isBuyProduct(p : Product) -> Bool {
        var isFound = false
        buy_sub_products.forEach{item in
            if item.id == p.id {
                isFound = true
            }
        }
        return isFound
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {

        let size = CGSize(width: view.frame.width - 50, height: 1600)

        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height

        return rectangleHeight
    }
    
    func getHeight(index : Int) -> CGFloat {
        var categHeight : CGFloat = 35
        if (index > 0 && sub_products[index - 1].catId == sub_products[index].catId)
        {
            categHeight = 0
        }
        if(isOpened[index]) {
            let txt = sub_products[index].desc!
            let tmp_h = 390 + categHeight + estimatedHeightOfLabel(text: txt)
            return tmp_h
        }
        return CGFloat(70 + categHeight)
    }
}


//MARK:- FIRESTORE CALLS
extension ItemDetailController {
    
    func getSubProductsList(p_id : String){
        productsCol.document(p_id).collection("sub_products").getDocuments { [weak self] (querySnap, err) in
            guard let snap = querySnap else {
                UIApplication.showError(message: err!.localizedDescription, delay: 1)
                return
            }
            
            var tmp_p_list = [Product]()
            snap.documents.forEach { (doc) in
                let data = doc.data()
                guard let product = try? FirestoreDecoder().decode(Product.self, from: data) else{
                    print("Error while decoding Order")
                    return
                }
                tmp_p_list.append(product)
            }
            
            self?.sub_products = tmp_p_list.sorted(by: self!.sorterForSubCat)
            isOpened.removeAll()
            self?.sub_products.forEach{ item in
                isOpened.append(false)
            }
            self?.sub_products_area.reloadData()
        }
    }
     
    func sorterForSubCat(a:Product, b:Product) -> Bool {
        let aArr = a.catId.components(separatedBy: "=@=")
        let bArr = b.catId.components(separatedBy: "=@=")
        let w_a = aArr.count > 1 ? Int(aArr[1]) : 0
        let w_b = bArr.count > 1 ? Int(bArr[1]) : 0
        return w_a! > w_b!
    }
}
