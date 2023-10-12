//
//  ProgressCircleLayer.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-17.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Device

class ProgressCircleLayer: UIView {
    private var lineWidth:CGFloat = ((Device.size() == .screen4_7Inch) ? 8 : 10)
    private var radius: CGFloat {
        get{
            return (min(self.frame.width, self.frame.height) - lineWidth)/2
        }
    }
    public var duration: Double = 0.5
    public var progressBackgoundColor = UIColor.lightGray
    private let overAllMaskLayer = CAShapeLayer()
    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    
    private var layoutDone = false
        override func layoutSublayers(of layer: CALayer) {
            if !layoutDone {
                
                #if targetEnvironment(simulator)
                    self.clearAllLayers()
                    drawMaskForgroundLayer()
                    layoutDone = true
                    print("Running on Simulator")
                #endif
            }
        }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    func clearAllLayers() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    func drawMaskForgroundLayer() {
        
            let startAngle = (3 * CGFloat.pi) / 2
            let endAngle = startAngle + 2 * CGFloat.pi
            
            let path = UIBezierPath(arcCenter: self.pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            self.overAllMaskLayer.lineCap = CAShapeLayerLineCap.butt
            self.overAllMaskLayer.path = path.cgPath
            self.overAllMaskLayer.lineWidth = self.lineWidth
            self.overAllMaskLayer.fillColor = UIColor.clear.cgColor
            self.overAllMaskLayer.strokeColor = UIColor(red: CGFloat(103/255.0), green: CGFloat(104/255.0), blue: CGFloat(105/255.0), alpha: 0.5).cgColor
            self.overAllMaskLayer.strokeEnd = 0
            
            self.layer.addSublayer(self.overAllMaskLayer)
        
    }
    
    public func setProgressMaskLayer(to progressConstant: Double, withAnimation: Bool) {
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        overAllMaskLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEndMaskLayer")
            animation.fromValue = 0
            animation.toValue = progress
            animation.duration = duration
            overAllMaskLayer.add(animation, forKey: "foregroundAnimationMaskLayer")
        }
        
    }

}
