//
//  AddItemVC+Picker.swift
//  AditiAdmin
//
//  Created by macbook on 25/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import CodableFirebase

extension AddItemViewController : UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @objc func dateChanged(_ datePicker: UIDatePicker){
        if toField.isFirstResponder {
            toDate = datePicker.date
            toField.text = toDate?.toStringwith(format: "dd/MM/yyyy")
        }else{
            fromDate = datePicker.date
            fromField.text = fromDate?.toStringwith(format: "dd/MM/yyyy")
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == categoryField,
            let index = categoryList.firstIndex(where: { $0.title == textField.text ?? "" }){
            selectCategory(index: index)
        }
        if textField == toField  {
            let datePicker = textField.inputView as! UIDatePicker
            if let date = toDate  {
                datePicker.date = date
            }else{
                toDate = datePicker.date
            }
        }
        if textField == fromField  {
            let datePicker = textField.inputView as! UIDatePicker
            if let date = fromDate  {
                datePicker.date = date
            }else{
                fromDate = datePicker.date
            }
        }
        if textField == discountField , let text = textField.text {
            textField.text = text.replacingOccurrences(of: "%", with: "")
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == toField , let date = toDate , let datePicker = textField.inputView as? UIDatePicker {
            datePicker.date = date
            textField.text = toDate?.toStringwith(format: "dd/MM/yyyy")
        }
        if textField == fromField , let date = fromDate , let datePicker = textField.inputView as? UIDatePicker {
            datePicker.date = date
            textField.text = fromDate?.toStringwith(format: "dd/MM/yyyy")
        }
        if textField == discountField , let text = textField.text {
            if text.count == 0 {
                textField.text = text + "0%"
            }else{
                if (Int(text) ?? 0) > 99 {
                    textField.text = "0%"
                    UIApplication.showError(message: "Invalid discount percentage", delay: 1)
                }else{
                    textField.text = text + "%"
                }
            }
        }
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row].title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectCategory(index: row)
    }
    func selectCategory(index : Int){
        selectedCategory = categoryList[index]
        categoryField.text = selectedCategory!.title
    }
    
   
}

//MARK:- FIRESTORE CALLS
extension AddItemViewController {
    
    func getSubProductsList(p_id : String){
        UIApplication.showLoader()
        listener = productsCol.document(p_id).collection("sub_products")
            .addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnap, err) in
                UIApplication.hideLoader()
                
                guard let snap = querySnap else {
                    return
                }
                
                var tmp_p_list = [Product]()
                var tmp_c_list = [String]()
                snap.documents.forEach { (doc) in
                    if doc.metadata.hasPendingWrites {
                        return
                    }
                    let data = doc.data()
                    guard let product = try? FirestoreDecoder().decode(Product.self, from: data) else{
                        print("Error while decoding Order")
                        return
                    }
                    tmp_p_list.append(product)
                    if tmp_c_list.contains(product.catId) == false {
                        tmp_c_list.append(product.catId)
                    }
                }
                Appdata.shared.subPlist = tmp_p_list
                self?.subCatList = tmp_c_list
                self?.subCatList = self!.subCatList.sorted(by: self!.sorterForSubCat)
                self?.subCatTableView.reloadData()
        }
    }
    
    func sorterForSubCat(a:String, b:String) -> Bool {
        let aArr = a.components(separatedBy: "=@=")
        let bArr = b.components(separatedBy: "=@=")
        let w_a = aArr.count > 1 ? Int(aArr[1]) : 0
        let w_b = bArr.count > 1 ? Int(bArr[1]) : 0
        return w_a! > w_b!
    }
     
     func getCategoryList(){
         UIApplication.showLoader()
         categoriesCol.getDocuments { [weak self] (snap, err) in
             guard let snap = snap, let weakSelf = self else {
                 UIApplication.showError(message: err!.localizedDescription)
                 return
             }
             snap.documents.forEach { (document) in
                 if let category = try? FirestoreDecoder().decode(Category.self, from: document.data()){
                     weakSelf.categoryList.append(category)
                 }
             }
             if let picker = weakSelf.categoryField.inputView as? UIPickerView {
                 picker.reloadAllComponents()
             }
             if let p = weakSelf.product { //isEditing
                 if let index = weakSelf.categoryList.firstIndex(where: { $0.id == p.catId }) {
                     weakSelf.selectCategory(index: index)
                 }
             }else if weakSelf.categoryList.count > 0 {
                 weakSelf.selectCategory(index: 0)
             }
             UIApplication.hideLoader()
         }
     }
}
