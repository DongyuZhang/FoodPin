//
//  UINavigationController+Ext.swift
//  FoodPin
//
//  Created by Dongyu Zhang on 9/25/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
}
