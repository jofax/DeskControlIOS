//
//  SurveyOptionsButton.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-24.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class SurveyOptionsButton: UIButton {

     private var shadowLayer: CAShapeLayer!
     var selectedState: Bool = false

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
               
               if !self.isSelected {
                   layer.insertSublayer(shadowLayer, at: 0)
               }

           }

       }

}
