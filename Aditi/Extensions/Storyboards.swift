//
//  Storyboards.swift
//  share-food
//
//  Created by Invision-040 on 1/14/19.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import UIKit

extension UIStoryboard{
    
    enum Storyboard: String {
        case main
        case usertabbar
        case cart
        case riders
        case admin
        case chat

        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T{
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        return viewController
    }
}

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension UIViewController: StoryboardIdentifiable { }

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
