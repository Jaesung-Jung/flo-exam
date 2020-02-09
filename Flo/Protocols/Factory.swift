//
//  Factory.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

struct Factory<A, R> {
  let create: (A) -> R
}
