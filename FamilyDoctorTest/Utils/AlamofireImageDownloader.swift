//
//  AlamofireImageDownloader.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import AlamofireImage
import ReactiveSwift

final class AlamofireImageDownloader: ImageDownloader {
    
    static let shared = AlamofireImageDownloader(
        configuration: AlamofireImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 10,
        imageCache: AutoPurgingImageCache(
            memoryCapacity: 100_000_000,
            preferredMemoryUsageAfterPurge: 60_000_000
        )
    )
}

private protocol Interface {
    static func download(_ link: String, size: CGSize?, recoveryImage: UIImage?) -> SignalProducer<UIImage, Never>
    static func imageFromCash(by identifier: String) -> UIImage?
    static func cleanImageCache()
}

//MARK: Interface

extension AlamofireImageDownloader: Interface {
    
    static func download(_ link: String, size: CGSize? = nil, recoveryImage: UIImage?) -> SignalProducer<UIImage, Never> {
        return downloadImage(by: link)
            .observe(on: imageScheduer)
            .flatMap(.latest, { self.render(image: $0, size: size) })
            .flatMap(.latest, { self.store(image: $0, with: link)})
            .flatMapError { _ in self.render(image: recoveryImage, size: size) }
            .start(on: imageScheduer)
    }
    
    static func imageFromCash(by identifier: String) -> UIImage? {
        let imageCache = AlamofireImageDownloader.shared.imageCache
        return imageCache?.image(withIdentifier: identifier)
    }
    
    static func cleanImageCache() {
        let imageCache = AutoPurgingImageCache()
        imageCache.removeAllImages()
    }
}

//MARK: Queue

private extension AlamofireImageDownloader {
    
    static let downloadQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.FamilyDoctorTest.image.download", qos: .background)
        return queue
    }()
    
    static var imageScheduer: QueueScheduler = {
        return QueueScheduler(targeting: downloadQueue)
    }()
}

//MARK: Internal Methods

private extension AlamofireImageDownloader {
    
    static func downloadImage(by link: String) -> SignalProducer<UIImage, Error> {
        return SignalProducer { sink, disposable in
            let downloader = AlamofireImageDownloader.shared
            guard let url = URL(string: link) else {
                let error = Error.commonError(with: "downloadImage: link is not url")
                return sink.send(error: error)
            }
            let urlRequest = URLRequest(url: url)
            let imageRequest = downloader.download(urlRequest) { imageResponse in
                if disposable.hasEnded {
                    return sink.sendCompleted()
                }
                if let error = imageResponse.error {
                    return sink.send(error: Error(error: error as NSError))
                }
                guard let image = imageResponse.result.value else {
                    let error = Error.commonError(with: "downloadImage: value nil")
                    return sink.send(error: error)
                }
                sink.complete(value: image)
            }
            disposable.observeEnded {
                if let request = imageRequest {
                    downloader.cancelRequest(with: request)
                }
            }
        }
    }
    
    static func render(image: UIImage, size: CGSize) -> UIImage {
        return image.render(with: size, backgroundColor: .white)
    }
    
    static func render(image: UIImage?, size: CGSize?) -> SignalProducer<UIImage, Never> {
        return SignalProducer { sink, disposable in
            guard let image = image else { sink.sendCompleted(); return }
            guard let size = size else { sink.complete(value: image); return}
            let result = self.render(image: image, size: size)
            sink.complete(value: result)
        }
    }
    
    static func store(image: UIImage, with link: String) -> SignalProducer<UIImage, Never> {
        return SignalProducer { sink, disposable in
            let imageCash = AlamofireImageDownloader.shared.imageCache
            imageCash?.add(image, withIdentifier: link)
            sink.complete(value: image)
        }
    }
}

