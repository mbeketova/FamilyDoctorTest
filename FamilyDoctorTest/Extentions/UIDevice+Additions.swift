//
//  UIDevice+Additions.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit

extension UIDevice {
    var bottomSafeAreaInset: CGFloat {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.bottom ?? 0
    }
    
    var topSafeAreaInset: CGFloat {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
    }
}

