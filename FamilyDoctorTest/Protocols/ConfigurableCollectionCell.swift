//
//  ConfigurableCollectionCell.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit

protocol ConfigurableCell {
    associatedtype T
    
    func bind(viewModel: T)
}

protocol Reusable {
    static var nib: UINib {get}
    static var reuseIdentifier: String {get}
}

extension Reusable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return "\(String(describing: self))Identifier"
    }
}

protocol ConfigurableCollectionCell : Reusable, ConfigurableCell {
    static func estimatedSize(viewModel: T?) -> CGSize
}

extension UICollectionView {
    func dequeue<T: Reusable>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    func registerNib<T: Reusable>(_ type: T.Type) {
        self.register(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerClass<T: Reusable>(_ type: T.Type) where T:UICollectionViewCell {
        self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
}

