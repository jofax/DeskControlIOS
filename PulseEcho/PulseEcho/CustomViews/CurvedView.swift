//
//  CurvedView.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class CurvedView: UIView {

   override func draw(_ rect: CGRect) {
        let color = UIColor.white//UIColor(rgb: 0x285387)
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x:0, y:0))
        myBezier.addLine(to: CGPoint(x:rect.width, y:0))
        myBezier.addLine(to: CGPoint(x:rect.width, y:rect.height))
        myBezier.addQuadCurve(to: CGPoint(x:0, y:rect.height), controlPoint: CGPoint(x:rect.width/2, y:rect.height-rect.height*1.5))
        myBezier.addLine(to: CGPoint(x:0, y:0))
    
        color.setFill()
        myBezier.fill()
        myBezier.close()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear

    }
}

//@IBDesignable
//class CurvedView: UIView {
//
//    private func pathCurvedForView(givenView: UIView, curvedPercent:CGFloat) ->UIBezierPath
//    {
//        let arrowPath = UIBezierPath()
//        arrowPath.move(to: CGPoint(x:0, y:0))
//        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:0))
//        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:givenView.bounds.size.height))
//        arrowPath.addQuadCurve(to: CGPoint(x:0, y:givenView.bounds.size.height), controlPoint: CGPoint(x:givenView.bounds.size.width/2, y:givenView.bounds.size.height-givenView.bounds.size.height*curvedPercent))
//        arrowPath.addLine(to: CGPoint(x:0, y:0))
//        arrowPath.close()
//
//        return arrowPath
//    }
//
////    func pathCurvedForView(givenView: UIView, curvedPercent:CGFloat) ->UIBezierPath
////    {
////        let arrowPath = UIBezierPath()
////        arrowPath.move(to: CGPoint(x:0, y:0))
////        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:0))
////        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:givenView.bounds.size.height - (givenView.bounds.size.height*curvedPercent)))
////        arrowPath.addQuadCurve(to: CGPoint(x:0, y:givenView.bounds.size.height - (givenView.bounds.size.height*curvedPercent)), controlPoint: CGPoint(x:givenView.bounds.size.width/2, y:givenView.bounds.size.height))
////        arrowPath.addLine(to: CGPoint(x:0, y:0))
////        arrowPath.close()
////
////        return arrowPath
////    }
//
//    @IBInspectable var curvedPercent : CGFloat = 0{
//        didSet{
//            guard curvedPercent <= 1 && curvedPercent >= 0 else{
//                return
//            }
//
//            let shapeLayer = CAShapeLayer(layer: self.layer)
//            shapeLayer.path = self.pathCurvedForView(givenView: self,curvedPercent: curvedPercent).cgPath
//            shapeLayer.frame = self.bounds
//            shapeLayer.masksToBounds = false
//            self.layer.mask = shapeLayer
//        }
//    }
//
//}
