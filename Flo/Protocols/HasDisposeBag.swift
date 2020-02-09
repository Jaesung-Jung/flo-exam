//
//  HasDisposeBag.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import RxSwift

private struct _HasDisposeBagKeys {
  static var disposeBag: UInt8 = 0
}

protocol HasDisposeBag: class {
}

extension HasDisposeBag where Self: AssociatedObjectStorable {
  var disposeBag: DisposeBag {
    get {
      return associatedObject(
        forKey: &_HasDisposeBagKeys.disposeBag,
        default: DisposeBag(),
        policy: .retainNonatomic
      )
    }
    set {
      setAssociatedObject(newValue, forKey: &_HasDisposeBagKeys.disposeBag, policy: .retainNonatomic)
    }
  }
}
