//
//  UIImageExt.swift
//  
//
//  Created by vedlai on 4/30/23.
//
#if canImport(UIKit)
import UIKit
extension UIImage {
    public var hasAlpha: Bool {
        guard let alphaInfo = self.cgImage?.alphaInfo else {return false}
        return alphaInfo != CGImageAlphaInfo.none &&
        alphaInfo != CGImageAlphaInfo.noneSkipFirst &&
        alphaInfo != CGImageAlphaInfo.noneSkipLast
    }
    public func imageWithAlpha(alpha: CGFloat) throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPointZero, blendMode: .normal, alpha: alpha)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else{
            UIGraphicsEndImageContext()
            throw ImageError.unableToAddAplhaToImage
        }
        UIGraphicsEndImageContext()
        return newImage
    }
    enum ImageError: LocalizedError{
        case unableToAddAplhaToImage
        case dataIsMissingOrInavalid
        case noDataAvailable
        case noImageAvaiable
    }
}


extension UIImage {
    
    public func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    public func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

//https://stackoverflow.com/questions/31661023/change-color-of-certain-pixels-in-a-uiimage
extension UIImage{
    public func processPixels(location: CGPoint?, color: UIImage.RGBA32 = .clear) -> UIImage? {
        guard let inputCGImage = self.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        if let location = location{
            let desiredSize = 20
            let size = desiredSize/2 //half on the left and half on the right and top/bottom.
            let y = Int(location.x)
            let x = Int(location.y)
            let xMin = x - size
            let xMax = x + size
            let yMin = y - size
            let yMax = y + size
            
            
            guard xMin >= 0, xMax <= width + size * 2 , yMin >= 0, yMax <= height + size * 2 else{
                return self
            }
            
            let xRange = xMin...xMax
            let yRange = yMin...yMax
            
            for y in yRange{
                for x in xRange{
                    let offset = x * width + y
                    if offset <= (width * height) && offset >= 0 && pixelBuffer[offset].alphaComponent > 0{
                        pixelBuffer[offset] = color
                    }
                }
            }
        }else{
            for offset in 0...height * width{
                pixelBuffer[offset] = color
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
        
        return outputImage
    }
    
    public struct RGBA32: Equatable {
        private var color: UInt32
        
        var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }
        
        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }
        
        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }
        
        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }
        
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }
        
        public static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        public static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        public static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        public static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        public static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        public static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        public static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        public static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
        public static let clear   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 0)
        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        public static func == (lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}

extension UIImage{
    public func copy() throws -> UIImage{
        guard let cgImag = cgImage else {
            throw ImageError.noImageAvaiable
        }
        let newImage = UIImage(cgImage: cgImag, scale: scale, orientation: imageOrientation)
        return newImage
    }
}


/// A value transformer which transforms `UIImage` instances into data using `NSSecureCoding`.
@objc(UIImageValueTransformer)
public final class UIImageValueTransformer: ValueTransformer {
    override public class func transformedValueClass() -> AnyClass {
        return UIImage.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIImage else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform `UIColor` to `Data`")
            return nil
        }
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: data as Data)
            return color
        } catch {
            assertionFailure("Failed to transform `Data` to `UIColor`")
            return nil
        }
    }
}
extension UIImageValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: UIImageValueTransformer.self))
    
    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = UIImageValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
#endif
