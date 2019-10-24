//
//  RealmObject.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

enum CommonAttributes: String {
    case id = "id"
}

@objcMembers
class RealmObject : Object {
    dynamic var id: String!
    
    override class func indexedProperties() -> [String] {
        return [CommonAttributes.id.rawValue]
    }
    
    override class func primaryKey() -> String? {
        return CommonAttributes.id.rawValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? RealmObject else { return false }
        return self.id == object.id
    }
    
    override var hash: Int { return self.id.hash }
}

func == <T: RealmObject>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}

extension Object : Serializable {
    @objc var jsonRepresentation: [String : Any] {
        return [:]
    }
}
