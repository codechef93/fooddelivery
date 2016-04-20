//
//  CartCell.swift
//  AditiAdmin
//
//  Created by macbook on 14/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

protocol SubPCellDelegate : class {
    func add(cartItem : CartItem)
    func sub(cartItem : CartItem)
    func delete(cartItem : CartItem)
}

class SubPCell: UIView {
  
    @IBOutlet var ContentView: UIView!
    @IBOutlet weak var p_name: UILabel!
    @IBOutlet weak var p_price: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func  commonInit() {
        Bundle.main.loadNibNamed("SubPCell", owner: self, options: nil)
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    var item : CartItem!
    weak var delegate : SubPCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setup(item : CartItem, delegate : SubPCellDelegate){
        self.item = item
        self .delegate = delegate
    }
}
