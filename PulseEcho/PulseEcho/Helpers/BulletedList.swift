//
//  BulletedList.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-19.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

class BulletedList {
    static func createBulletedList(fromStringArray strings: [String], font: UIFont? = nil) -> NSAttributedString {

        let fullAttributedString = NSMutableAttributedString()
        let attributesDictionary: [NSAttributedString.Key: Any]

        if font != nil {
            attributesDictionary = [NSAttributedString.Key.font: font!]
        } else {
            attributesDictionary = [NSAttributedString.Key: Any]()
        }

        for index in 0..<strings.count {
            let bulletPoint: String = "\u{2022}"
            var formattedString: String = "\(bulletPoint) \(strings[index])"

            if index < strings.count - 1 {
                formattedString = "\(formattedString)\n"
            }

            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString, attributes: attributesDictionary)
            let paragraphStyle = BulletedList.createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            //attributedString.addAttributes([NSAttributedString.Key.baselineOffset:offset], range: n1)
            fullAttributedString.append(attributedString)
       }

        return fullAttributedString
    }

    private static func createParagraphAttribute() -> NSParagraphStyle {
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15, options: NSDictionary() as! [NSTextTab.OptionKey : Any])]
        paragraphStyle.defaultTabInterval = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 11
        return paragraphStyle
    }
}
