
import Foundation
class Appdata {
    static let shared = Appdata()
    
    var subPlist = [Product]()
    private init() { }
}
