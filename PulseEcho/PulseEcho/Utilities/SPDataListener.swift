//
//  SPDataListener.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-21.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
@objc protocol SPDataListener: AnyObject {
    
    func sittingHeightAdjusted(adjusted: Bool)
    func standingHeightAdjusted(adjusted: Bool)
  
}
