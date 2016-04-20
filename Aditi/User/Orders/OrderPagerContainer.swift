//
//  OrderPagerContainer.swift
//  AditiUser
//
//  Created by macbook on 27/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class OrderPagerContainer: UIViewController {

    @IBOutlet weak var container : UIView!
    @IBOutlet weak var notesLbl : UILabel!
    let vc = OrderPager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notesLbl.text = UserTabbarController.shared?.impInfo?.text
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        vc.view.frame = container.bounds
        self.container.addSubview(vc.view)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
