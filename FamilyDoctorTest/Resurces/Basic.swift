//
//  Basic.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import RealmSwift

struct Constants {
    static let realmSchemaVersion: UInt64 = UInt64(1)// не забывать менять!

    struct Network {
        static let productionBaseUrl: URL = URL(string: "https://cloud.fdoctor.ru")!
    }

    struct UI {
        struct Sizes {
            static let navigationBarHeight:         CGFloat = 64
            static let cornerRadius:                CGFloat = 10
        }
    }

    struct RealmConfigurations {
        static let pills = Realm.configuration(named: "pills")
    }

}

