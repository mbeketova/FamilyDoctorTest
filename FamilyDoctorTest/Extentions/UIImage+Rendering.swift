//
//  UIImage+Rendering.swift
//  FamilyDoctorTest
//
//  Created by Mariya on 24/10/2019.
//  Copyright © 2019 Mariya. All rights reserved.
//

import UIKit
import AVFoundation.AVUtilities

extension UIImage {
    func render(with size: CGSize, backgroundColor: UIColor) -> UIImage {
        //fixed crash for size == zero:
        let normalSize = size == .zero ? CGSize(width: 320, height: 320) : size
        //-----------------------------
        let scale = UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: normalSize.width, height: normalSize.height).integral
        let rect = UIImage.center(innerRect: AVMakeRect(aspectRatio: self.size, insideRect: frame), in: frame)
        
        let cgImage = self.cgImage!
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        UIGraphicsBeginImageContextWithOptions(frame.size, true, scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(backgroundColor.cgColor)
        context.fill(frame)
        context.interpolationQuality = .high
        context.translateBy(x: 0, y: frame.height)
        context.scaleBy(x: 1, y: -1)
        
        context.saveGState()
        
        context.draw(cgImage, in: rect)
        context.restoreGState()
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    private static func center(innerRect: CGRect, in outerRect: CGRect) -> CGRect {
        let originX = (outerRect.size.width - innerRect.size.width) * 0.5
        let originY = (outerRect.size.height - innerRect.size.height) * 0.5
        return CGRect(x: originX, y: originY, width: innerRect.width, height: innerRect.height).integral
    }
    
    func resized(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        self.croped().draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage;
        }
        return nil
    }
    
    private func croped() -> UIImage {
        if self.size.width != self.size.height {
            let sizeValue = self.size.width < self.size.height ? self.size.width : self.size.height
            return self.cropToBounds(width: Double(sizeValue), height: Double(sizeValue))
        }
        return self
    }
    
    private func cropToBounds(width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: self.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x:posX, y:posY, width: cgwidth,height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = (contextImage.cgImage?.cropping(to: rect))!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
}

