//
//  ETagCashe.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation

struct ETagCache {
    static func cacheIfNeeded(response: HTTPURLResponse?) {
        guard let response = response else { return }
        guard let etag = response.allHeaderFields["Etag"] else { return }
        guard let link = response.url?.absoluteString else { return }
        UserDefaults.standard.set(etag, forKey: link)
        UserDefaults.standard.synchronize()
    }
    
    static func etag(for url: URL) -> String {
        return UserDefaults.standard.value(forKey: url.absoluteString) as? String ?? ""
    }
}

