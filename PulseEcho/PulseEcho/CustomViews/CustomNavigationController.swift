//
//  CustomNavigationController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    init() {
        super.init(navigationBarClass: NavBar.self, toolbarClass: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: NavBar.self, toolbarClass: nil)

        self.viewControllers = [rootViewController]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
