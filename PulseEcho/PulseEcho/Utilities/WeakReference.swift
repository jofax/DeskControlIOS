//
//  WeakReference.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-21.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
class WeakReference<T: AnyObject> {
    
    weak var value: T?

    init(value: T) {
        self.value = value
    }
    
    func release() {
        value = nil
    }
}
