//
//  Pill.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
internal class Pill: RealmObject {
    dynamic var name: String = ""
    dynamic var img: String = ""
    dynamic var desription: String = ""
    dynamic var dose: String = ""

    var displayDescription: String {
        return "\(self.desription) \n\(self.dose)"
    }
}

//MARK:- Deserializable
extension Pill : Deserializable {
    static func normalize(json: inout [String : AnyObject]){
        let id = json["id"] as! Int
        json["id"] = id.description as AnyObject
    }
}

