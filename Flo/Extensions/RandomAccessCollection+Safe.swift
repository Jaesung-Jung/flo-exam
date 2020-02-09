//
//  RandomAccessCollection+Safe.swift
//  Flo
//
//  Created by 정재성 on 2020/02/05.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

extension RandomAccessCollection {
  subscript(safe index: Index) -> Element? {
    guard indices.contains(index) else {
      return nil
    }
    return self[index]
  }
}
