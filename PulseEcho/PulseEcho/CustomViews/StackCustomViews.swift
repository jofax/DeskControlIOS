//
//  StackCustomViews.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
class StackCustomViews: UIView {

    var height: CGFloat = 1.0
    var width: CGFloat = 1.0

    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }

    override func prepareForInterfaceBuilder() {
         invalidateIntrinsicContentSize()
    }
}
