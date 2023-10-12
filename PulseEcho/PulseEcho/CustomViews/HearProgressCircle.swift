//
//  HearProgressCircle.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-20.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Device

class HearProgressCircle: UIView {
    
    //CLASS VARIABLES
    
    //DEMO
    
    private let upperRightForegroundLayer = CAShapeLayer()
    private let upperRightBackgroundLayer = CAShapeLayer()
    
    private let lowerRightForegroundLayer = CAShapeLayer()
    private let lowerRightBackgroundLayer = CAShapeLayer()
    
    private let upperLeftForegroundLayer = CAShapeLayer()
    private let upperLeftBackgroundLayer = CAShapeLayer()
    
    private let lowerLeftForegroundLayer = CAShapeLayer()
    private let lowerLeftBackgroundLayer = CAShapeLayer()

    public var oneProgressForegroundColor = UIColor.red
    public var twoProgressForegroundColor = UIColor.blue
    public var threeProgressForegroundColor = UIColor.green
    public var fourthProgressForegroundColor = UIColor.yellow
    
    
    public var lineWidth:CGFloat = ((Device.size() == .screen3_5Inch) ? 5 : 10) {
        didSet{
            lowerRightForegroundLayer.lineWidth = lineWidth
            lowerRightBackgroundLayer.lineWidth = lineWidth
            upperRightForegroundLayer.lineWidth = lineWidth
            upperRightBackgroundLayer.lineWidth = lineWidth
            upperLeftForegroundLayer.lineWidth = lineWidth
            upperLeftBackgroundLayer.lineWidth = lineWidth
            
            lowerLeftForegroundLayer.lineWidth = lineWidth
            lowerLeftBackgroundLayer.lineWidth = lineWidth
        }
    }

     private let sliceAngle = (2 * CGFloat.pi) / 4
     private let oneStartAngle  = CGFloat.pi / 2 //CGFloat.pi * 2
     private let oneEndAngle = CGFloat.pi * 2 //CGFloat.pi / 2
     private let twoStartAngle = CGFloat.pi * 0.0 / 2
     private let twoEndAngle = (3 * CGFloat.pi) / 2
     private let threeStartAngle  = (3 * CGFloat.pi) / 2
     private let threeEndAngle = CGFloat.pi
     private let fourStartAngle = CGFloat.pi
     private let fourEndAngle = CGFloat.pi / 2
     private func setForegroundLayerColorForUpperRight(){
        self.lowerRightForegroundLayer.strokeColor = oneProgressForegroundColor.cgColor
     }
     
     private func makeBar(){
         self.layer.sublayers = nil
         drawBackgroundLayerUpperRight()
         //drawForegroundLayerUpperRight()
         drawBackgroundLayerLowerRight()
         //drawForegroundLayerLowerRight()
         drawBackgroundLayerLowerLeft()
         //drawForegroundLayerLowerLeft()
         drawBackgroundLayerUpperLeft()
         //drawForegroundLayerUpperLeft()
         
         drawMaskForgroundLayer()
         
     }
     
    

    private func drawBackgroundLayerUpperRight(){
        //let twoStartAngle1 = CGFloat.pi * 0.0 / 2
        //let twoEndAngle1 = (3 * CGFloat.pi) / 2
        
        //print("lower right radius",self.radius)
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: twoStartAngle, endAngle: twoEndAngle, clockwise: false)
        self.upperRightBackgroundLayer.path = path.cgPath
        self.upperRightBackgroundLayer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
        self.upperRightBackgroundLayer.lineWidth = lineWidth
        self.upperRightBackgroundLayer.lineCap = CAShapeLayerLineCap.butt
        self.upperRightBackgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(upperRightBackgroundLayer)
        
    }
    
    private func drawForegroundLayerUpperRight(){
        let startAngle = (3 * CGFloat.pi) / 2
        let endAngle =  CGFloat.pi
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        upperRightForegroundLayer.lineCap = CAShapeLayerLineCap.butt
        upperRightForegroundLayer.path = path.cgPath
        upperRightForegroundLayer.lineWidth = lineWidth
        upperRightForegroundLayer.fillColor = UIColor.clear.cgColor
        upperRightForegroundLayer.strokeColor = twoProgressForegroundColor.cgColor
        upperRightForegroundLayer.strokeEnd = 0
        
        self.layer.addSublayer(upperRightForegroundLayer)
        
    }
    
    //LOWER RIGHT
    private func drawBackgroundLayerLowerRight(){
        
        //let oneStartAngle1  = CGFloat.pi * 2
        //let oneEndAngle1 = CGFloat.pi / 2
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: oneStartAngle , endAngle: oneEndAngle, clockwise: false)
        self.lowerRightBackgroundLayer.path = path.cgPath
        self.lowerRightBackgroundLayer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
        self.lowerRightBackgroundLayer.lineWidth = lineWidth
        self.lowerRightBackgroundLayer.lineCap = CAShapeLayerLineCap.butt
        self.lowerRightBackgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(lowerRightBackgroundLayer)
    }

    private func drawForegroundLayerLowerRight(){
        let startAngle = CGFloat.pi * 0.0 / 2
        let endAngle = (3 * CGFloat.pi) / 2
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        lowerRightForegroundLayer.lineCap = CAShapeLayerLineCap.butt
        lowerRightForegroundLayer.path = path.cgPath
        lowerRightForegroundLayer.lineWidth = lineWidth
        lowerRightForegroundLayer.fillColor = UIColor.clear.cgColor
        lowerRightForegroundLayer.strokeColor = oneProgressForegroundColor.cgColor
        lowerRightForegroundLayer.strokeEnd = 0
        self.layer.addSublayer(lowerRightForegroundLayer)

    }
    
    //LOWER LEFT
    private func drawBackgroundLayerLowerLeft(){
        
        //let fourStartAngle1 = CGFloat.pi
        //let fourEndAngle1 = CGFloat.pi / 2
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: fourStartAngle, endAngle: fourEndAngle, clockwise: false)
        self.lowerLeftBackgroundLayer.path = path.cgPath
        self.lowerLeftBackgroundLayer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
        self.lowerLeftBackgroundLayer.lineWidth = lineWidth
        self.lowerLeftBackgroundLayer.lineCap = CAShapeLayerLineCap.butt
        self.lowerLeftBackgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(lowerLeftBackgroundLayer)

    }
    
    private func drawForegroundLayerLowerLeft(){
        let startAngle = CGFloat.pi / 2
        let endAngle = CGFloat.pi
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        lowerLeftForegroundLayer.lineCap = CAShapeLayerLineCap.butt
        lowerLeftForegroundLayer.path = path.cgPath
        lowerLeftForegroundLayer.lineWidth = lineWidth
        lowerLeftForegroundLayer.fillColor = UIColor.clear.cgColor
        lowerLeftForegroundLayer.strokeColor = threeProgressForegroundColor.cgColor
        lowerLeftForegroundLayer.strokeEnd = 0
        
        self.layer.addSublayer(lowerLeftForegroundLayer)
    }
    
    //UPPER LEFT
    private func drawBackgroundLayerUpperLeft(){
           
           //let threeStartAngle1  = (3 * CGFloat.pi) / 2
           //let threeEndAngle1 = CGFloat.pi
           
           let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: threeStartAngle, endAngle: threeEndAngle, clockwise: false)
           self.upperLeftBackgroundLayer.path = path.cgPath
           self.upperLeftBackgroundLayer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
           self.upperLeftBackgroundLayer.lineWidth = lineWidth
           self.upperLeftBackgroundLayer.lineCap = CAShapeLayerLineCap.butt
           self.upperLeftBackgroundLayer.fillColor = UIColor.clear.cgColor
           self.layer.addSublayer(upperLeftBackgroundLayer)
           
       }
       
       private func drawForegroundLayerUpperLeft(){
           let startAngle = CGFloat.pi
           let endAngle = (3 * CGFloat.pi) / 2
           
           let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
           
           upperLeftForegroundLayer.lineCap = CAShapeLayerLineCap.butt
           upperLeftForegroundLayer.path = path.cgPath
           upperLeftForegroundLayer.lineWidth = lineWidth
           upperLeftForegroundLayer.fillColor = UIColor.clear.cgColor
           upperLeftForegroundLayer.strokeColor = fourthProgressForegroundColor.cgColor
           upperLeftForegroundLayer.strokeEnd = 0
           
           self.layer.addSublayer(upperLeftForegroundLayer)
           
       }

    public func setProgressUpperRight(to progressConstant: Double, withAnimation: Bool) {
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        upperRightForegroundLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEndUpperRight")
            animation.fromValue = 0
            animation.toValue = progress
            animation.duration = duration
            upperRightForegroundLayer.add(animation, forKey: "foregroundAnimationUpperRight")
        }
        
    }
    
    public func setProgressLowerRight(to progressConstant: Double, withAnimation: Bool) {
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        lowerRightForegroundLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEndLowerRight")
            animation.fromValue = 0
            animation.toValue = progress
            animation.duration = duration
            lowerRightForegroundLayer.add(animation, forKey: "foregroundAnimationLowerRight")
        }
        
    }
    
    public func setProgressLowerLeft(to progressConstant: Double, withAnimation: Bool) {
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        lowerLeftForegroundLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEndLowerLeft")
            animation.fromValue = 0
            animation.toValue = progress
            animation.duration = duration
            lowerLeftForegroundLayer.add(animation, forKey: "foregroundAnimationLowerLeft")
        }
        
    }
    
    public func setProgressUpperLeft(to progressConstant: Double, withAnimation: Bool) {
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        upperLeftForegroundLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEndUpperLeft")
            animation.fromValue = 0
            animation.toValue = progress
            animation.duration = duration
            upperLeftForegroundLayer.add(animation, forKey: "foregroundAnimationUpperLeft")
        }
        
    }

    func setupView() {
        makeBar()
    }


    
    /* WITH BLUETOOTH PARSING **/
    private let overAllMaskLayer = CAShapeLayer()
    
    private var radius: CGFloat {
        get{
            return (min(self.frame.width, self.frame.height) - lineWidth)/2
        }
    }
    
    public var duration: Double = 0.5
    
    public var progressBackgoundColor = UIColor.lightGray
    
    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    
    
    private var verticalProfileObject: SPVerticalProfile?
    private var coreOneObject: SPCoreObject?
    
    func createPeriodLayersWithMovements(periods: [[String:Any]]) {
        var _lineWidth: CGFloat = 0.0
        
        switch deviceSize {
            case .i4_7Inch:
                _lineWidth = 8
            case .i4Inch:
                _lineWidth = 6
            case .i6_1Inch:
                _lineWidth = 13
            default:
                _lineWidth =  10
        }
        
        self.lineWidth = _lineWidth
        
        for (_, item) in periods.enumerated() {
            //print("index : ", index)
            let _key = item["key"] as? String
            let _start = item["start"] as? Int ?? 0
            let _end = item["end"] as? Int ?? 0
            
            let startAngle = Utilities.instance.getAngle(duration: _start / 60)
            let endAngle = Utilities.instance.getAngle(duration: _end / 60)
            
            let _layer = CAShapeLayer()
            let path = UIBezierPath(arcCenter: self.pathCenter,
                                    radius: self.radius,
                                    startAngle: startAngle ,
                                    endAngle:endAngle,
                                    clockwise: true)
            _layer.path = path.cgPath
            if _key == MovementType.DOWN.movementRawString {
                _layer.strokeColor = UIColor(hexstr: Constants.smartpods_bluish_white).cgColor
            } else {
                _layer.strokeColor = UIColor(hexString: Constants.smartpods_blue).cgColor
            }
            _layer.lineWidth = _lineWidth //self.lineWidth
            _layer.lineCap = CAShapeLayerLineCap.butt
            _layer.fillColor = UIColor.clear.cgColor
        
            self.layer.addSublayer(_layer)
        }

        
        drawMaskForgroundLayer()
    }
    
    func initWithProfile(movements: SPVerticalProfile) {
        self.verticalProfileObject = movements
        

        #if targetEnvironment(simulator)
            self.createPeriodLayersWithMovements(periods: [["end": 900, "start": 0, "key": "7", "value": 3], ["value": 900, "start": 900, "key": "4", "end": 1800], ["end": 2700, "value": 1800, "start": 1800, "key": "7"], ["value": 2700, "start": 2700, "key": "4", "end": 0]])
        //self.createPeriodLayersWithMovements(periods: [["end": 2700, "start": 0, "key": "7", "value": 3],  ["value": 2700, "start": 2700, "key": "7", "end": 0]])
            return
        #endif
        
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            self.createPeriodLayersWithMovements(periods: [["end": 2700, "start": 0, "key": "7", "value": 3],  ["value": 2700, "start": 2700, "key": "7", "end": 0]])
            return
        }
        
        print("initWithProfile movements: ", movements.movements)
        self.createPeriodLayersWithMovements(periods: movements.movements)
    }
    
    func clearAllLayers() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    private func drawMaskForgroundLayer() {
        
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
    
    //Layout Sublayers
    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            #if targetEnvironment(simulator)
                self.clearAllLayers()
                /*initWithMovement(movements: self.currentMovements,
                                 core: self.currentCoreObject ?? CoreObject(raw: "", strings: []))*/
            
                //initWithProfile(movements: self.verticalProfileObject ?? VerticalProfile(data: [UInt8](), rawString: "", notify: false))
                layoutDone = true
            #endif

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupView()
        if self.verticalProfileObject != nil && self.coreOneObject != nil {
//            initWithMovement(movements: self.currentMovements,
//                             core: self.currentCoreObject ?? CoreObject(strings: []))
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear

    }

}
