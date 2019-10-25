//
//  UIImageView+Animatable.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

extension UIImageView {
    var animatableImage: UIImage? {
        set {
            UIView.transition(with: self,
                              duration: 0.20,
                              options: .transitionCrossDissolve,
                              animations: { self.image = newValue },
                              completion: { _ in
                                
            })
        }
        get { return self.image }
    }
    
}

//MARK: - Reactive
extension Reactive where Base: UIImageView {
    var animatableImage: BindingTarget<UIImage> {
        return makeBindingTarget {(view, image: UIImage) in
            view.animatableImage = image
        }
    }
}
