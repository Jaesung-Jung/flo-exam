//
//  AssociatedObjectStorable.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import ObjectiveC

protocol AssociatedObjectStorable: class {
}

extension AssociatedObjectStorable {
  func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(self, key) as? T
  }

  func associatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T, policy: AssociationPolicy) -> T {
    if let object: T = associatedObject(forKey: key) {
      return object
    }
    let object = `default`()
    setAssociatedObject(object, forKey: key, policy: policy)
    return object
  }

  func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer, policy: AssociationPolicy) {
    objc_setAssociatedObject(self, key, object, policy.objcAssociationPolicy)
  }

  func removeAssociatedObjects() {
    objc_removeAssociatedObjects(self)
  }
}

enum AssociationPolicy: UInt {
  case assign = 0
  case copy = 771
  case copyNonatomic = 3
  case retain = 769
  case retainNonatomic = 1

  fileprivate var objcAssociationPolicy: objc_AssociationPolicy {
    return objc_AssociationPolicy(rawValue: rawValue)! // swiftlint:disable:this force_unwrapping
  }
}

extension NSObject: AssociatedObjectStorable {
}
