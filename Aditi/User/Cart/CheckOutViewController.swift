//
//  CheckOutViewController.swift
//  AditiUser
//
//  Created by Shezu on 18/07/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import Stripe

protocol CheckoutVcDelegate : class {
    func tokenCreated(token : String)
    func errorFromStripe(error : String)
}

class CheckoutViewController: UIViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var popUp: UIView!
    
    weak var delegate : CheckoutVcDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        popUp.layer.cornerRadius = 8
        UIView.animate(withDuration: 1) {
            self.blackView.alpha = 0.4
        }
    }

    @IBAction func pay(_ sender : UIButton) {
        let cardParams = STPCardParams()
        cardParams.number = cardTextField.cardNumber
        cardParams.expMonth = UInt(cardTextField.expirationMonth)
        cardParams.expYear = UInt(cardTextField.expirationYear)
        cardParams.cvc = cardTextField.cvc
        
        // Pass it to STPAPIClient to create a Token
        UIApplication.showLoader()
        STPAPIClient.shared.createToken(withCard: cardParams) { [weak self] token, error in
            guard let token = token else {
                // Handle the error
                UIApplication.hideLoader()
                self?.delegate?.errorFromStripe(error: error?.localizedDescription ?? "付款時出錯")
                self?.dismiss(animated: true, completion: nil)
                return
            }
            let tokenID = token.tokenId
            self?.delegate?.tokenCreated(token: tokenID)
            self?.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
