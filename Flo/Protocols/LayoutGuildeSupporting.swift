//
//  LayoutGuildeSupporting.swift
//  Flo
//
//  Created by 정재성 on 2020/02/09.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

import Cartography

protocol LayoutGuideSupporting {
  func layoutGuide(
    insets: UIEdgeInsets
  ) -> (
    top: Expression<Cartography.Edge>,
    left: Expression<Cartography.Edge>,
    bottom: Expression<Cartography.Edge>,
    right: Expression<Cartography.Edge>
  )
}

extension LayoutGuideSupporting where Self: UIViewController {
  func layoutGuide(
    insets: UIEdgeInsets
  ) -> (
    top: Expression<Cartography.Edge>,
    left: Expression<Cartography.Edge>,
    bottom: Expression<Cartography.Edge>,
    right: Expression<Cartography.Edge>
  ) {
    if #available(iOS 11.0, *) {
      let safeAreaLayoutGuideProxy = view.safeAreaLayoutGuide.asProxy()
      return (
        top: safeAreaLayoutGuideProxy.top + insets.top,
        left: safeAreaLayoutGuideProxy.left + insets.left,
        bottom: safeAreaLayoutGuideProxy.bottom - insets.bottom,
        right: safeAreaLayoutGuideProxy.right - insets.right
      )
    } else {
      let viewLayoutProxy = view.asProxy()
      return (
        top: car_bottomLayoutGuide.asProxy().bottom + insets.top,
        left: viewLayoutProxy.left + insets.left,
        bottom: viewLayoutProxy.right - insets.bottom,
        right: car_bottomLayoutGuide.asProxy().top - insets.right
      )
    }
  }
}
