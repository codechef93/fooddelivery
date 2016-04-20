//
//  UIImageView+Kingfisher.swift
//  share-food
//
//  Created by Invision-040 on 3/5/19.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with url: URL?,placeholderImage:UIImage? = Constants.imgPlaceholder,
                  completion : ((_ image : UIImage?) -> Void)? = nil ) {
        var kf = self.kf
        kf.indicatorType = .activity
        if let placeholder = placeholderImage{
            if let _url = url{
                if let completion = completion {
                    let res = ImageResource(downloadURL: _url, cacheKey: nil)
                    kf.setImage(with: res, placeholder: nil, options: [.cacheMemoryOnly], progressBlock: nil) { (result) in
                        switch result {
                        case .success(let image):
                            completion(image.image)
                        case .failure(let error):
                            print(error.errorCode)
                            completion(nil)
                        }
                    }
                }else{
                    kf.setImage(with: _url, placeholder: placeholder)
                }
            }
        }
        else {
            kf.setImage(with: url)
        }
    }
}
//
