//
//  UIImageView+Download.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit
import ReactiveSwift

extension UIImageView {
    @discardableResult func setImageAsync(link: String,
                                          size: CGSize? = nil,
                                          until: Signal<Void, Never>? = nil,
                                          recoveryImage: UIImage? = nil) -> Signal<UIImage, Never> {
        let size = size ?? self.nativeSize
        return Signal { [weak self] sink, disposable in
            let workItem = DispatchWorkItem {
                guard let _self = self else { return sink.sendCompleted() }
                if let image = AlamofireImageDownloader.imageFromCash(by: link) {
                    DispatchQueue.main.async {
                        _self.image = image
                    }
                    sink.complete(value: image)
                } else {
                    let imageProducer = AlamofireImageDownloader.download(link, size: size, recoveryImage: recoveryImage)
                    let untilProducer = until != nil ? imageProducer.take(until: until!) : imageProducer
                    _self.reactive.animatableImage <~ untilProducer
                        .observe(on: UIScheduler())
                        .on(completed: {
                            sink.sendCompleted()
                        }, value: { image in
                            sink.complete(value: image)
                        })
                }
            }
            DispatchQueue.global(qos: .default).async(execute: workItem)
        }
    }
}
