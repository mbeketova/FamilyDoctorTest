//
//  Serializable.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation

protocol Serializable {
    var jsonRepresentation: [String : Any] { get }
}

extension Array where Element : Serializable {
    var jsonRepresentation: [[String : Any]] {
        return map{$0.jsonRepresentation}
    }
}

protocol Deserializable {
    static func normalize(json: inout [String : AnyObject])
}

extension Deserializable {
    static func normalize(json: inout [String : AnyObject]) {}
}

