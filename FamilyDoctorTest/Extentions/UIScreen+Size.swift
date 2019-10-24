//
//  UIScreen+Size.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit

extension UIScreen {
    static var mainBounds: CGRect {
        return UIScreen.main.bounds
    }

    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var size: CGSize {
        return UIScreen.main.bounds.size
    }
}

