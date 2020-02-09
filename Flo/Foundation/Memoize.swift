//
//  Memoize.swift
//  Flo
//
//  Created by 정재성 on 2020/02/01.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

func memoize<T: Hashable, U> (_ f: @escaping (T) -> U) -> (T) -> U {
  var memo: [T: U] = [:]
  return { x in
    if let r = memo[x] {
      return r
    }
    let r = f(x)
    memo[x] = r
    return r
  }
}
