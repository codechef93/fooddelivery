//
//  Cart.swift
//  AditiUser
//
//  Created by macbook on 29/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit

struct CartItem : Codable, Equatable {
    var product : Product
    let catName : String
    var note : String?
    var quantity : Int = 1
    var subProducts: [Product]
    
    var amount : Int {
        var sub_total = Int(product.totalAmount)!
        subProducts.forEach({
            sub_total += Int($0.totalAmount)!
        })
        return sub_total * quantity
    }
    
    var postBody : [String:Any]{
        var dict = [String:Any]()
        dict["product"] = product.postBody
        dict["catName"] = catName
        dict["note"] = note
        dict["quantity"] = quantity
        dict["subProducts"] = subProducts.map{ $0.postBody }
        return dict
    }
}

class Cart : Codable {
    static var shared : Cart! {
        get {
            if let cart = UserDefaults.standard.decode(for: Cart.self, using: "Cart") {
                return cart
            }
            return Cart()
        }
        set(cart) {
            UserDefaults.standard.encode(for: cart, using: "Cart")
        }
    }
    private init() {}
    var items = [CartItem]()
    
    var allItemsCount : Int {
        if items.count == 0 { return 0}
        var qty = 0
        items.forEach({ qty += $0.quantity  })
        return qty
    }
    
    var subTotal : Int {
        var subTotal = 0
        items.forEach({
            subTotal += $0.amount
        })
        return subTotal
    }
    
    func addProduct(product : Product, catName : String, qty : Int, note : String?, subProducts : [Product]){
        
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            var cartItem = items[index]
            cartItem.quantity += qty
            cartItem.subProducts = subProducts
            cartItem.note = note
            items[index] = cartItem
        }else{
            var cartItem = CartItem(product: product, catName: catName, note : note, subProducts: subProducts)
            cartItem.quantity = qty
            items.append(cartItem)
        }
        UIApplication.showSuccess(message: Messages.addedToCart, delay : 1)
        save()
    }
    
    func subProduct(product : Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            var item = items[index]
            item.quantity -= 1
            
            if item.quantity == 0 {
                items.remove(at: index)
                UIApplication.showSuccess(message: Messages.removedFromCart, delay : 1)
            }else{
                self.items[index] = item
            }
            save()
        }
    }
    
    func deleteProduct(product : Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items.remove(at: index)
            UIApplication.showSuccess(message: Messages.removedFromCart, delay : 1)
            save()
        }
    }
    
    func getLatestProductPrices(){
        for (index, item) in items.enumerated() {
            var item = item
            let latestProduct = UserTabbarController.shared?.products.first(where: { $0.id == item.product.id })
            item.product.price = latestProduct?.price ?? item.product.price
            items[index] = item
        }
        save()
    }
    
    func countForProduct(product : Product) -> Int{
        if let p = items.first(where: { $0.product.id == product.id }) {
            return p.quantity
        }
        return 0
    }
    
    func total(coupon : Coupon? = nil) -> Int{
        if let c = coupon {
            let discountAmount = (Int(c.discount)! * subTotal) / 100
            return subTotal - discountAmount
        }
        return subTotal
    }
    
    func getDiscountAmount(coupon : Coupon? = nil) -> Int{
        if let c = coupon {
            let discountAmount = (Int(c.discount)! * subTotal) / 100
            return discountAmount
        }
        return 0
    }
    
    func save()  {
        Cart.shared = self
    }
    func clear(){
        Cart.shared = nil
    }
}
