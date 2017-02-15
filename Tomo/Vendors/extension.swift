//
//  extension.swift
//  Tomo
//
//  Created by starboychina on 2017/01/04.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation
import MobileCoreServices
import RxSwift

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
        if (self.size.width > self.size.height)
        {
            fitSize.width = newSize.width
            fitSize.height = self.size.height * newSize.width / self.size.width
        }
        else
        {
            fitSize.height = newSize.height
            fitSize.width = self.size.width * newSize.height / self.size.height
        }
        if (fitSize.width > newSize.width)
        {
            fitSize.width = newSize.width
            fitSize.height = self.size.height * newSize.width / self.size.width
        }
        if (fitSize.height > newSize.height)
        {
            fitSize.height = newSize.height
            fitSize.width = self.size.width * newSize.height / self.size.height
        }
        return scaleToFillSize(fitSize)
    }
    
    func scaleToFitSize(_ scaleSize: CGSize) -> UIImage?
    {
        // Keep aspect ratio
        var destWidth = 0, destHeight = 0
        if self.size.width > self.size.height
        {
            destWidth = Int(scaleSize.width)
            destHeight = Int(self.size.height * scaleSize.width / self.size.width)
        }
        else
        {
            destHeight = Int(scaleSize.height)
            destWidth = Int(self.size.width * scaleSize.height / self.size.height)
        }
        if destWidth > Int(scaleSize.width)
        {
            destWidth = Int(scaleSize.width)
            destHeight = Int(self.size.height * scaleSize.width / self.size.width)
        }
        if destHeight > Int(scaleSize.height)
        {
            destHeight = Int(scaleSize.height)
            destWidth = Int(self.size.width * scaleSize.height / self.size.height)
        }
        
        return self.scaleToFillSize(CGSize(width: destWidth, height: destHeight))
    }
    
    private func scaleToFillSize(_ scaleSize: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else
        {
            return nil
        }
        
        var destWidth = Int(scaleSize.width * self.scale)
        var destHeight = Int(scaleSize.height * self.scale)
        if self.imageOrientation == .left
            || self.imageOrientation == .leftMirrored
            || self.imageOrientation == .right
            || self.imageOrientation == .rightMirrored
        {
            let temp = destWidth
            destWidth = destHeight
            destHeight = temp
        }
        
        // Create an ARGB bitmap context
        guard let bmContext = self.ARGBBitmapContext(width: destWidth, height: destHeight, withAlpha: cgImage.hasAlpha()) else
        {
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
        guard let scaledImageRef = bmContext.makeImage() else
        {
            return nil
        }
        
        return UIImage(cgImage: scaledImageRef, scale: self.scale, orientation: self.imageOrientation)
    }
    
    // MARK: - ARGB bitmap context
    private func ARGBBitmapContext(width: Int, height: Int, withAlpha: Bool) -> CGContext?
    {
        let numberOfComponentsPerARBGPixel = 4
        let alphaInfo = withAlpha ? CGImageAlphaInfo.premultipliedFirst : CGImageAlphaInfo.noneSkipFirst
        let bmContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * numberOfComponentsPerARBGPixel, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: alphaInfo.rawValue)
        return bmContext
    }
}

// MARK: -
public extension CGImage
{
    public func hasAlpha() -> Bool
    {
        let alphaInfo = self.alphaInfo
        return (alphaInfo == .first || alphaInfo == .last || alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast)
    }
}

public extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    /**
     Strips the specified characters from the beginning of self.
     
     - returns: Stripped string
     */
    func trimmedLeft (characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
        if let range = rangeOfCharacter(from: set.inverted) {
            return self[range.lowerBound..<endIndex]
        }
        
        return ""
    }
    
    /**
     Strips the specified characters from the end of self.
     
     - returns: Stripped string
     */
    func trimmedRight (characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
        if let range = rangeOfCharacter(from: set.inverted, options: String.CompareOptions.backwards) {
            return self[startIndex..<range.upperBound]
        }
        
        return ""
    }
    
    /**
     Strips whitespaces from both the beginning and the end of self.
     
     - returns: Stripped string
     */
    func trimmed () -> String {
        return trimmedLeft().trimmedRight()
    }
    /**
     Parses a string containing a date into an optional NSDate if the string is a well formed.
     The default format is yyyy-MM-dd, but can be overriden.
     
     - returns: A NSDate parsed from the string or nil if it cannot be parsed as a date.
     */
    func toDate(format : String? = "yyyy-MM-dd") -> Date? {
        let text = self.trimmed().lowercased()
        let dateFmt = DateFormatter()
        dateFmt.timeZone = NSTimeZone.default
        if let fmt = format {
            dateFmt.dateFormat = fmt
        }
        return dateFmt.date(from: text)
    }
    
    
    public var isEmail: Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let regex = "(?=^.{8,}$)(?=.*\\d)(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}

internal extension Array {
    
    /**
     Deletes all the items in self that are equal to element.
     
     - parameter element: Element to remove
     */
    mutating func remove <U: Equatable> (_ element: U) {
        let anotherSelf = self
        
        removeAll(keepingCapacity: true)
        
        anotherSelf.forEach({ current in
            if (current as! U) != element {
                self.append(current)
            }
        })
    }
}

extension UINavigationController {

    func pop(to viewController: UIViewController, animated: Bool) {
        _ = self.popToViewController(viewController, animated: animated)
    }
    
    @discardableResult
    func pop(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
}

// MARK: - extension for rxSwift
extension UIViewController {

    /// When a DisposeBag is deallocated, it will call dispose on each of the added disposables.
    var disposeBag: DisposeBag {
        return DisposeBag()
    }
}
