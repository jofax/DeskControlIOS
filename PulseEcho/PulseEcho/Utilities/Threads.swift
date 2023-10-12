//
//  Threads.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
class Threads {

  static let concurrentName =  String(format:"%@ConcurrentQueue",Bundle.appName())
  static let queueName = String(format:"%@SerialQueue",Bundle.appName())
    
  static let concurrentQueue = DispatchQueue(label: concurrentName, attributes: .concurrent)
  static let serialQueue = DispatchQueue(label: queueName)

  // Main Queue
  class func performTaskInMainQueue(task: @escaping ()->()) {
    DispatchQueue.main.async {
      task()
    }
  }

  // Background Queue
  class func performTaskInBackground(task:@escaping () throws -> ()) {
    DispatchQueue.global(qos: .background).async {
      do {
        try task()
      } catch let error as NSError {
        print("error in background thread:\(error.localizedDescription)")
      }
    }
  }

  // Concurrent Queue
  class func perfromTaskInConcurrentQueue(task:@escaping () throws -> ()) {
    concurrentQueue.async {
      do {
        try task()
      } catch let error as NSError {
        print("error in Concurrent Queue:\(error.localizedDescription)")
      }
    }
  }

  // Serial Queue
  class func perfromTaskInSerialQueue(task:@escaping () throws -> ()) {
    serialQueue.async {
      do {
        try task()
      } catch let error as NSError {
        print("error in Serial Queue:\(error.localizedDescription)")
      }
    }
  }

  // Perform task afterDelay
  class func performTaskAfterDealy(_ timeInteval: TimeInterval, _ task:@escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: (.now() + timeInteval)) {
      task()
    }
  }
}
