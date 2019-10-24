//
//  PillsNetworkRouter.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

enum PillsNetworkRouter: URLRequestConvertible {
    case getPills
}

extension PillsNetworkRouter: NetworkRouterParams {
    var path: String {
        switch self {
        case .getPills:
            return "test_task"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var isProduction: Bool {
        return true
    }
    
    var parameters: Parameters {
        switch self {
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.methodDependent
        }
    }
}

