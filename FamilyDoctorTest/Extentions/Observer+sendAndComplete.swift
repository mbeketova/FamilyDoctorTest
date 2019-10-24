//
//  Observer+sendAndComplete.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import ReactiveSwift

extension Signal.Observer {
    func complete(value: Value) {
        send(value: value)
        sendCompleted()
    }
}
