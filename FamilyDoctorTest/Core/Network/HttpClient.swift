//
//  HttpClient.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import ReactiveCocoa

final class HttpClient {
    static let shared = HttpClient()
    
    fileprivate let reachabilityManager: NetworkReachabilityManager
    fileprivate var retryQueue: [AbstractEnqueuedRequest] = []

    init() {
        self.reachabilityManager = NetworkReachabilityManager(host: Constants.Network.productionBaseUrl.absoluteString)!
        startReachabilityManager()
    }
    
    deinit {
        stopReachabilityManager()
    }

    func loadExternal(request: URLRequest, qos: DispatchQoS.QoSClass = .default) -> SignalProducer<AnyObject, Error> {
        return SignalProducer { sink, disposable in
            sessionManager.request(request).response(queue: DispatchQueue.global(qos: qos)) { response in
                guard response.error?.isConnectionError != true else {
                    self.handleExternalConnectionError(for: request, observer: sink); return
                }
                guard let statusCode = response.response?.statusCode else { sink.sendInterrupted(); return }
                
                switch(statusCode) {
                case 200...205:
                    self.handleExternalResponse(for: response.data!, observer: sink)
                case 400..<600:
                    self.handleErrorResponse(for: response.data!, observer: sink)
                default:
                    sink.sendInterrupted()
                }
            }
        }
    }
    
    func load(request: URLRequestConvertible & NetworkRouterParams, qos: DispatchQoS.QoSClass = .default) -> SignalProducer<AnyObject, Error> {
        return SignalProducer { sink, disposable in
            sessionManager.request(request).response(queue: DispatchQueue.global(qos: qos)) { [unowned self] response in
                guard response.error?.isConnectionError != true else {
                    self.handleConnectionError(for: request, observer: sink); return
                }
                ETagCache.cacheIfNeeded(response: response.response)
                guard let statusCode = response.response?.statusCode else { sink.sendInterrupted(); return }
                print("path: \(request.path), statusCode: \(statusCode)")
                switch(statusCode) {
                case 204:
                    sink.complete(value: ("" as AnyObject)) //пустой ответ
                case 200...203, 205, 409:
                    self.handleResponse(for: response.data!, observer: sink)
                case 404:
                    sink.complete(value: ("" as AnyObject)) //пустой массив
                case 400...403, 405..<600:
                    self.handleErrorResponse(for: response.data!, observer: sink)
                default:
                    sink.send(error: Error.commonError(with: "Неизвестный код"))
                }
            }
        }
    }
    
    func cancelRequests(for path: String) {
        sessionManager.cancelTasks(for: path)
    }
}

//MARK: - Retry
fileprivate class AbstractEnqueuedRequest {
    weak var observer: Signal<AnyObject, Error>.Observer?
}

fileprivate class InternalEnqueuedRequest: AbstractEnqueuedRequest {
    let request: URLRequestConvertible & NetworkRouterParams
    
    init(request: URLRequestConvertible & NetworkRouterParams, observer: Signal<AnyObject, Error>.Observer) {
        self.request = request
        super.init()
        self.observer = observer
    }
}

fileprivate class ExternalEnqueuedRequest: AbstractEnqueuedRequest {
    let request: URLRequest
    
    init(request: URLRequest, observer: Signal<AnyObject, Error>.Observer) {
        self.request = request
        super.init()
        self.observer = observer
    }
}

fileprivate extension HttpClient {
    func startSuspendedRequests() {
        self.retryQueue.forEach { (item) in
            guard let observer = item.observer else { return }
            switch item {
            case let item as InternalEnqueuedRequest:
                self.load(request: item.request).start(observer)
            case let item as ExternalEnqueuedRequest:
                self.loadExternal(request: item.request).start(observer)
            default: break
            }
        }
        self.retryQueue.removeAll()
    }
    
    func handleConnectionError(for request: URLRequestConvertible & NetworkRouterParams, observer: Signal<AnyObject, Error>.Observer) {
        guard request.method == .get else {
            observer.send(error: Error.connectionError)
            return
        }
        guard self.reachabilityManager.isReachableOnEthernetOrWiFi else {
            print("НЕТ СВЯЗИ!")
            observer.send(error: Error.connectionError)
            return
        }
        self.retryQueue.append(InternalEnqueuedRequest(request: request, observer: observer))
    }
    
    func handleExternalConnectionError(for request: URLRequest, observer: Signal<AnyObject, Error>.Observer) {
        self.retryQueue.append(ExternalEnqueuedRequest(request: request, observer: observer))
    }
}

//MARK: - Reachability
fileprivate extension HttpClient {
    func startReachabilityManager() {
        self.reachabilityManager.listener = self.handleNetworkReachability
        self.reachabilityManager.startListening()
    }
    
    func stopReachabilityManager() {
        self.reachabilityManager.stopListening()
    }
    
    func handleNetworkReachability(status: Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .notReachable: break
        case .reachable(_), .unknown:
            startSuspendedRequests()
        }
    }
}

//MARK: - Response Handlers
fileprivate extension HttpClient {
    func handleResponse(for data: Data, observer: Signal<AnyObject, Error>.Observer) {
        guard data.count != 0 else { observer.sendCompleted(); return }
        //201 code
        guard String(data: data.subdata(in: 0..<2), encoding: .utf8) != "[]" else { observer.send(value: () as AnyObject); return }
        if let parsingResult = JsonParser.parse(data: data) {
            observer.send(value: parsingResult)
        } else {
            observer.send(error: Error.commonError(with: "Invalid Json"))
        }
    }
    
    func handleErrorResponse(for data: Data, observer: Signal<AnyObject, Error>.Observer) {
        let parsingResult = JsonParser.parse(data: data)
        guard let info = parsingResult as? [String : AnyObject] else {
            guard let parsedError = parsingResult as? NSError else {
                observer.send(error: Error.commonError(with: "parsed Error"))
                return
            }
            observer.send(error: Error(error: parsedError))
            return
        }
        guard let error = info["error"] as? [ String : AnyObject ] else {observer.send(error: Error(code: 666, title: "Неизвестная ошибка",
                                                                                                    message: "Сервер еще не готов")); return}
        guard let code = error["code"] as? Int else {observer.send(error: Error(code: 666, title: "Ошибка в неверном формате",
                                                                                message: "Сервер еще не готов")); return}
        guard let message = error["message"] as? String else {observer.send(error: Error(code: 666, title: "Сообщение в неизвестном формате",
                                                                              message: "Сервер еще не готов")); return}
        observer.send(error: Error.init(code: code, title: "", message: message))
    }
    
    func handleExternalResponse(for data: Data, observer: Signal<AnyObject, Error>.Observer) {
        let parsingResult = JsonParser.parse(data: data)
        guard let info = parsingResult as? [String : AnyObject] else {
            observer.send(error: parsingResult as! Error); return
        }
        observer.complete(value: info as AnyObject)
    }
}

//MARK: - Error
fileprivate extension Swift.Error {
    var isConnectionError: Bool {
        let error = self as NSError
        return error.code == -1009
    }
}

