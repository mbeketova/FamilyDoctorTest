//
//  Error.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation

enum ErrorAttributes: String {
    case title = "title"
    case message = "message"
    case code = "code"
}

enum ErrorType {
    case client
    case server
    case validation
    case corrupted
    case connection
    case hidden
    case cancelled
    case removed
    case common
}

struct Error: Swift.Error {
    let title: String?
    let message: String
    var localizedMessage: String {
        get {
            return self.handledMessage()
        }
    }
    let code: Int
    
    var type: ErrorType {
        switch self.code {
        case 400..<500:
            return .client
        case 500..<600:
            return .server
        case -90210:
            return .validation
        case 102, -999:
            return .cancelled
        case 100500:
            return .corrupted
        case -9999:
            return .removed
        case -1009:
            return .connection
        case 0:
            return .hidden
        default:
            return .common
        }
    }
    
    init(error: NSError) {
        self.code = error.code
        self.title = nil
        self.message = error.localizedDescription
    }
    
    init(code: Int, title: String? = nil, message: String = "") {
        self.code = code
        self.title = title
        self.message = message
    }
}

private extension Error {
    func handledMessage() -> String {
        switch self.type {
        case .client,.corrupted,.server:
            return NSError.commonMessage
        case .connection:
            return NSError.connectionLostMessage
        default:
            return self.message
        }
    }
}

extension Error {
    
    static var connectionError: Error {
        return Error(code: NSError.connectionLostCode,
                     title: NSError.connectionLostTitle,
                     message: NSError.connectionLostMessage)
    }
    
    static func commonError(with title: String) -> Error {
        return Error(code: NSError.corruptedDataCode, title: title)
    }
    
    static func validationError(with message: String) -> Error {
        return Error(code: NSError.validationDataCode, message: message)
    }
    
    static var canceledError: Error {
        return Error(code: NSError.canceledCode,
                     title: NSError.canceledTitle,
                     message: NSError.canceledMessage)
    }
    
    static var removedError: Error {
        return Error(code: NSError.removedCode,
                     title: NSError.removedTitle,
                     message: NSError.removedMessage)
    }
    
    static func firebase(error: NSError) -> Error {
        switch error.code {
        case 17020:
            return connectionError
        default:
            return Error(error: error)
        }
    }
}

extension NSError {
    static let connectionLostCode = -1009
    static let serviceDenied = 181093
    static let corruptedDataCode = 100500
    static let validationDataCode = -90210
    static let canceledCode = -999
    static let removedCode = -9999
    
    static let connectionLostTitle = "connectionLostTitle"
    static let canceledTitle = "canceledTitle"
    static let removedTitle = "removedTitle"
    
    static let connectionLostMessage = "connectionLostMessage"
    static let commonMessage = "commonMessage"
    static let canceledMessage = "canceledMessage"
    static let removedMessage = "removedMessage"
    
    var isConnectionLostError: Bool {
        return self.code == NSError.connectionLostCode
    }
}
