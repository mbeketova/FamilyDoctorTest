//
//  Alamofire+Cancel.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Alamofire

extension SessionManager {
    func cancelTasks(for path: String) {
        sessionManager.session.getAllTasks { tasks in
            tasks.forEach{ task in
                guard task.currentRequest?.url?.path.range(of: path) != nil else { return }
                task.cancel()
            }
        }
    }
}

