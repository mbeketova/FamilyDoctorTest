//
//  NetworkRouterProperties.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkRouterParams {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }
    var encoding: ParameterEncoding { get }
    var headers: [String: String]? { get }
    var isProduction: Bool { get }
    var supportsETag: Bool { get }
}

extension NetworkRouterParams {
    var encoding: ParameterEncoding {
        return URLEncoding.methodDependent
    }
    
    var headers: [String: String]? {
        let headers =  ["Content-Type" : "application/json", "Accept" : "application/json"]
        return headers
    }
    
    var isProduction: Bool {
        return true
    }
    
    var supportsETag: Bool {
        return false
    }
}

