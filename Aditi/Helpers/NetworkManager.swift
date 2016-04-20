//
//  NetworkManager.swift
//  AditiAdmin
//
//  Created by macbook on 15/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
class NetworkManager {
    class func createOrder(params : [String:Any], completion: @escaping (_ success : Bool,_ message: String, _ statusCode : Int?) -> Void){
        let session = URLSession.shared
        let strUrl = "http://us-central1-project-aditi-48c34.cloudfunctions.net/createOrder".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var req = URLRequest(url: URL(string: strUrl!)!)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = ["Content-Type" : "application/json"]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            req.httpBody = data
        }catch{
            completion(false,"invalid params",nil)
        }
        session.dataTask(with: req) { (data, response, err) in
            DispatchQueue.main.async {
                if let e = err {
                    completion(false,e.localizedDescription,nil)
                }else if let d = data ,
                    let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String:Any],
                    let success = json["success"] as? Bool,
                    let msg = json["message"] as? String,
                    let resp = response as? HTTPURLResponse{
                    completion(success, msg, resp.statusCode)
                }else{
                    completion(false, "invalid response", nil)
                }
            }
        }.resume()
    }
    
    class func sendPush(params : [String:Any], completion: @escaping (_ success : Bool,_ message: String, _ statusCode : Int?) -> Void){
           let session = URLSession.shared
           let strUrl = "http://us-central1-project-aditi-48c34.cloudfunctions.net/sendPush".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
           var req = URLRequest(url: URL(string: strUrl!)!)
           req.httpMethod = "POST"
           req.allHTTPHeaderFields = ["Content-Type" : "application/json"]
           do {
               let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
               req.httpBody = data
           }catch{
               completion(false,"invalid params",nil)
           }
           session.dataTask(with: req) { (data, response, err) in
               DispatchQueue.main.async {
                   if let e = err {
                       completion(false,e.localizedDescription,nil)
                   }else if let d = data ,
                       let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String:Any],
                       let success = json["success"] as? Bool,
                       let msg = json["message"] as? String,
                       let resp = response as? HTTPURLResponse{
                       completion(success, msg, resp.statusCode)
                   }else{
                       completion(false, "invalid response", nil)
                   }
               }
           }.resume()
    }
    
    class func deleteCategory(params : [String:Any], completion: @escaping (_ success : Bool,_ message: String) -> Void){
        let session = URLSession.shared
        let strUrl = "http://us-central1-project-aditi-48c34.cloudfunctions.net/deleteCategory".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var req = URLRequest(url: URL(string: strUrl!)!)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = ["Content-Type" : "application/json"]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            req.httpBody = data
        }catch{
            completion(false,"invalid params")
        }
        session.dataTask(with: req) { (data, response, err) in
            DispatchQueue.main.async {
                if let e = err {
                    completion(false,e.localizedDescription)
                }else if let d = data ,
                    let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String:Any],
                    let success = json["success"] as? Bool,
                    let msg = json["message"] as? String{
                    completion(success, msg)
                }else{
                    completion(false, "invalid response")
                }
            }
        }.resume()
    }
}

