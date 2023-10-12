//
//  TemperatureIndicator.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

public enum Level: Int {
    case noValue
    case veryLow
    case low
    case good
    case veryGood
    case excellent
}

public class TemperatureIndicator: UIView {
    
    // MARK: - Level
    private var _level = Level.noValue
    
    public var level: Level {
        get {
            return _level
        }
        set(newValue) {
            _level = newValue
            setNeedsDisplay()
        }
    }
    
    // MARK: - Customization
    
    public var edgeInsets = UIEdgeInsets(top: 3, left: 2, bottom: 3, right: 2)
    public var spacing: CGFloat = 4
    public var color = UIColor(hexString: Constants.smartpods_gray)
    
    // MARK: - Constants
    
    private let indicatorsCount: Int = 3
    
    // MARK: - Drawing
    
    override public func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        ctx.saveGState()
        
        let levelValue = level.rawValue        
        let barsCount = CGFloat(indicatorsCount)
        //let barWidth = (rect.width - edgeInsets.right - edgeInsets.left - ((barsCount - 1) * spacing)) / barsCount
        let barWidth = CGFloat(5)
        let barHeight = rect.height - edgeInsets.top - edgeInsets.bottom
        for index in 0...indicatorsCount - 1 {

            let i = CGFloat(index)
            let width = barWidth
            let height = barHeight - (((barHeight * 0.5) / barsCount) * (barsCount - i))
            let x: CGFloat = edgeInsets.left + i * barWidth + i * spacing
            let y: CGFloat = barHeight - height
            let cornerRadius: CGFloat = barWidth * 0.25
            let barRect = CGRect(x: x, y: y, width: width, height: height)
            let clipPath: CGPath = UIBezierPath(roundedRect: barRect, cornerRadius: cornerRadius).cgPath
        

            ctx.addPath(clipPath)
            ctx.setFillColor(color.cgColor)
            ctx.setStrokeColor(color.cgColor)

            if index + 1 > levelValue {
                ctx.strokePath()
            }
            else {
                ctx.fillPath()
            }
        }
        
        ctx.restoreGState()
    }
    
}
