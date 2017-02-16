//
//  UIImage.swift
//  Tomo
//
//  Created by starboychina on 2017/02/16.
//  Copyright © 2017 e-business. All rights reserved.
//

import MobileCoreServices

extension UIImage {
    // MARK: - URL style
    @discardableResult
    public func save(to url: URL) -> Bool {
        guard let data = UIImagePNGRepresentation(self) else {
            return false
        }
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }
    // MARK: - Paths style
    @discardableResult
    public func save(toPath path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        return self.save(to: url)
    }

    func scale(toFit newSize: CGSize) -> UIImage? {
        var fitSize = self.size
        if self.size.width > self.size.height {
            fitSize.width = newSize.width
            fitSize.height = self.size.height * newSize.width / self.size.width
        } else {
            fitSize.height = newSize.height
            fitSize.width = self.size.width * newSize.height / self.size.height
        }

        if fitSize.width > newSize.width {
            fitSize.width = newSize.width
            fitSize.height = self.size.height * newSize.width / self.size.width
        }

        if fitSize.height > newSize.height {
            fitSize.height = newSize.height
            fitSize.width = self.size.width * newSize.height / self.size.height
        }

        return scaleToFillSize(fitSize)
    }

    func scaleToFitSize(_ scaleSize: CGSize) -> UIImage? {
        // Keep aspect ratio
        var destWidth = 0, destHeight = 0
        if self.size.width > self.size.height {
            destWidth = Int(scaleSize.width)
            destHeight = Int(self.size.height * scaleSize.width / self.size.width)
        } else {
            destHeight = Int(scaleSize.height)
            destWidth = Int(self.size.width * scaleSize.height / self.size.height)
        }

        if destWidth > Int(scaleSize.width) {
            destWidth = Int(scaleSize.width)
            destHeight = Int(self.size.height * scaleSize.width / self.size.width)
        }

        if destHeight > Int(scaleSize.height) {
            destHeight = Int(scaleSize.height)
            destWidth = Int(self.size.width * scaleSize.height / self.size.height)
        }

        return self.scaleToFillSize(CGSize(width: destWidth, height: destHeight))
    }

    private func scaleToFillSize(_ scaleSize: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }

        var destWidth = Int(scaleSize.width * self.scale)
        var destHeight = Int(scaleSize.height * self.scale)
        if self.imageOrientation == .left
            || self.imageOrientation == .leftMirrored
            || self.imageOrientation == .right
            || self.imageOrientation == .rightMirrored {

            let temp = destWidth
            destWidth = destHeight
            destHeight = temp
        }

        // Create an ARGB bitmap context
        let bitmapContext = self.ARGBBitmapContext(width: destWidth, height: destHeight, withAlpha: cgImage.hasAlpha())
        guard let bmContext = bitmapContext else {
            return nil
        }

        // Image quality
        bmContext.setShouldAntialias(true)
        bmContext.setAllowsAntialiasing(true)
        bmContext.interpolationQuality = .high

        // Draw the image in the bitmap context
        UIGraphicsPushContext(bmContext)
        bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: destWidth, height: destHeight))
        UIGraphicsPopContext()

        // Create an image object from the context
        guard let scaledImageRef = bmContext.makeImage() else {
            return nil
        }

        return UIImage(cgImage: scaledImageRef, scale: self.scale, orientation: self.imageOrientation)
    }

    // MARK: - ARGB bitmap context
    private func ARGBBitmapContext(width: Int, height: Int, withAlpha: Bool) -> CGContext? {
        let numberOfComponentsPerARBGPixel = 4
        let alphaInfo = withAlpha ? CGImageAlphaInfo.premultipliedFirst : CGImageAlphaInfo.noneSkipFirst
        return CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * numberOfComponentsPerARBGPixel,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: alphaInfo.rawValue)
    }
}

// MARK: -
public extension CGImage {
    public func hasAlpha() -> Bool {
        let alpha = self.alphaInfo
        return (alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast)
    }
}
