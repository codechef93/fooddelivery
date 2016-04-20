//
//  OrderViewController.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class QRcodeViewController: UIViewController {
    
    @IBOutlet weak var qrImg: UIImageView!
    var order : Order?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "二維碼(QR code)"
        
        var qr_string = "\(order!.id)=\(order!.status.rawValue)"
        generateQRCode(from: qr_string)
    }
    
    func generateQRCode(from string: String){
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                qrImg.image = UIImage(ciImage: output)
            }
        }
    }
}
