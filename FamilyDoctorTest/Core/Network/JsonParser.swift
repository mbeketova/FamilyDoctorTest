//
//  JsonParser.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation

struct JsonParser {
    static func parse(data: Data) -> AnyObject? {
        if let object = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as AnyObject {
            return object
        }
        return nil
    }
}

