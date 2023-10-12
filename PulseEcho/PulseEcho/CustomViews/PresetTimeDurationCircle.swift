//
//  PresetTimeDurationCircle.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Device

class PresetTimeDurationCircle: UIView {
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
    
    private var periods: [[String: Any]] =  [[String: Any]]()
    private var progressTitle: String = ""
    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            //layoutDone = true
            
            #if targetEnvironment(simulator)
                self.clearAllLayers()
                self.createPresetTimeDurationCircle(periods: self.periods, title: self.progressTitle)
                //drawMaskForgroundLayer()
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
    
    
    func createPresetTimeDurationCircle(periods:[[String: Any]], title: String) {
        self.periods = periods
        self.progressTitle = title
        
        for (_, item) in periods.enumerated() {
            let _key = item["key"] as? String
            let startAngle = item["start"] as? CGFloat ?? 0.0
            let endAngle = item["end"] as? CGFloat ?? 0.0
            
            let _layer = CAShapeLayer()
            let path = UIBezierPath(arcCenter: pathCenter,
                                    radius: radius,
                                    startAngle: startAngle ,
                                    endAngle:endAngle,
                                    clockwise: true)
            _layer.path = path.cgPath
            if _key == MovementType.DOWN.movementRawString {
                _layer.strokeColor = UIColor(hexstr: Constants.smartpods_bluish_white).cgColor
            } else {
                _layer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
            }
            _layer.lineWidth = lineWidth
            _layer.lineCap = CAShapeLayerLineCap.butt
            _layer.fillColor = UIColor.clear.cgColor
        
            self.layer.addSublayer(_layer)
        }
        
        //drawMaskForgroundLayer()
        
        let frame = CGRect(x: (self.frame.size.width / 2) - 100, y: (self.frame.size.height / 2) - 25, width: 200,height: 50)
        
        let durationLbl = UILabel()
         durationLbl.backgroundColor = .clear
         durationLbl.font = UIFont(name: Constants.smartpods_font_gotham, size: 17.0)
         durationLbl.textColor = UIColor(hexString: Constants.smartpods_gray)
         let _string = String(format: "%@ Min/Hr", title)
         let _title = title as NSString
         
         let font = UIFont(name: Constants.smartpods_font_gotham, size: 17)!
         let boldFont = UIFont(name: Constants.smartpods_font_ddin, size: 30)!
         durationLbl.attributedText = _string.withBoldText(
             boldPartsOfString: [_title], font: font, boldFont: boldFont)
        
         durationLbl.textAlignment = .center
        
        //Min/Hr
        
        let standingLbl = UILabel()
        standingLbl.backgroundColor = .clear
        standingLbl.font = UIFont(name: Constants.smartpods_font_gotham, size: 15.0)
        standingLbl.textColor = UIColor(hexString: Constants.smartpods_gray)
        standingLbl.text = "Standing time"
        standingLbl.textAlignment = .center
            
        let stackView = UIStackView(frame: frame)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        stackView.addArrangedSubview(durationLbl)
        stackView.addArrangedSubview(standingLbl)
        
        standingLbl.adjustContentFontSize()
        durationLbl.adjustContentFontSize()
        
        self.addSubview(stackView)
        
        

    }
    
    func createCustomTimeDuration(periods:[[String: Any]], clockwise: Bool) {
        for (_, item) in periods.enumerated() {
            let _key = item["key"] as? String
            let startAngle = item["start"] as? CGFloat ?? 0.0
            let endAngle = item["end"] as? CGFloat ?? 0.0
            
            let _layer = CAShapeLayer()
            let path = UIBezierPath(arcCenter: pathCenter,
                                    radius: radius,
                                    startAngle: startAngle ,
                                    endAngle:endAngle,
                                    clockwise: clockwise)
            _layer.path = path.cgPath
            if _key == MovementType.DOWN.movementRawString {
                _layer.strokeColor =  UIColor(hexstr: Constants.smartpods_bluish_white).cgColor
            } else {
                _layer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
            }
            _layer.lineWidth = lineWidth
            _layer.lineCap = CAShapeLayerLineCap.butt
            _layer.fillColor = UIColor.clear.cgColor
        
            self.layer.addSublayer(_layer)
        }
        
        //drawMaskForgroundLayer()
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
