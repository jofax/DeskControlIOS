//
//  SPCommanPool.swift
//  PulseEcho
//
//  Created by Joseph on 2020-12-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

class CommandPool<T> {

    private let lockQueue = DispatchQueue(label: "smartpods.pool.lock.queue")
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

/*let pool = CommandPool<String>(["a", "b", "c"])

let a = pool.acquire()
print("\(a ?? "n/a") acquired")
let b = pool.acquire()
print("\(b ?? "n/a") acquired")
let c = pool.acquire()
print("\(c ?? "n/a") acquired")

DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .seconds(2)) {
    if let item = b {
        pool.release(item)
    }
}

print("No more resource in the pool, blocking thread until...")
let x = pool.acquire()
print("\(x ?? "n/a") acquired again")*/

