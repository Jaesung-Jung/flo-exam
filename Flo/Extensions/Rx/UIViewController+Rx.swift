//
//  UIViewController+Rx.swift
//  Flo
//
//  Created by 정재성 on 2020/02/01.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

#if canImport(RxSwift) && canImport(RxCocoa)

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
  var didLoad: ControlEvent<Void> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
    )
  }

  var willAppear: ControlEvent<Bool> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewWillAppear(_:))).map { $0.first as? Bool ?? false }
    )
  }

  var didAppear: ControlEvent<Bool> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewDidAppear(_:))).map { $0.first as? Bool ?? false }
    )
  }

  var viewWillDisappear: ControlEvent<Bool> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
    )
  }

  var viewDidDisappear: ControlEvent<Bool> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
    )
  }

  var viewWillLayoutSubviews: ControlEvent<Void> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
    )
  }

  var viewDidLayoutSubviews: ControlEvent<Void> {
    return ControlEvent(
      events: methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
    )
  }
}

#endif
