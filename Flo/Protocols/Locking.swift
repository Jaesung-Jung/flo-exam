//
//  Locking.swift
//  Flo
//
//  Created by 정재성 on 2020/02/03.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Foundation

protocol Locking {
  associatedtype Lock: NSLocking

  var lock: Lock { get }
}

extension Locking {
  func locking(_ closure: () -> Any) {
    lock.lock()
    defer { lock.unlock() }
    _ = closure()
  }

  func locking(_ closure: () -> Void) {
    lock.lock()
    defer { lock.unlock() }
    closure()
  }
}
