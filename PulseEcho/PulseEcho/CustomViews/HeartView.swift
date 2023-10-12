//
//  HeartView.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-13.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

public protocol ShapeDesignable {
    
    var strokeColor: UIColor { get set }
    
    var scaling: Double { get set }
    
    var strokeWidth: CGFloat { get set }
    
}


@IBDesignable open class ShapeView: UIView, ShapeDesignable {
    
    @IBInspectable open var strokeColor: UIColor = UIColor.black
    @IBInspectable open var scaling: Double = 1.0
    @IBInspectable open var strokeWidth: CGFloat = 1.0

    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        config()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        config()
    }
    
    open func config() {
        //To be subclassed
    }
    
    
}

public protocol HeartDesignable: ShapeDesignable {
    
    var fillColor: UIColor { get set }
    
    var shapeMask: Bool { get set }
}

public extension HeartDesignable where Self: UIView {
    
    func drawHeart() {
        
        
        layer.sublayers?
            .filter  { $0.name == "Heart" }
            .forEach { $0.removeFromSuperlayer() }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.name = "Heart"
        shapeLayer.path = UIBezierPath().getHearts(frame, scale: scaling).cgPath
        
        if shapeMask {
            shapeLayer.fillRule = CAShapeLayerFillRule.nonZero
            self.layer.mask = shapeLayer
        } else  {
            shapeLayer.lineWidth = strokeWidth
            shapeLayer.strokeColor = strokeColor.cgColor
            shapeLayer.fillColor = fillColor.cgColor
            self.layer.addSublayer(shapeLayer)
        }
    }
}

public extension UIBezierPath  {
    
    func getHearts(_ originalRect: CGRect, scale: Double) -> UIBezierPath {
        
        
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        
        self.move(to: CGPoint(x: originalRect.size.width/2, y: scaledRect.origin.y + scaledRect.size.height))
        
        
        self.addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/4)),
            controlPoint1:CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
            controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/2)) )
        
        self.addArc(withCenter: CGPoint( x: scaledRect.origin.x + (scaledRect.size.width/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
            radius: (scaledRect.size.width/4),
            startAngle: CGFloat(Double.pi),
            endAngle: 0,
            clockwise: true)
        
        self.addArc(withCenter: CGPoint( x: scaledRect.origin.x + (scaledRect.size.width * 3/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
            radius: (scaledRect.size.width/4),
            startAngle: CGFloat(Double.pi),
            endAngle: 0,
            clockwise: true)
        
        self.addCurve(to: CGPoint(x: originalRect.size.width/2, y: scaledRect.origin.y + scaledRect.size.height),
            controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
            controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )

        self.close()
        
        return self
    }
    

    func maximumSquareRect(_ rect: CGRect) -> CGRect {
        let side = min(rect.size.width, rect.size.height)
        return CGRect(x: rect.size.width/2 - side/2, y: rect.size.height/2 - side/2, width: side, height: side)
    }
}


@IBDesignable open class HeartView: ShapeView, HeartDesignable {
    
    @IBInspectable open var fillColor: UIColor = UIColor.clear
    @IBInspectable open var shapeMask: Bool = false
    
    override open func config() {
        drawHeart()
    }
    
}
