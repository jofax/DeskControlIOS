//
//  HeartProgressBackgroundLayer.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Device
import NVActivityIndicatorView

class HeartProgressBackgroundLayer: UIView {
    
    public var overAllMaskLayer = CAShapeLayer()
    private var lineWidth:CGFloat = 3.0
    private var radius: CGFloat {
        get{
            return (min(self.frame.width, self.frame.height) + lineWidth)/2
        }
    }
    var activityIndicator: NVActivityIndicatorView?
    public var progressBackgoundColor = UIColor.lightGray

    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    
    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            createBackgroundLayer()
            layoutDone = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    
    
    func createBackgroundLayer() {
        
        self.activityIndicator = NVActivityIndicatorView(frame: self.frame, type: .ballScaleMultiple, color: UIColor(hexstr: Constants.smartpods_blue), padding: 0)
        //activityIndicator?.backgroundColor = .red
        //self.heartProgressBg.addSubview(activityIndicator ?? UIView())
        overAllMaskLayer.addSublayer(self.activityIndicator?.layer ?? CALayer())
        //self.activityIndicator?.startAnimating()
        
        
        print("createBackgroundLayer")
        
        let startAngle = (3 * CGFloat.pi) / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        overAllMaskLayer.lineCap = CAShapeLayerLineCap.butt
        overAllMaskLayer.path = path.cgPath
        overAllMaskLayer.lineWidth = lineWidth
        overAllMaskLayer.fillColor = UIColor(red: CGFloat(30/255.0), green: CGFloat(176/255.0), blue: CGFloat(255/255.0), alpha: 0.2).cgColor
        //overAllMaskLayer.strokeColor = UIColor(red: CGFloat(103/255.0), green: CGFloat(104/255.0), blue: CGFloat(105/255.0), alpha: 0.5).cgColor
        overAllMaskLayer.strokeEnd = 5

        self.layer.addSublayer(overAllMaskLayer)
    }
    
    func animateActivityLoader(animate: Bool) {
        if animate {
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.stopAnimating()
        }
        
//        if let peripheral = SPBluetoothManager.shared.state.peripheral {
//            if peripheral.state == .connected || peripheral.state == .disconnected  || peripheral.state == .disconnecting{
//                self.activityIndicator?.stopAnimating()
//            }
//
//            if peripheral.state == .connecting {
//                self.activityIndicator?.startAnimating()
//            }
//
//        }
        
//        if (SPBluetoothManager.shared.pulse == .Disconnected || SPBluetoothManager.shared.pulse == .Connected) {
//            self.activityIndicator?.stopAnimating()
//        }
//        
//        if SPBluetoothManager.shared.pulse == .Connecting {
//            self.activityIndicator?.startAnimating()
//        }
        
    }

 }
