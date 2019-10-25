//
//  Realm+Instance.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import RealmSwift
import Foundation

extension Realm.Configuration {
    static var currentDefaultConfiguration = Realm.Configuration(schemaVersion: Constants.realmSchemaVersion)
}

extension Realm {
    private static let inMemoryConfiguration = Realm.Configuration(inMemoryIdentifier: "InMemory",
                                                                   schemaVersion: Constants.realmSchemaVersion)
    // To prevent whole in memory realm deallocation
    private static let inMemoryMainRealm = try! Realm(configuration: inMemoryConfiguration)
    
    static var instance: Realm {
        return try! Realm(configuration: Realm.Configuration.currentDefaultConfiguration)
    }
    
    static func configuration(named: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(named).realm")
        config.schemaVersion = Constants.realmSchemaVersion
        return config
    }
    
    static func instance(with configuration: Realm.Configuration) -> Realm {
        return try! Realm(configuration: configuration)
    }
    
    static func refreshMainInstanceAsync(with configuration: Realm.Configuration = Realm.Configuration.currentDefaultConfiguration) {
        DispatchQueue.main.async {
            Realm.instance(with: configuration).refresh()
        }
    }
    
    static func refreshMainInstanceSync(with configuration: Realm.Configuration = Realm.Configuration.currentDefaultConfiguration) {
        _ = DispatchQueue.main.sync {
            Realm.instance(with: configuration).refresh()
        }
    }
    
    static var inMemoryInstance: Realm {
        if Thread.isMainThread {
            return inMemoryMainRealm
        }
        return try! Realm(configuration: inMemoryConfiguration)
    }
    
    ///creates copy of object from other realm in this realm
    func createCopy<T: Object>(of object: T) {
        try! write {
            create(T.self, value: object, update: .all)
        }
    }
}
