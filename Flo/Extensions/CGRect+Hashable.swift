//
//  CGRect+Hashable.swift
//  Flo
//
//  Created by 정재성 on 2020/02/03.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

extension CGRect: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(origin.x)
    hasher.combine(origin.y)
    hasher.combine(size.width)
    hasher.combine(size.height)
  }
}
