
import Foundation
import CodableFirebase
import FirebaseFirestore

struct ImpInfo : Codable {
    var text: String?
    var banner: String?
    var deliveryTime: String?
    var cities_level1: [CityItem] = [CityItem]()
    var cities_level2: [CityItem] = [CityItem]()
    var cities_level3: [CityItem] = [CityItem]()
    
    static func getInfo ( completion :  @escaping (_ data : ImpInfo?, _ error : String? ) -> Void) {
        contentsCol.getDocuments{(snap, err) in
            if snap != nil {
                snap!.documents.forEach { (snap) in
                    let doc = snap.data()
                    if snap.documentID == Content.notes.rawValue{
                        
                        guard let imp_info = try? FirestoreDecoder().decode(ImpInfo.self, from: doc) else{
                            print("Error while decoding Order")
                            completion(nil, "Error while decoding Order")
                            return
                        }
                        User.shared?.impInfo = imp_info
                        completion(imp_info, nil)
                    }
                }
            }
            completion(nil, err?.localizedDescription)
        }
    }
    
    static func addCity(level : String, cityitem : [String : Any], completion : @escaping (_ result : String?, _ error : String? ) -> Void) {
        contentsCol.document(Content.notes.rawValue).updateData([
            level: FieldValue.arrayUnion([cityitem]),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(nil, err.localizedDescription)
            } else {
                completion("success", nil)
            }
        }
    }
    
    static func delCity(level : String, cityitem : [String : Any], completion : @escaping (_ result : String?, _ error : String? ) -> Void) {
        contentsCol.document(Content.notes.rawValue).updateData([
            level: FieldValue.arrayRemove([cityitem]),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(nil, err.localizedDescription)
            } else {
                completion("success", nil)
            }
        }
    }
}


