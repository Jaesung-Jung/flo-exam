//
//  TimeProgress.swift
//  Flo
//
//  Created by 정재성 on 2020/02/08.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

struct TimeProgress {
  let current: Double
  let total: Double

  var progress: Double {
    return min(max(0, current / total), 1)
  }

  var isFinished: Bool {
    return current >= total
  }
}
