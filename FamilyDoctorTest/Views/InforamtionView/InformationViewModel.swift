//
//  InformationViewModel.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 25/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa

final class InformationViewModel {
    let pill: MutableProperty<Pill>
    
    init(pill: Pill) {
        self.pill = MutableProperty<Pill>(pill)
    }
}

