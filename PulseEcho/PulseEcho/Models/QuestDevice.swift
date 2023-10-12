//
//  QuestDevice.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-12.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import CoreBluetooth

struct QuestDevice {
    let deviceName: String
    let periPheral: CBPeripheral
    let identifier: String
    var isConnecting: Bool
}
