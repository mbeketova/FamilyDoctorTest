//
//  CGSize+Native.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit

extension CGSize {
    var native: CGSize {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
