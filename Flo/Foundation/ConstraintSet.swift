//
//  ConstraintSet.swift
//  Flo
//
//  Created by 정재성 on 2020/02/03.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Cartography

final class ConstraintSet: Locking {
  private var _constraintGroups = Set<ConstraintGroup>()

  let lock = NSRecursiveLock()

  func insert(_ constraintGroup: ConstraintGroup) {
    locking { _constraintGroups.insert(constraintGroup) }
  }

  func active() {
    locking { _constraintGroups.forEach { $0.active = true } }
  }

  func deactive() {
    locking { _constraintGroups.forEach { $0.active = false } }
  }

  func uninstall() {
    locking {
      _constraintGroups.forEach(constrain(clear:))
      _constraintGroups.removeAll()
    }
  }

  deinit {
    uninstall()
  }
}

extension ConstraintGroup {
  func store(in bag: ConstraintSet) {
    bag.insert(self)
  }
}

extension ConstraintGroup: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(Unmanaged.passUnretained(self).toOpaque())
  }

  public static func == (lhs: ConstraintGroup, rhs: ConstraintGroup) -> Bool {
    return lhs === rhs
  }
}
