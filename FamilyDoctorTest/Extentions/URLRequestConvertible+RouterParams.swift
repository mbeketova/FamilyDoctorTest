//
//  URLRequestConvertible+RouterParams.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import Alamofire

extension URLRequestConvertible where Self:NetworkRouterParams  {
    func asURLRequest() throws -> URLRequest {
        let baseUrl = Constants.Network.productionBaseUrl
        let url = baseUrl.appendingPathComponent(self.path)
        var request = try! URLRequest(url: url, method: self.method, headers: self.headers)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return try self.encoding.encode(request, with: self.parameters)
    }
}
