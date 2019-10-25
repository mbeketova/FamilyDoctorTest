//
//  PillsService.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

private protocol Interface: class {
    func loadPills() -> SignalProducer<Void, Error>
}

//MARK: - Interface
final class PillsService: Interface {
    private let realmConfig: Realm.Configuration
    
    required init(config: Realm.Configuration = Realm.instance.configuration) {
        self.realmConfig = config
    }
    
    func loadPills() -> SignalProducer<Void, Error> {
        let request = PillsNetworkRouter.loadPills
        return HttpClient.shared.load(request: request, qos: .utility)
            .flatMap(.latest, save)
            .observe(on: QueueScheduler.main)
    }
}

//MARK: - Save
private extension PillsService {
    func save(response: AnyObject) -> SignalProducer<Void, Error> {
        guard let response = response as? [String : AnyObject] else {
            return SignalProducer(error: Error.commonError(with: "response error"))
        }
        guard let pills = response["pills"] as? [[String : AnyObject]] else {
            return SignalProducer(error: Error.commonError(with: "pills json error"))
        }
        return SignalProducer {sink, dispose in
            let realm = Realm.instance(with: self.realmConfig)
            try! realm.write {
                let pillToClean = realm.objects(Pill.self)
                realm.delete(pillToClean)
                
                pills.forEach{
                    var pill = $0
                    Pill.normalize(json: &pill)
                    realm.create(Pill.self, value: pill, update: .all)
                }
            }

           Realm.refreshMainInstanceAsync(with: self.realmConfig)
        }
    }

}
