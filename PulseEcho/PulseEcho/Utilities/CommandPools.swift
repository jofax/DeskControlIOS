//
//  CommandPools.swift
//  PulseEcho
//
//  Created by Joseph on 2020-05-15.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

class CommandPools<T> {
    private let lockQueue = DispatchQueue(label: "SP.CommandPool.lock.queue")
    private let semaphore: DispatchSemaphore
    private var items = [T]()

    init(_ items: [T]) {
        self.semaphore = DispatchSemaphore(value: items.count)
        self.items.reserveCapacity(items.count)
        self.items.append(contentsOf: items)
    }

    func acquire() -> T? {
        if self.semaphore.wait(timeout: .distantFuture) == .success, !self.items.isEmpty {
            return self.lockQueue.sync {
                return self.items.remove(at: 0)
            }
        }
        return nil
    }

    func release(_ item: T) {
        self.lockQueue.sync {
            self.items.append(item)
            self.semaphore.signal()
        }
    }
}

