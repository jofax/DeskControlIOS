//
//  CustomNavBar.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
class NavBar: UINavigationBar {

    override init(frame: CGRect) {
        super.init(frame: frame)

        if #available(iOS 11, *) {
            translatesAutoresizingMaskIntoConstraints = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 70.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard #available(iOS 11, *) else {
            return
        }

        frame = CGRect(x: frame.origin.x, y:  0, width: frame.size.width, height: 90)

        if let parent = superview {
            parent.layoutIfNeeded()

            for view in parent.subviews {
                let stringFromClass = NSStringFromClass(view.classForCoder)
                if stringFromClass.contains("NavigationTransition") {
                    view.frame = CGRect(x: view.frame.origin.x, y: frame.size.height - 64, width: view.frame.size.width, height: parent.bounds.size.height - frame.size.height + 4)
                }
            }
        }

        for subview in self.subviews {
            var stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 90)
                subview.backgroundColor = .yellow
            }

            stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarContent") {
                subview.frame = CGRect(x: subview.frame.origin.x, y: 40, width: subview.frame.width, height: subview.frame.height)

            }
        }
    }
}
