//
//  Extensions.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
//import RLBAlertsPickers
import AVFoundation
import AVKit
import CommonCrypto

/* SWIFT EXTENSIONS */

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
  case topRightBottomLeft
  case topLeftBottomRight
  case horizontal
  case vertical

var startPoint: CGPoint {
    return points.startPoint
}

var endPoint: CGPoint {
    return points.endPoint
}

var points: GradientPoints {
    switch self {
    case .topRightBottomLeft:
        return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
    case .topLeftBottomRight:
        return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
    case .horizontal:
        return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
    case .vertical:
        return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
    }
  }
}

extension UIView {

func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = colours.map { $0.cgColor }
    gradient.locations = locations
    self.layer.insertSublayer(gradient, at: 0)
}

func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = colours.map { $0.cgColor }
    gradient.startPoint = orientation.startPoint
    gradient.endPoint = orientation.endPoint
    self.layer.insertSublayer(gradient, at: 0)
  }
    
    func addBottomShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }

}

extension UIView {
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension UIView {
    
    enum GlowEffect: Float {
        case small = 1, normal = 5, big = 15
    }

    func doGlowAnimation(withColor color: UIColor, withEffect effect: GlowEffect = .normal, repeatAnimation: Bool) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = effect.rawValue
        glowAnimation.beginTime = CACurrentMediaTime()+0.3
        glowAnimation.duration = CFTimeInterval(1.0)
        glowAnimation.fillMode = .removed
        glowAnimation.autoreverses = true
        glowAnimation.isRemovedOnCompletion = true

        if repeatAnimation {
            glowAnimation.repeatCount = .infinity
        }

        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }

    func addTopRoundedCornerToView(targetView:UIView?, desiredCurve:CGFloat?)
    {
        let offset:CGFloat =  targetView!.frame.width/desiredCurve!
        let bounds: CGRect = targetView!.bounds

        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y+bounds.size.height / 2, width: bounds.size.width, height: bounds.size.height / 2)

        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)

        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath

        // Set the newly created shape layer as the mask for the view's layer
        targetView!.layer.mask = maskLayer
    }
    
    func addBottomRoundedEdge(desiredCurve: CGFloat?) {
        let offset: CGFloat = self.frame.width / desiredCurve!
        let bounds: CGRect = self.bounds
        
        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height / 2)
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer
    }
    
    func addCurvedView() {
        let maskLayer = CAShapeLayer(layer: self.layer)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x:0, y:0))
        bezierPath.addLine(to: CGPoint(x:self.bounds.size.width, y:0))
        bezierPath.addLine(to: CGPoint(x:self.bounds.size.width, y:self.bounds.size.height))
        bezierPath.addQuadCurve(to: CGPoint(x:0, y:self.bounds.size.height), controlPoint: CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height-self.bounds.size.height*0.3))
        bezierPath.addLine(to: CGPoint(x:0, y:0))
        bezierPath.close()
        maskLayer.path = bezierPath.cgPath
        maskLayer.frame = self.bounds
        maskLayer.masksToBounds = true
        self.layer.mask = maskLayer
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIButton {

  /// Sets the background color to use for the specified button state.
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {

    let minimumSize: CGSize = CGSize(width: 1.0, height: 1.0)

    UIGraphicsBeginImageContext(minimumSize)

    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(color.cgColor)
      context.fill(CGRect(origin: .zero, size: minimumSize))
    }

    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    self.clipsToBounds = true
    self.setBackgroundImage(colorImage, for: forState)
  }
}

extension UIView {
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
    var boolValue: Bool {
        return NSNumber(integerLiteral: self).boolValue
    }
}

extension UIBezierPath {
    
    convenience init(heartIn rect: CGRect, center: CGPoint) {
        self.init()
        self.move(to: CGPoint(x: rect.width * 0.514, y: rect.height * 0.2311))
        
        self.addCurve(to: CGPoint(x: rect.origin.x, y: rect.height * 0.368),
                      controlPoint1: CGPoint(x: rect.width * 0.385, y: -0.119 * rect.height),
                      controlPoint2: CGPoint(x: rect.origin.x, y: -0.028 * rect.height))
        
        self.addCurve(to: CGPoint(x: rect.width * 0.515, y: rect.height),
                      controlPoint1: CGPoint(x: rect.origin.x, y: rect.height * 0.764),
                      controlPoint2: CGPoint(x: rect.width * 0.515, y: rect.height))
        
        self.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.366),
                      controlPoint1: CGPoint(x: rect.width * 0.515, y: rect.height),
                      controlPoint2: CGPoint(x: rect.width, y: rect.height * 0.7615))
        
        self.addCurve(to: CGPoint(x: rect.width * 0.514, y: rect.height * 0.2311),
                      controlPoint1: CGPoint(x: rect.width, y: -0.031 * rect.height),
                      controlPoint2: CGPoint(x: rect.width * 0.6376, y: -0.103 * rect.height))
        
        self.close()
        
    }
    
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {
    func subString(from: Int, to: Int) -> String {
       let startIndex = self.index(self.startIndex, offsetBy: from)
       let endIndex = self.index(self.startIndex, offsetBy: to)
       return String(self[startIndex...endIndex])
    }
}

extension UIFont {
    
    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}

extension UILabel {
    
    /// Will auto resize the contained text to a font size which fits the frames bounds.
    /// Uses the pre-set font to dynamically determine the proper sizing
    func fitTextToBounds() {
        guard let text = text, let currentFont = font else { return }
    
        let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
        font = bestFittingFont
    }
    
    private var basicStringAttributes: [NSAttributedString.Key: Any] {
        var attribs = [NSAttributedString.Key: Any]()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        attribs[.paragraphStyle] = paragraphStyle
        
        return attribs
    }
}

extension String {

    func attributedString(letterSize: CGFloat, digitSize: CGFloat) -> NSAttributedString
    {
        let pattern = "\\d+"
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
        let attributedString = NSMutableAttributedString(string: self, attributes: [.font : UIFont.systemFont(ofSize: letterSize)])
        matches.forEach { attributedString.addAttributes([.font : UIFont.systemFont(ofSize: digitSize)], range: $0.range) }
        return attributedString.copy() as! NSAttributedString
    }
    
    func withBoldText(boldPartsOfString: Array<NSString>, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont!]
        let boldString = NSMutableAttributedString(string: self as String, attributes:nonBoldFontAttribute)
        for i in 0 ..< boldPartsOfString.count {
            boldString.addAttributes(boldFontAttribute, range: (self as NSString).range(of: boldPartsOfString[i] as String))
        }
        return boldString
    }
}

enum DeviceSize {
    case big, medium, small, extra_small
}

protocol Fontadjustable {

    var devicetype: DeviceSize { get }

    func adjustFontSizeForDevice()
}

extension UILabel: Fontadjustable {

    var devicetype: DeviceSize {
        print("device screen size: ",UIScreen.main.nativeBounds.height)
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .extra_small
        case 1334:
            return .small
        case 2208:
            return .big
        case 2436:
            return .big
        case 2688:
            return .big
        case 1792, 1920:
            return .medium
        default:
            return .small
        }
    }

    func adjustFontSizeForDevice() {
        switch self.devicetype {
        case .small:
            self.font = font.withSize(font.pointSize)
        case .medium:
            self.font = font.withSize(font.pointSize + 2)
        case .big:
            self.font = font.withSize(font.pointSize + 3)
        case .extra_small:
            self.font = font.withSize(font.pointSize)
        }
    }
    
    func adjustNumberFontSize() {
        switch deviceSize {
            case .i4Inch:
                self.font = font.withSize(30.0)
            default:
                adjustFontSizeForDevice()
        }
        
    }
    func adjustContentFontSize() {
        switch deviceSize {
            case .i4Inch:
                self.font = font.withSize(14.0)
            default:
                adjustFontSizeForDevice()
        }
    }
}

extension UITextView: Fontadjustable {
    var devicetype: DeviceSize {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .extra_small
        case 1334:
            return .small
        case 2208:
            return .big
        case 2436:
            return .big
        case 2688:
            return .big
       case 1792, 1920:
            return .medium
        default:
            return .small
        }
    }

    func adjustFontSizeForDevice() {
        switch self.devicetype {
        case .small:
            self.font = font?.withSize(font?.pointSize ?? 16)
        case .medium:
            self.font = font?.withSize((font?.pointSize ?? 16) + 2)
        case .big:
            self.font = font?.withSize((font?.pointSize ?? 16) + 3)
        case .extra_small:
            self.font = font?.withSize(font?.pointSize ?? 16)
        }
    }
    
    func adjustNumberFontSize() {
        switch deviceSize {
            case .i4Inch:
                self.font = font?.withSize(30.0)
            default:
                adjustFontSizeForDevice()
        }
        
    }
    func adjustContentFontSize() {
        switch deviceSize {
            case .i4Inch:
                self.font = font?.withSize(14.0)
            default:
                adjustFontSizeForDevice()
        }
    }
}

extension UITextField: Fontadjustable {
    var devicetype: DeviceSize {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .extra_small
        case 1334:
            return .small
        case 2208:
            return .big
        case 2436:
            return .big
        case 2688:
            return .big
        case 1792, 1920:
            return .medium
        default:
            return .small
        }
    }

    func adjustFontSizeForDevice() {
        switch self.devicetype {
        case .small:
            self.font = font?.withSize(font?.pointSize ?? 16)
        case .medium:
            self.font = font?.withSize((font?.pointSize ?? 16) + 2)
        case .big:
            self.font = font?.withSize((font?.pointSize ?? 16) + 3)
        case .extra_small:
            self.font = font?.withSize(font?.pointSize ?? 16)
        }
    }
    
    func adjustNumberFontSize() {
        switch deviceSize {
            case .i4Inch:
                self.font = font?.withSize(30.0)
            default:
                adjustFontSizeForDevice()
        }
        
    }
    func adjustContentFontSize() {
        switch deviceSize {
            case .i4Inch:
                self.font = font?.withSize(14.0)
            default:
                adjustFontSizeForDevice()
        }
    }
}

extension Array {

    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
        
    var base64Decoded: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }

    /// Returns a base64 representation of the current string, or nil if the
    /// operation fails.
    var base64Encoded: String? {
        let utf8 = self.data(using: .utf8)
        let base64 = utf8?.base64EncodedString()
        return base64
    }
    
    func generateRandomBytes() -> String? {
        var bytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard result == errSecSuccess else {
            print("Problem generating random bytes")
            return nil
        }

        return Data(bytes).base64EncodedString()
    }
    
}

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = true
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.color = .green
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}

extension Character {
    var unicode: String {
        // See table here: https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts
        let unicodeChars = [Character("0"):"\u{2070}",
                            Character("1"):"\u{00B9}",
                            Character("2"):"\u{00B2}",
                            Character("3"):"\u{00B3}",
                            Character("4"):"\u{2074}",
                            Character("5"):"\u{2075}",
                            Character("6"):"\u{2076}",
                            Character("7"):"\u{2077}",
                            Character("8"):"\u{2078}",
                            Character("9"):"\u{2079}",
                            Character("i"):"\u{2071}",
                            Character("+"):"\u{207A}",
                            Character("-"):"\u{207B}",
                            Character("="):"\u{207C}",
                            Character("("):"\u{207D}",
                            Character(")"):"\u{207E}",
                            Character("n"):"\u{207F}"]

        if let unicode = unicodeChars[self] {
            return unicode
        }

        return String(self)
    }
}

extension String {
    var unicodeSuperscript: String {
        let char = Character(self)
        return char.unicode
    }

    func superscripted() -> String {
        let regex = try! NSRegularExpression(pattern: "\\^\\{([^\\}]*)\\}")
        var unprocessedString = self
        var resultString = String()

        while let match = regex.firstMatch(in: unprocessedString, options: .reportCompletion, range: NSRange(location: 0, length: unprocessedString.count)) {
                // add substring before match
                let substringRange = unprocessedString.index(unprocessedString.startIndex, offsetBy: match.range.location)
                let subString = unprocessedString.prefix(upTo: substringRange)
                resultString.append(String(subString))

                // add match with subscripted style
                let capturedSubstring = NSAttributedString(string: unprocessedString).attributedSubstring(from: match.range(at: 1)).mutableCopy() as! NSMutableAttributedString
                capturedSubstring.string.forEach { (char) in
                    let superScript = char.unicode
                    let string = NSAttributedString(string: superScript)
                    resultString.append(string.string)
                }

                // strip off the processed part
                unprocessedString.deleteCharactersInRange(range: NSRange(location: 0, length: match.range.location + match.range.length))
        }

        // add substring after last match
        resultString.append(unprocessedString)
        return resultString
    }

    mutating func deleteCharactersInRange(range: NSRange) {
        let mutableSelf = NSMutableString(string: self)
        mutableSelf.deleteCharacters(in: range)
        self = mutableSelf as String
    }
}

extension UILabel{
 // for Swift 4 add @objc for defaultFont to make UILabel.appearance() affect!
 @objc var defaultFont: UIFont? {
        get { return self.font }
        set {
          /* When ViewController still in navigation stack
            and appear each time, the font label will decrease
            till will disappear, so we need to call dp just one
            time for each label .*/
         
         // check if font is nil
            guard self.font != nil else {
                return
            }
         if self.tag == 0 {  // self.tag = 0 is default value .
             self.tag = 1
            let newFontSize = self.font.pointSize.dp // we get old font size and adaptive it with multiply it with dp.
            let oldFontName = self.font.fontName
            self.font = UIFont(name: oldFontName, size: newFontSize) // and set new font here .
         }
        }
    }
}

extension CGFloat {
    /**
     The relative dimension to the corresponding screen size.
     
     //Usage
     let someView = UIView(frame: CGRect(x: 0, y: 0, width: 320.dp, height: 40.dp)
     
     **Warning** Only works with size references from @1x mockups.
     
     */
    var dp: CGFloat {
        return (self / 320) * UIScreen.main.bounds.width
    }
}

extension String {
    
    private func filterCharacters(unicodeScalarsFilter closure: (UnicodeScalar) -> Bool) -> String {
        return String(String.UnicodeScalarView(unicodeScalars.filter { closure($0) }))
    }

    private func filterCharacters(definedIn charSets: [CharacterSet], unicodeScalarsFilter: (CharacterSet, UnicodeScalar) -> Bool) -> String {
        if charSets.isEmpty { return self }
        let charSet = charSets.reduce(CharacterSet()) { return $0.union($1) }
        return filterCharacters { unicodeScalarsFilter(charSet, $0) }
    }

    func removeCharacters(charSets: [CharacterSet]) -> String { return filterCharacters(definedIn: charSets) { !$0.contains($1) } }
    func removeCharacters(charSet: CharacterSet) -> String { return removeCharacters(charSets: [charSet]) }

    func onlyCharacters(charSets: [CharacterSet]) -> String { return filterCharacters(definedIn: charSets) { $0.contains($1) } }
    func onlyCharacters(charSet: CharacterSet) -> String { return onlyCharacters(charSets: [charSet]) }
    
    var onlyDigitsInString: String { return onlyCharacters(charSets: [.decimalDigits]) }
    var onlyLettersInString: String { return onlyCharacters(charSets: [.letters]) }
}

public struct LengthFormatters {

    public static let imperialLengthFormatter: LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.isForPersonHeightUse = true
        return formatter
    }()

}

extension Measurement where UnitType : UnitLength {

    var heightOnFeetsAndInches: String? {
        guard let measurement = self as? Measurement<UnitLength> else {
            return nil
        }
        
        
        let meters = measurement.converted(to: .meters).value
        
        
        return LengthFormatters.imperialLengthFormatter.string(fromMeters: meters)
    }

    var heightOnCentimeters: String? {
        guard let measurement = self as? Measurement<UnitLength> else {
            return nil
        }
        let centimeters = (measurement.converted(to: .centimeters).value) / 100
        return LengthFormatters.imperialLengthFormatter.string(fromMeters: centimeters)
    }
    
//    var heightInFeetString : String? {
//        guard let measurement = self as? Measurement<UnitLength> else {
//            return nil
//        }
//        let measurement = Measurement(value: Double(self.height) / 12.0, unit: UnitLength.feet)
//        let meters = measurement.converted(to: .meters).value
//        return LengthFormatters.imperialLengthFormatter.string(fromMeters: meters)
//    }

}

extension Measurement where UnitType == UnitLength {
    private static let usFormatted: MeasurementFormatter = {
       let formatter = MeasurementFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitStyle = .long
        return formatter
    }()
    var usFormatted: String { Measurement.usFormatted.string(from: self) }
}

extension MeasurementFormatter {
    func lengthStringFormat(from measurement: Measurement<UnitLength>) -> String
    {
        var measurement = measurement
        let unitOptions = self.unitOptions
        let unitStyle = self.unitStyle
        self.unitOptions = .naturalScale
        self.unitStyle = .long
        var string = self.string(from: measurement)
        if string.contains(self.string(from: UnitLength.miles))
        {
            self.unitStyle = unitStyle
            measurement.convert(to: UnitLength.feet)
            self.unitOptions = .providedUnit
            string = self.string(from: measurement)
        }
        else if string.contains(self.string(from: UnitLength.kilometers))
        {
            self.unitStyle = unitStyle
            measurement.convert(to: UnitLength.meters)
            self.unitOptions = .providedUnit
            string = self.string(from: measurement)
        }
        else
        {
            self.unitStyle = unitStyle
            string = self.string(from: measurement)
        }
        self.unitOptions = unitOptions
        return string
    }
}

extension UIScrollView {

    func resizeScrollViewContentSize() {

        var contentRect = CGRect.zero

        for view in self.subviews {

            contentRect = contentRect.union(view.frame)

        }

        self.contentSize = contentRect.size

    }

}

/** end of extension */
extension UIViewController {
    
    class func instantiateFromStoryboard(storyboard: String = "Main", name: String? = nil) -> UIViewController {
        
        let storyboardName = name ?? String(describing: self)
        return UIStoryboard.init(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardName)
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(title: "OK", style: .default)
        DispatchQueue.main.async {
            alert.show()
            //self.app_delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertFromController(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(title: "OK", style: .default)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String? ,tapped: (() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(title: "OK", style: .default) { (action) in tapped?() }
        //Threads.performTaskInMainQueue {
            alert.show()
        //}
    }
    
    func showAlert(title: String?, message: String? , positiveText: String, negativeText: String,success: (() -> Void)? , cancel: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(title: positiveText, style: .default) { (action) in success?() }
        alert.addAction(title: negativeText, style: .cancel)  { (action) in cancel?() }
        //Threads.performTaskInMainQueue {
            alert.show()
        //}
    }
    
    func showAlertWithAction(title: String?, message: String? , buttonTitle: String, buttonAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(title: buttonTitle, style: .default) { (action) in buttonAction?() }
        Threads.performTaskInMainQueue {
            alert.show()
        }
    }
    
    func configureChildViewController(_ childController: UIViewController, onView: UIView?) {
        var holderView = self.view
        if let onView = onView {
            holderView = onView
        }
        addChild(childController)
        holderView?.addSubview(childController.view)
        holderView?.constrainViewEqual(childController.view)
        childController.didMove(toParent: self)
    }
}

extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return ""
        }
    }

}

extension UINavigationController {
    
    class func uinavigationFromStoryboard(storyboard: String = "Main", name: String? = nil) -> UIViewController {
        let storyboardName = name ?? String(describing: self)
        
        return UIStoryboard.init(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardName)
    }
}

extension NSMutableAttributedString {
    func setFont(_ text:String, font: UIFont) -> NSMutableAttributedString {
        let attrs = [ NSAttributedString.Key.font: font]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes: attrs)
        
        self.append(boldString)
        return self
    }
}

extension CAGradientLayer {
    
    func gradient(reversed: Bool) -> CAGradientLayer {
        let black = UIColor.darkGray.withAlphaComponent(0.25).cgColor
        var gradientColors: [CGColor] = [UIColor(white: 1.0, alpha: 0).cgColor, black]
        
        if reversed {
            gradientColors = gradientColors.reversed()
        }
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        
        return gradientLayer
    }
}

extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
    
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}

extension Double {
    var mileseconds : Double {
        return self * 1000
    }
    var seconds : Double {
        return self / 1000
    }
    
    var customFormattedTime : String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.timeZone = TimeZone.current
        
        if NSCalendar.current.isDateInToday(date) {
            formatter.dateFormat = "hh:mm a"
        } else if NSCalendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "hh:mm a"
            return "yesterday,\n" + formatter.string(from: date)
        } else if date.isDateInThisYear() {
            formatter.dateFormat = "MMM dd,\n hh:mm a"
        } else {
            formatter.dateFormat = "MMM dd yyyy,\n hh:mm a"
        }
        
        let defaultTimeZoneStr = formatter.string(from: date)
        return defaultTimeZoneStr
    }
}

extension Date {
    func isDateInThisYear() -> Bool {
        let date = Date()
        let value = self
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        let valueYear = calendar.component(.year, from: value)
        
        if currentYear == valueYear {
            return true
        }
        return false
    }
    
    func toString(withFormat format: String = "EEEE ، d MMMM yyyy") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.dateFormat = format
        let strMonth = dateFormatter.string(from: self)
        
        return strMonth
    }
    
    func offsetFrom(date: Date) -> String {
        //let difference = NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: date, toDate: self, options: [])
        let difference = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: self)
        
        var seconds : String = ""
        var minutes : String = ""
        var hours : String = ""
        var days : String = ""
        
        let tmp1 : String = String(format: "%.2d", difference.second ?? 0)
        let tmp2 : String = String(format: "%.2d", difference.minute ?? 0)
        let tmp3 : String = String(format: "%.2d", difference.hour ?? 0)
        let tmp4 : String = String(format: "%d", difference.day ?? 0)
        
        seconds = "\(tmp1)"
        minutes = "\(tmp2)" + ":" + seconds
        hours = "\(tmp3)" + ":" + minutes
        
        if tmp4 == "0" {
            days = hours
            
            if difference.second ?? 0 >= 0 && difference.minute ?? 0 >= 0 && difference.hour ?? 0 >= 0 && difference.day ?? 0 >= 0 {
                return days
            }
            else {
                return ""
            }
        } else {
            days =  (Int(tmp4) ?? 0 > 1 ? "\(tmp4) days" : "\(tmp4) day")
            
            if difference.second ?? 0 >= 0 && difference.minute ?? 0 >= 0 && difference.hour ?? 0 >= 0 && difference.day ?? 0 >= 0 {
                return days
            }
                
            else {
                return ""
            }
        }
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
//    func isBetween(_ date1: Date, and date2: Date) -> Bool {
//            return (min(date1, date2) ... max(date1, date2)) ~= self
//        }
    
    func isBetween(_ date1: Date, _ date2: Date) -> Bool {
            let minDate = min(date1, date2)
            let maxDate = max(date1, date2)

            guard self != minDate else { return true }
            guard self != maxDate else { return false }

            return DateInterval(start: minDate, end: maxDate).contains(self)
        }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension NSObject {
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
}

extension CALayer {
    
    func configureGradientBackground(colors:CGColor...) {
        
        let gradient = CAGradientLayer()
        
        let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
        let squareFrame = CGRect(origin: self.bounds.origin, size: CGSize(width: maxWidth, height: maxWidth))
        gradient.frame = squareFrame
        gradient.colors = colors
        
        self.insertSublayer(gradient, at: 0)
    }
}

extension String {
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
    
    
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
    
    func replaceCharacters(characters: String, toSeparator: String) -> String {
        let characterSet = CharacterSet(charactersIn: characters)
        //let components = self.componentsSeparatedByCharactersInSet(characterSet)
        let components = self.components(separatedBy: characterSet)
        //let result = components.joinWithSeparator("")
        let result = components.joined(separator: "")
        return result
    }

    func wipeCharacters(characters: String) -> String {
        return self.replaceCharacters(characters: characters, toSeparator: "")
    }
    
    func stripCharacters(_ characters: [String]) -> String {
        var output = self
        for character in characters {
            output = replacingOccurrences(of: character, with: "")
        }
        return output
    }
    
    func HTMLImageCorrector() -> String {
        var HTMLToBeReturned = self
        while HTMLToBeReturned.range(of: "(?<=width=\")[^\" height]+", options: .regularExpression) != nil{
            if let match = HTMLToBeReturned.range(of: "(?<=width=\")[^\" height]+", options: .regularExpression) {
                HTMLToBeReturned.removeSubrange(match)
                if let match2 = HTMLToBeReturned.range(of: "(?<=height=\")[^\"]+", options: .regularExpression) {
                    HTMLToBeReturned.removeSubrange(match2)
                    let string2del = "width=\"\" height=\"\""
                    HTMLToBeReturned = HTMLToBeReturned.replacingOccurrences(of: string2del, with: "style=\"width: 100%\"")
                }
            }
            
        }
        
        return HTMLToBeReturned
    }
    
    func customCount() -> Int {
        let trimmedString = self.components(separatedBy: .whitespaces).joined()
        return trimmedString.count
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func foundHttpReference() -> String? {
        let pat = "<a[^>]+href=\"(.*?)\"[^>]*>(.*)?</a>"
        let regex = try! NSRegularExpression(pattern: pat)
        let range = NSMakeRange(0, self.count)
        let matches = regex.matches(in: self, range: range)
        for match in matches {
            let htmlLessString = (self as NSString).substring(with: match.range(at: 1))
            return htmlLessString
        }
        return nil
    }
    
    func isEmptyOrWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        
        return (self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "")
    }
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
        
    }
    
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }

        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }

        return String(self[substringStartIndex ..< substringEndIndex])
    }
}
extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: self, options: nil)![0] as! T
    }

    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    fileprivate func constrainViewEqual(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
        self.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
    
    func animate(fadeIn: Bool, withDuration: TimeInterval = 1.0) {
        UIView.animate(withDuration: withDuration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.alpha = fadeIn ? 1.0 : 0.0
        })
    }
    
    func animateFadeInOut(withDuration: TimeInterval = 1.0) {
        self.isUserInteractionEnabled = !self.isUserInteractionEnabled
        UIView.animate(withDuration: withDuration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.alpha = self.isUserInteractionEnabled ? 1.0 : 0.0
        })
    }
}

public extension UIDevice {
    
    /// pares the deveice name as the standard name
    var modelName: String {
        
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        default:                                        return identifier
        }
    }
    
}

extension UITextView {
    
    /**
     Calculates if new textview height (based on content) is larger than a base height
     
     - parameter baseHeight: The base or minimum height
     
     - returns: The new height
     */
    func newHeight(withBaseHeight baseHeight: CGFloat) -> CGFloat {
        
        // Calculate the required size of the textview
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = frame
        
        // Height is always >= the base height, so calculate the possible new height
        let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: height)
        
        return newFrame.height
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}
extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension UIRefreshControl {
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
    }
}

extension UIColor {
    convenience init(hexstr: String) {
        let hex = hexstr.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.alpha = 0.0
        }, completion: completion)
    }
    
    //BORDERS
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var leftBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: 0.0, width: newValue, height: bounds.height))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = UIColor(cgColor: layer.borderColor!)
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line(==lineWidth)]", options: [], metrics: metrics, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line]|", options: [], metrics: nil, views: views))
        }
    }
    
    @IBInspectable var topBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: newValue))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line(==lineWidth)]", options: [], metrics: metrics, views: views))
        }
    }
    
    @IBInspectable var rightBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: bounds.width, y: 0.0, width: newValue, height: bounds.height))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[line(==lineWidth)]|", options: [], metrics: metrics, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line]|", options: [], metrics: nil, views: views))
        }
    }
    @IBInspectable var bottomBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: bounds.height, width: bounds.width, height: newValue))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(==lineWidth)]|", options: [], metrics: metrics, views: views))
        }
    }
}

@IBDesignable public class GradientView: UIView {

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureGradientLayer()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureGradientLayer()
    }

    func configureGradientLayer() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.init(hexString: "#55a4da").cgColor, UIColor.init(hexString: "#7dc29b").cgColor]
    }
}

extension UILabel {
    
    @IBInspectable var kerning: Float {
        get {
            var range = NSMakeRange(0, (text ?? "").count)
            guard let kern = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: &range),
                let value = kern as? NSNumber
                else {
                    return 0
            }
            return value.floatValue
        }
        set {
            var attText:NSMutableAttributedString
            
            if let attributedText = attributedText {
                attText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = text {
                attText = NSMutableAttributedString(string: text)
            } else {
                attText = NSMutableAttributedString(string: "")
            }
            
            let range = NSMakeRange(0, attText.length)
            attText.addAttribute(NSAttributedString.Key.kern, value: NSNumber(value: newValue), range: range)
            self.attributedText = attText
        }
    }
}

extension UIButton {
    
    @IBInspectable
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedTitle(for: .normal) {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: self.titleLabel?.text ?? "")
                setTitle(.none, for: .normal)
            }
            
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            
            setAttributedTitle(attributedString, for: .normal)
        }
        
        get {
            if let currentLetterSpace = attributedTitle(for: .normal)?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}

@IBDesignable
class PaddedLabel: UILabel {
    
    @IBInspectable var inset:CGSize = CGSize(width: 0, height: 0)
    
    var padding: UIEdgeInsets {
        var hasText:Bool = false
        if let t = self.text?.count, t > 0 {
            hasText = true
        }
        else if let t = attributedText?.length, t > 0 {
            hasText = true
        }
        
        return hasText ? UIEdgeInsets(top: inset.height, left: inset.width, bottom: inset.height, right: inset.width) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let p = padding
        let width = superContentSize.width + p.left + p.right
        let heigth = superContentSize.height + p.top + p.bottom
        return CGSize(width: width, height: heigth)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let p = padding
        let width = superSizeThatFits.width + p.left + p.right
        let heigth = superSizeThatFits.height + p.top + p.bottom
        return CGSize(width: width, height: heigth)
    }
}

extension UIButton {
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

extension UILabel {
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

@IBDesignable
extension UITextField {
    
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        // Swift 4.1 and below
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
}

extension UIDevice {
    var isSimulator: Bool {
        #if IOS_SIMULATOR
        return true
        #else
        return false
        #endif
    }
}

extension UITableViewCell {
    func removeSectionSeparators() {
        for subview in subviews {
            if subview != contentView && subview.frame.width == frame.width {
                subview.removeFromSuperview()
            }
        }
    }
}

extension UITextView {
    func textViewInset() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
    }
}

extension URL {
    
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

extension UIView {

    func applyGradient(isTopBottom: Bool, colorArray: [UIColor]) {
        if let sublayers = layer.sublayers {
            let _ = sublayers.filter({ $0 is CAGradientLayer }).map({ $0.removeFromSuperlayer() })
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isTopBottom {
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //leftRight
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

}

extension UISearchBar {
    func changeSearchBarColor(fieldColor: UIColor, backColor: UIColor, borderColor: UIColor?) {
        UIGraphicsBeginImageContext(bounds.size)
        backColor.setFill()
        UIBezierPath(rect: bounds).fill()
        setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext()!, for: UIBarPosition.any, barMetrics: .default)
        
        let newBounds = bounds.insetBy(dx: 0, dy: 8)
        fieldColor.setFill()
        let path = UIBezierPath(roundedRect: newBounds, cornerRadius: newBounds.height / 2)
        
        if let borderColor = borderColor {
            borderColor.setStroke()
            path.lineWidth = 1 / UIScreen.main.scale
            path.stroke()
        }
        
        path.fill()
        setSearchFieldBackgroundImage(UIGraphicsGetImageFromCurrentImageContext()!, for: UIControl.State.normal)
        
        UIGraphicsEndImageContext()
    }
}

extension UIViewController {
    var app_delegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

extension UIApplicationDelegate {

    static var shared: Self {
        return UIApplication.shared.delegate! as! Self
    }
}

private var GlowLayerAssociatedObjectKey = "SPGlowLayerAssociatedObjectKey"

public extension UIView {

  private var glowLayer: CALayer? {
    get {
      return objc_getAssociatedObject(self, &GlowLayerAssociatedObjectKey) as? CALayer
    } set {
      objc_setAssociatedObject(self, &GlowLayerAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }

  /// Starts glowing view with options.
  ///
  /// - parameter color:         Glow color.
  /// - parameter fromIntensity: Glow start intensity.
  /// - parameter toIntensity:   Glow end intensity.
  /// - parameter fill:          If true, glows inside the view as well. If not, only glows outer border.
  /// - parameter position:      Sets position of glow over view. Defaults center.
  /// - parameter duration:      Duration of one pulse of glow.
  /// - parameter shouldRepeat:  If true, repeats until stop. If not, pulses just once.
  /// - parameter glowOnce:      Should it glow once and stop glowing or glows until `stopGlowing` called. It's not effective if repeat is on. Defauts true.
    func startGlowing(
    color: UIColor = .white,
    fromIntensity: CGFloat = 0,
    toIntensity: CGFloat = 1,
    fill: Bool = false,
    position: CGPoint? = nil,
    duration: TimeInterval = 1,
    repeat shouldRepeat: Bool = true,
    glowOnce: Bool = true) {

    // If we're already glowing, don't bother
    guard glowLayer == nil
      else { return }

    glowLayer = CALayer()
    guard let glowLayer = glowLayer
      else { return }

    // The glow image is taken from the current view's appearance.
    // As a side effect, if the view's content, size or shape changes,
    // the glow won't update.
    var image: UIImage?

    UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
    if let context = UIGraphicsGetCurrentContext() {
      layer.render(in: context)
      if fill {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        color.setFill()
        path.fill(with: .sourceAtop, alpha: 1.0)
      }
      image = UIGraphicsGetImageFromCurrentImageContext()
    }
    UIGraphicsEndImageContext()

    // Setup glowLayer
    glowLayer.frame = CGRect(origin: position ?? bounds.origin, size: frame.size)
    glowLayer.contents = image?.cgImage
    glowLayer.opacity = 0
    glowLayer.shadowColor = color.cgColor
    glowLayer.shadowOffset = CGSize.zero
    glowLayer.shadowRadius = 10
    glowLayer.shadowOpacity = 1
    glowLayer.rasterizationScale = UIScreen.main.scale
    glowLayer.shouldRasterize = true
    layer.addSublayer(glowLayer)

    // Create an animation that slowly fades the glow view in and out forever.
    let animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = fromIntensity
    animation.toValue = toIntensity
    animation.repeatCount = shouldRepeat ? .infinity : 0
    animation.duration = duration
    animation.autoreverses = shouldRepeat || glowOnce
    animation.isRemovedOnCompletion = shouldRepeat || glowOnce
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    glowLayer.add(animation, forKey: "glowViewPulseAnimation")

    // Stop glowing after duration if not repeats
    if !shouldRepeat && glowOnce {
      let delay = duration * Double(Int64(NSEC_PER_SEC))
      DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + delay,
        execute: { [weak self] in
          self?.stopGlowing()
        })
    }
  }

  /// Stop glowing by removing the glowing view from the superview
  /// and removing the association between it and this object.
  func stopGlowing() {
    glowLayer?.removeFromSuperlayer()
    glowLayer = nil
  }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {

        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
    }

        return self
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

extension AVPlayer {
   func stop(){
    self.seek(to: CMTime.zero)
    self.pause()
   }
}

extension TimeInterval {
    func convertSecondString() -> String {
        let component =  Date.dateComponentFrom(second: self)
        if let hour = component.hour ,
            let min = component.minute ,
            let sec = component.second {
            
            let fix =  hour > 0 ? NSString(format: "%02d:", hour) : ""
            let a = NSString(format: "%@%02d:%02d", fix,min,sec) as String
            return a
        } else {
            return "-:-"
        }
    }
}
extension Date {
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let c = NSCalendar.current
        
        var components = c.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date1, to: date2)
        components.calendar = c
        return components
    }
    
    func isEqualTo(_ date: Date) -> Bool {
      return self == date
    }

    func isGreaterThan(_ date: Date) -> Bool {
       return self > date
    }

    func isSmallerThan(_ date: Date) -> Bool {
       return self < date
    }
}

extension String {
    var utf8Array: [UInt8] {
        return Array(utf8)
    }
}

extension StringProtocol {
    var Utf8Data: Data { .init(utf8) }
    var Utf8bytes: [UInt8] { .init(utf8) }
    var Utf16bytes: [UInt16] { .init(utf16) }
}

extension UIStackView {
    @discardableResult
    func removeAllArrangedSubviews() -> [UIView] {
        return arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }

    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}

class DeviceUI {
  // Base width in point, use iPhone 6
  static let base: CGFloat = 375

  static var ratio: CGFloat {
    return UIScreen.main.bounds.width / base
  }
}

extension CGFloat {

  var adjusted: CGFloat {
    return self * DeviceUI.ratio
  }
}

extension Double {

  var adjusted: CGFloat {
    return CGFloat(self) * DeviceUI.ratio
  }
}

extension Int {

  var adjusted: CGFloat {
    return CGFloat(self) * DeviceUI.ratio
  }
}

/**
 label.font = UIFont.systemFont(ofSize: 23.adjusted)

 phoneTextField.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 30.adjusted),
 phoneTextField.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -30.adjusted),

 imageView.widthAnchor.constraint(equalToConstant: 80.adjusted), imageView.heightAnchor.constraint(equalToConstant: 90.adjusted),
 */

extension UICollectionView {
    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
}

extension UIView {
    var allSubviews: [UIView] {
        return self.subviews + self.subviews.map { $0.allSubviews }.joined()
    }
}

extension UIView {

    func embedInScrollView()->UIView{
        let cont=UIScrollView()

        self.translatesAutoresizingMaskIntoConstraints = false;
        cont.translatesAutoresizingMaskIntoConstraints = false;
        cont.addSubview(self)
        cont.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[innerView]|", options: NSLayoutConstraint.FormatOptions(rawValue:0),metrics: nil, views: ["innerView":self]))
        cont.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[innerView]|", options: NSLayoutConstraint.FormatOptions(rawValue:0),metrics: nil, views: ["innerView":self]))
        cont.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: cont, attribute: .width, multiplier: 1.0, constant: 0))
        return cont
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var convertToUint16: UInt16 {
        withUnsafeBytes { $0.bindMemory(to: UInt16.self) }[0]
    }
    
    var convertTouint32: UInt32 {
        withUnsafeBytes { $0.bindMemory(to: UInt32.self) }[0]
    }
    
//    var uint64: UInt64 {
//            get {
//                if count >= 8 {
//                    return self.withUnsafeBytes { $0.load(as: UInt64.self) }
//                } else {
//                    return (self + Data(repeating: 0, count: 8 - count)).uint64
//                }
//            }
//        }
    
    var uint64: UInt64 {
            get {
                if count >= 8 {
                    return self.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
                } else {
                    return (Data(repeating: 0, count: 8 - count) + self).uint64
                }
            }
        }
}

extension NSDate {

    /** Returns a NSDate instance from a time stamp */
    convenience init(timeStamp: Double) {
        self.init(timeIntervalSince1970: timeStamp)
    }
}


extension Double {

    /** Returns a timeStamp from a NSDate instance */
    static func timeStampFromDate(date: NSDate) -> Double {
        return date.timeIntervalSince1970
    }
}

extension String {
    var hexaToBinary: String {
        return hexaToBytes.map {
            let binary = String($0, radix: 2)
            return repeatElement("0", count: 8-binary.count) + binary
        }.joined()
    }

    private var hexaToBytes: [UInt8] {
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let end = index(after: start)
            defer { start = index(after: end) }
            return UInt8(self[start...end], radix: 16)
        }
    }
}

extension Int {

    //From Decimal
    //10 -> 2
    func decToBinString() -> String {
        let result = createString(radix: 2)
        return result
    }

    //10 -> 8
    func decToOctString() -> String {
//        let result = decToOctStringFormat()
        let result = createString(radix: 8)

        return result
    }

    //10 -> 16
    func decToHexString() -> String {
//        let result = decToHexStringFormat()
        let result = createString(radix: 16)
        return result
    }

    //10 -> 8
    func decToOctStringFormat(minLength: Int = 0) -> String {

        return createString(minLength: minLength, system: "O")
    }

    //10 -> 16
    func decToHexStringFormat(minLength: Int = 0) -> String {

        return createString(minLength: minLength, system: "X")
    }

    fileprivate  func createString(radix: Int) -> String {
        return String(self, radix: radix, uppercase: true)
    }

    fileprivate func createString(minLength: Int = 0, system: String) -> String {
        //0 - fill empty space by 0
        //minLength - min count of chars
        //system - system number
        return String(format:"%0\(minLength)\(system)", self)
    }
}

extension String {

    //To Decimal
    //2 -> 10
    func binToDec() -> Int {
        return createInt(radix: 2)
    }

    //8 -> 10
    func octToDec() -> Int {
        return createInt(radix: 8)
    }

    //16 -> 10
    func hexToDec() -> Int {
        return createInt(radix: 16)
    }

    //Others
    //2 -> 8
    func binToOct() -> String {
        return self.binToDec().decToOctString()
    }

    //2 -> 16
    func binToHex() -> String {
        return self.binToDec().decToHexString()
    }

    //8 -> 16
    func octToHex() -> String {
        return self.octToDec().decToHexString()
    }

    //16 -> 8
    func hexToOct() -> String {
        return self.hexToDec().decToOctString()
    }

    //16 -> 2
    func hexToBin() -> String {
        return self.hexToDec().decToBinString()
    }

    //8 -> 2
    func octToBin() -> String {
        return self.octToDec().decToBinString()
    }

    //Additional
    //16 -> 2
    func hexToBinStringFormat(minLength: Int = 0) -> String {

        return hexToBin().pad(minLength: minLength)
    }

    func pad(minLength: Int) -> String {
        let padCount = minLength - self.count

        guard padCount > 0 else {
            return self
        }

        return String(repeating: "0", count: padCount) + self
    }

    fileprivate func createInt(radix: Int) -> Int {
        return Int(self, radix: radix)!
    }

}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension String {

    /// the length of the string
    var length: Int {
        return self.count
    }

    /// Get substring, e.g. "ABCDE".substring(index: 2, length: 3) -> "CDE"
    ///
    /// - parameter index:  the start index
    /// - parameter length: the length of the substring
    ///
    /// - returns: the substring
    public func SPByteData(index: Int, length: Int) -> String {
        if self.length <= index {
            return "0"
        }
        let leftIndex = self.index(self.startIndex, offsetBy: index)
        if self.length <= index + length {
            return String(self[..<leftIndex])
        }
        let rightIndex = self.index(self.endIndex, offsetBy: -(self.length - index - length))
        //return self.substring(with: leftIndex..<rightIndex)
        return String(self[leftIndex..<rightIndex])
    }

    /// Get substring, e.g. -> "ABCDE".substring(left: 0, right: 2) -> "ABC"
    ///
    /// - parameter left:  the start index
    /// - parameter right: the end index
    ///
    /// - returns: the substring
    public func SPByteData(left: Int, right: Int) -> String {
        if length <= left {
            return "0"
        }
        let leftIndex = self.index(self.startIndex, offsetBy: left)
        if length <= right {
            //return self.substring(from: leftIndex)
            return String(self[..<leftIndex])
        }
        else {
            let rightIndex = self.index(self.endIndex, offsetBy: -self.length + right + 1)
            //return self.substring(with: leftIndex..<rightIndex)
            return String(self[leftIndex..<rightIndex])
        }
    }
}

extension Array where Element: CustomStringConvertible {
  public func stringRepresentation(separator: String = "") -> String {
    return self.map{ $0.description }.joined(separator: ",")
  }
}

extension Character {
    var byte: UInt8 {
        return String(self).utf8.map{UInt8($0)}[0]
    }

    var short: UInt16 {
        return String(self).utf16.map{UInt16($0)}[0]
    }
}

extension Sequence where Element == Character {
    var byteArray: [UInt8] {
        return String(self).utf8.map{UInt8($0)}
    }

    var shortArray: [UInt16] {
        return String(self).utf16.map{UInt16($0)}
    }
}

extension String {
    
    public func pad(with padding: Character, toLength length: Int) -> String {
        let paddingWidth = length - self.count
        guard 0 < paddingWidth else { return self }

        return String(repeating: padding, count: paddingWidth) + self
    }
    
}

extension UInt8 {
     public func toBits() -> String
     {
          let a = String( self, radix : 2 )
          let b = a.pad(with: "0", toLength: 8)
          return b
     }
}

extension Data {
    var array: [UInt8] { return Array(self) }
}

extension Data {
    
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    var uint16: UInt16 {
        get {
            let i16array = self.withUnsafeBytes { $0.load(as: UInt16.self) }
            return i16array
        }
    }
    
    var uint32: UInt32 {
        get {
            let i32array = self.withUnsafeBytes { $0.load(as: UInt32.self) }
            return i32array
        }
    }
    
    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
            return NSUUID(uuidBytes: bytes)
        }
    }
    var stringASCII: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
    
    var stringUTF8: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
}

extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
    
    var byteArrayLittleEndian: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
}

extension Numeric {
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}

extension BinaryInteger {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = self
        var counter = 0

        for _ in (1...self.bitWidth) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
            if counter % 4 == 0 {
                binaryString.insert(contentsOf: " ", at: binaryString.startIndex)
            }
        }

        return binaryString
    }
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

extension String {
    
    var utf16Array: [UInt16] {
        return Array(utf16)
    }
}

extension Array {
    
    @discardableResult
    mutating func insert(_ newArray: Array, at index: Int) -> CountableRange<Int> {
        let mIndex = Swift.max(0, index)
        let start = Swift.min(count, mIndex)
        let end = start + newArray.count
        
        let left = self[0..<start]
        let right = self[start..<count]
        self = left + newArray + right
        return start..<end
    }
    
    mutating func remove<T: AnyObject> (_ element: T) {
        let anotherSelf = self
        
        removeAll(keepingCapacity: true)
        
        anotherSelf.each { (index: Int, current: Element) in
            if (current as! T) !== element {
                self.append(current)
            }
        }
    }
    
    func each(_ exe: (Int, Element) -> ()) {
        for (index, item) in enumerated() {
            exe(index, item)
        }
    }
}

extension Array where Element: Equatable {
    
    /// Remove Dublicates
    var unique: [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        return self.reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }

    /// Check if array contains an array of elements.
    ///
    /// - Parameter elements: array of elements to check.
    /// - Returns: true if array contains all given items.
    public func contains(_ elements: [Element]) -> Bool {
        guard !elements.isEmpty else { // elements array is empty
            return false
        }
        var found = true
        for element in elements {
            if !contains(element) {
                found = false
            }
        }
        return found
    }
    
    /// All indexes of specified item.
    ///
    /// - Parameter item: item to check.
    /// - Returns: an array with all indexes of the given item.
    public func indexes(of item: Element) -> [Int] {
        var indexes: [Int] = []
        for index in 0..<self.count {
            if self[index] == item {
                indexes.append(index)
            }
        }
        return indexes
    }
    
    /// Remove all instances of an item from array.
    ///
    /// - Parameter item: item to remove.
    public mutating func removeAll(_ item: Element) {
        self = self.filter { $0 != item }
    }
    
    /// Creates an array of elements split into groups the length of size.
    /// If array can’t be split evenly, the final chunk will be the remaining elements.
    ///
    /// - parameter array: to chunk
    /// - parameter size: size of each chunk
    /// - returns: array elements chunked
    public func chunk(size: Int = 1) -> [[Element]] {
        var result = [[Element]]()
        var chunk = -1
        for (index, elem) in self.enumerated() {
            if index % size == 0 {
                result.append([Element]())
                chunk += 1
            }
            result[chunk].append(elem)
        }
        return result
    }
}

public extension Array {
    
    /// Random item from array.
    var randomItem: Element? {
        if self.isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    
    /// Shuffled version of array.
    var shuffled: [Element] {
        var arr = self
        for _ in 0..<10 {
            arr.sort { (_,_) in arc4random() < arc4random() }
        }
        return arr
    }
    
    /// Shuffle array.
    mutating func shuffle() {
        // https://gist.github.com/ijoshsmith/5e3c7d8c2099a3fe8dc3
        for _ in 0..<10 {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

extension String {
    
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        let range: Range<Index> = start..<end
        return String(self[range])
    }
    
    var containsAlphabets: Bool {
        //Checks if all the characters inside the string are alphabets
        let set = CharacterSet.letters
        return self.utf16.contains {
            guard let unicode = UnicodeScalar($0) else { return false }
            return set.contains(unicode)
        }
    }
}

// MARK: - NSAttributedString extensions
internal extension String {
    
    /// Regular string.
    var regular: NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
    }
    
    /// Bold string.
    var bold: NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)])
    }
    
    /// Underlined string
    var underline: NSAttributedString {
        return NSAttributedString(string: self, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    /// Strikethrough string.
    var strikethrough: NSAttributedString {
        return NSAttributedString(string: self, attributes: [.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue as Int)])
    }
    
    /// Italic string.
    var italic: NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)])
    }
    
    /// Add color to string.
    ///
    /// - Parameter color: text color.
    /// - Returns: a NSAttributedString versions of string colored with given color.
    func colored(with color: UIColor) -> NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.foregroundColor: color])
    }
}

enum MovementType: Int {
    case DOWN = 7
    case UP = 4
    case INVALID = 100
    
    var movement: String {
        switch self {
        case .DOWN:
          return "DOWN"
        case .UP:
          return "UP"
        case .INVALID:
          return "INVALID"
        }
    }
    
    var readableMovement: String {
        switch self {
        case .DOWN:
          return "Sit"
        case .UP:
          return "Stand"
        case .INVALID:
          return "INVALID"
        }
    }
    
    var movementRawString: String {
        switch self {
        case .DOWN:
          return "7"
        case .UP:
          return "4"
        case .INVALID:
          return "100"
        }
    }
}

protocol Loopable {
    var allProperties: [String: Any] { get }
    
}
extension Loopable {
    var allProperties: [String: Any] {
        var result = [String: Any]()
        Mirror(reflecting: self).children.forEach { child in
            if let property = child.label {
                result[property] = child.value
            }
        }
        return result
    }
}


extension NSString: Loopable {}

extension Data {

    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }

    var decimalString: String {
        return map { String(format: "%d", $0) }.joined(separator: " ")
    }

}


extension String {
        // Returns true if the String starts with a substring matching to the prefix-parameter.
        // If isCaseSensitive-parameter is true, the function returns false,
        // if you search "sA" from "San Antonio", but if the isCaseSensitive-parameter is false,
        // the function returns true, if you search "sA" from "San Antonio"

        func hasPrefixCheck(prefix: String, isCaseSensitive: Bool) -> Bool {

            if isCaseSensitive == true {
                return self.hasPrefix(prefix)
            } else {
                var thePrefix: String = prefix, theString: String = self

                while thePrefix.count != 0 {
                    if theString.count == 0 { return false }
                    if theString.lowercased().first != thePrefix.lowercased().first { return false }
                    theString = String(theString.dropFirst())
                    thePrefix = String(thePrefix.dropFirst())
                }; return true
            }
        }
        // Returns true if the String ends with a substring matching to the prefix-parameter.
        // If isCaseSensitive-parameter is true, the function returns false,
        // if you search "Nio" from "San Antonio", but if the isCaseSensitive-parameter is false,
        // the function returns true, if you search "Nio" from "San Antonio"
        func hasSuffixCheck(suffix: String, isCaseSensitive: Bool) -> Bool {

            if isCaseSensitive == true {
                return self.hasSuffix(suffix)
            } else {
                var theSuffix: String = suffix, theString: String = self

                while theSuffix.count != 0 {
                    if theString.count == 0 { return false }
                    if theString.lowercased().last != theSuffix.lowercased().last { return false }
                    theString = String(theString.dropLast())
                    theSuffix = String(theSuffix.dropLast())
                }; return true
            }
        }
        // Returns true if the String contains a substring matching to the prefix-parameter.
        // If isCaseSensitive-parameter is true, the function returns false,
        // if you search "aN" from "San Antonio", but if the isCaseSensitive-parameter is false,
        // the function returns true, if you search "aN" from "San Antonio"
        func containsSubString(theSubString: String, isCaseSensitive: Bool) -> Bool {

            if isCaseSensitive == true {
                return self.range(of: theSubString) != nil
            } else {
                return self.range(of: theSubString, options: .caseInsensitive) != nil
            }
        }
    }

extension UIApplication {
  func isFirstLaunch() -> Bool {
    if !UserDefaults.standard.bool(forKey: Constants.HasLaunched) {
      UserDefaults.standard.set(true, forKey: Constants.HasLaunched)
      UserDefaults.standard.synchronize()
      return true
  }
    return false
  }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    func roundTo0f() -> NSString
    {
      return NSString(format: "%.0f", self)
    }

    func roundTo1f() -> NSString
    {
      return NSString(format: "%.1f", self)
    }

    func roundTo2f() -> NSString
    {
      return NSString(format: "%.2f", self)
    }

    func roundToNf(n : Int) -> NSString
    {
      return NSString(format: "%.\(n)f" as NSString, self)
    }
    
    func toInt() -> Int? {
        guard (self <= Double(Int.max).nextDown) && (self >= Double(Int.min).nextUp) else {
            return nil
        }

        return Int(self)
    }
}

extension String {
    func indexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.encodedOffset
    }
    
    func filterString(characters: String) -> String {
        return String(self.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: characters)) != nil })
    }
}

extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self {
        return filter(("0"..."9").contains)
    }
}

extension RangeReplaceableCollection where Self: StringProtocol {
    mutating func removeAllNonNumeric() {
        removeAll { !("0"..."9" ~= $0) }
    }
}

extension String {
    private static var digits = UnicodeScalar("0")..."9"
    var digits: String {
        return String(unicodeScalars.filter(String.digits.contains))
    }
}

enum AIEdge:Int {
    case
    Top,
    Left,
    Bottom,
    Right,
    Top_Left,
    Top_Right,
    Bottom_Left,
    Bottom_Right,
    All,
    None
}

enum BorderSide {
        case top(thickness: CGFloat = 1.0, color: UIColor = UIColor.lightGray)
        case bottom(thickness: CGFloat = 1.0, color: UIColor = UIColor.lightGray)
        case right(thickness: CGFloat = 1.0, color: UIColor = UIColor.lightGray)
        case left(thickness: CGFloat = 1.0, color: UIColor = UIColor.lightGray)
    }

extension UIView {
        
        func addBorder(on sides: [BorderSide]) {
            for side in sides {
                let border = UIView(frame: .zero)
                border.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(border)
                
                switch side {
                case .top(let thickness, let color):
                    NSLayoutConstraint(item: border, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: thickness).isActive = true
                    border.backgroundColor = color
                    
                case .bottom(let thickness, let color):
                    NSLayoutConstraint(item: border, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: thickness).isActive = true
                    border.backgroundColor = color
                    
                case .left(let thickness, let color):
                    NSLayoutConstraint(item: border, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: thickness).isActive = true
                    border.backgroundColor = color
                    
                case .right(let thickness, let color):
                    NSLayoutConstraint(item: border, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
                    NSLayoutConstraint(item: border, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: thickness).isActive = true
                    border.backgroundColor = color
                }
            }
        }
        
    func applyShadowWithCornerRadius(color:UIColor, opacity:Float, radius: CGFloat, edge:AIEdge, shadowSpace:CGFloat, cornerRadius: CGFloat)    {

        var sizeOffset:CGSize = CGSize.zero
        
        switch edge {
        case .Top:
            sizeOffset = CGSize(width: 0, height: -shadowSpace)
        case .Left:
            sizeOffset = CGSize(width: -shadowSpace, height: 0)
        case .Bottom:
            sizeOffset = CGSize(width: 0, height: shadowSpace)
        case .Right:
            sizeOffset = CGSize(width: shadowSpace, height: 0)
            
            
        case .Top_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: -shadowSpace)
        case .Top_Right:
            sizeOffset = CGSize(width: shadowSpace, height: -shadowSpace)
        case .Bottom_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: shadowSpace)
        case .Bottom_Right:
            sizeOffset = CGSize(width: shadowSpace, height: shadowSpace)
            
            
        case .All:
            sizeOffset = CGSize(width: 0, height: 0)
        case .None:
            sizeOffset = CGSize.zero
        }

        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = sizeOffset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false

        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.layer.cornerRadius).cgPath
    }
    
    func addShadow(to edges: [UIRectEdge], radius: CGFloat = 3.0, opacity: Float = 0.6, color: CGColor = UIColor.black.cgColor) {

            let fromColor = color
            let toColor = UIColor.clear.cgColor
            let viewFrame = self.frame
            for edge in edges {
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [fromColor, toColor]
                gradientLayer.opacity = opacity

                switch edge {
                case .top:
                    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                    gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: radius)
                case .bottom:
                    gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
                    gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
                    gradientLayer.frame = CGRect(x: 0.0, y: viewFrame.height - radius, width: viewFrame.width, height: radius)
                case .left:
                    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                    gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: radius, height: viewFrame.height)
                case .right:
                    gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
                    gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
                    gradientLayer.frame = CGRect(x: viewFrame.width - radius, y: 0.0, width: radius, height: viewFrame.height)
                default:
                    break
                }
                self.layer.addSublayer(gradientLayer)
            }
        }

        func removeAllShadows() {
            if let sublayers = self.layer.sublayers, !sublayers.isEmpty {
                for sublayer in sublayers {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
}

extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension StringProtocol {
    var asciiValues: [UInt32] {
        return compactMap { $0.ascii }
    }
}

extension String {

    func aesEncrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = self.data(using: String.Encoding.utf8),
            let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) {


            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)



            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                return base64cryptString


            }
            else {
                return nil
            }
        }
        return nil
    }

    func aesDecrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
            let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {

            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)

            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }

}


extension Data {
    func aesEncrypt( keyData: Data, ivData: Data, operation: Int) -> Data {
        let dataLength = self.count
        let cryptLength  = size_t(dataLength + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)

        let keyLength = size_t(kCCKeySizeAES128)
        let options = CCOptions(kCCOptionECBMode)


        var numBytesEncrypted :size_t = 0

        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            self.withUnsafeBytes {dataBytes in
                ivData.withUnsafeBytes {ivBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes, keyLength,
                                ivBytes,
                                dataBytes, dataLength,
                                cryptBytes, cryptLength,
                                &numBytesEncrypted)
                    }
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)

        } else {
            print("Error: \(cryptStatus)")
        }

        return cryptData;
    }
    
    func randomGenerateBytes(count: Int) -> Data? {
        let bytes = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
        defer { bytes.deallocate() }
        let status = CCRandomGenerateBytes(bytes, count)
        guard status == kCCSuccess else { return nil }
        return Data(bytes: bytes, count: count)
    }
    
    /// Encrypts for you with all the good options turned on: CBC, an IV, PKCS7
    /// padding (so your input data doesn't have to be any particular length).
    /// Key can be 128, 192, or 256 bits.
    /// Generates a fresh IV for you each time, and prefixes it to the
    /// returned ciphertext.
    func encryptAES_CBC_PKCS7_IV(key: Data, iv: Data) -> Data? {
        //guard let iv = randomGenerateBytes(count: kCCBlockSizeAES128) else { return nil }
        // No option is needed for CBC, it is on by default.
        guard let ciphertext = crypt(operation: kCCEncrypt,
                                    algorithm: kCCAlgorithmAES,
                                    options: kCCOptionPKCS7Padding,
                                    key: key,
                                    initializationVector: iv,
                                    dataIn: self) else { return nil }
        return iv + ciphertext
    }
    
    /// Decrypts self, where self is the IV then the ciphertext.
    /// Key can be 128/192/256 bits.
    func decryptAES_CBC_PKCS7_IV(key: Data) -> Data? {
        guard count > kCCBlockSizeAES128 else { return nil }
        let iv = prefix(kCCBlockSizeAES128)
        let ciphertext = suffix(from: kCCBlockSizeAES128)
        return crypt(operation: kCCDecrypt, algorithm: kCCAlgorithmAES,
            options: kCCOptionPKCS7Padding, key: key, initializationVector: iv,
            dataIn: ciphertext)
    }
    
    func crypt(operation: Int, algorithm: Int, options: Int, key: Data,
            initializationVector: Data, dataIn: Data) -> Data? {
        return key.withUnsafeBytes { keyUnsafeRawBufferPointer in
            return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
                    // Give the data out some breathing room for PKCS7's padding.
                    let dataOutSize: Int = dataIn.count + kCCBlockSizeAES128*2
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize,
                        alignment: 1)
                    defer { dataOut.deallocate() }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(CCOperation(operation), CCAlgorithm(algorithm),
                        CCOptions(options),
                        keyUnsafeRawBufferPointer.baseAddress, key.count,
                        ivUnsafeRawBufferPointer.baseAddress,
                        dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                        dataOut, dataOutSize, &dataOutMoved)
                    guard status == kCCSuccess else { return nil }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }
}

public extension CGFloat {
    /**
     Converts pixels to points based on the screen scale. For example, if you
     call CGFloat(1).pixelsToPoints() on an @2x device, this method will return
     0.5.
     
     - parameter pixels: to be converted into points
     
     - returns: a points representation of the pixels
     */
    func pixelsToPoints() -> CGFloat {
        return self / UIScreen.main.scale
    }
    
    /**
     Returns the number of points needed to make a 1 pixel line, based on the
     scale of the device's screen.
     
     - returns: the number of points needed to make a 1 pixel line
     */
    static func onePixelInPoints() -> CGFloat {
        return CGFloat(1).pixelsToPoints()
    }
}

extension Date {
    func addMinutes(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func dateInTimeZone(timeZoneIdentifier: String, dateFormat: String) -> String  {
     let dtf = DateFormatter()
     dtf.timeZone = TimeZone(identifier: timeZoneIdentifier)
     dtf.dateFormat = dateFormat

     return dtf.string(from: self)
     }
}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

extension Date {
    // you can create a read-only computed property to return just the nanoseconds from your date time
    //var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
}

extension Date {
  static func getStringFromDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
    let dateString = dateFormatter.string(from: date)
    return dateString
  }
  static func getDateFromString(dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime,
                               .withDashSeparatorInDate,
                               .withFullDate,
                               .withFractionalSeconds,
                               .withColonSeparatorInTimeZone]
    guard let date = formatter.date(from: dateString) else {
      return nil
    }
    return date
  }
  // get an ISO timestamp
  static func getISOTimestamp() -> String {
    let isoDateFormatter = ISO8601DateFormatter()
    let timestamp = isoDateFormatter.string(from: Date())
    return timestamp
  }
}

extension String {
  // create a formatted date from ISO
  // e.g "MMM d, yyyy hh:mm a"
  // e.g usage addedAt.formattedDate("MMM d, yyyy")
  public func formatISODateString(dateFormat: String) -> String {
    var formatDate = self
    let isoDateFormatter = ISO8601DateFormatter()
    if let date = isoDateFormatter.date(from: self) {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = dateFormat
      formatDate = dateFormatter.string(from: date)
    }
    return formatDate
  }
  
  // e.g usage createdAt.date()
  public func date() -> Date {
    var date = Date()
    let isoDateFormatter = ISO8601DateFormatter()
    if let isoDate = isoDateFormatter.date(from: self) {
      date = isoDate
    }
    return date
  }
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

extension TimeInterval{

func stringFromTimeInterval() -> String {

    let time = NSInteger(self)

    let seconds = time % 60
    let minutes = (time / 60) % 60
    let hours = (time / 3600)

    var formatString = ""
    if hours == 0 {
        if(minutes < 10) {
            formatString = "%2d:%0.2d"
        }else {
            formatString = "%0.2d:%0.2d"
        }
        return String(format: formatString,minutes,seconds)
    }else {
        formatString = "%2d:%0.2d:%0.2d"
        return String(format: formatString,hours,minutes,seconds)
    }
}
}

extension String {
    func stringBefore(_ delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            return String(prefix(upTo: index))
        } else {
            return ""
        }
    }
    
    func stringAfter(_ delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            return String(suffix(from: index).dropFirst())
        } else {
            return ""
        }
    }
}
