//
//  SessionManager.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import Alamofire

let sessionManager: Alamofire.SessionManager = createManager()

fileprivate func createManager() -> Alamofire.SessionManager {
    let configuration = URLSessionConfiguration.default
    configuration.httpMaximumConnectionsPerHost = 1
    configuration.urlCache = nil
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    
    let manager = Alamofire.SessionManager(configuration: configuration)
    manager.delegate.taskWillPerformHTTPRedirection = httpRedirectionHandler
    
    return manager
}

fileprivate func httpRedirectionHandler(session: URLSession,
                                        task: URLSessionTask,
                                        response: HTTPURLResponse,
                                        request: URLRequest) -> URLRequest? {
    let baseAddress = Constants.Network.productionBaseUrl.absoluteString
    guard request.url?.absoluteString.contains(baseAddress) == true else { return nil }
    return request
}
