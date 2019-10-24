//
//  UIView+NativeSize.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit

extension UIView {
    var nativeSize: CGSize {
        return self.bounds.size.native
    }
}
