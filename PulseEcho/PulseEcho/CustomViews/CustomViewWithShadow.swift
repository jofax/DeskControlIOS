//
//  CustomViewWithShadow.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-20.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

final class CustomViewWithShadow: UIView {
    private var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 33).cgPath
            if self.backgroundColor != nil {
                shadowLayer.fillColor = self.backgroundColor?.cgColor
            }
            else{
                shadowLayer.fillColor = UIColor.white.cgColor
            }
            shadowLayer.shadowColor = UIColor.gray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            shadowLayer.shadowOpacity = 0.4
            shadowLayer.shadowRadius = 2

            layer.insertSublayer(shadowLayer, at: 0)

        }

    }
}

