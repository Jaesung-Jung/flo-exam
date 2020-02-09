//
//  ObservableType+Rx.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

#if canImport(RxSwift)

import RxSwift

extension ObservableType where Element == Data {
  func decode<T: Decodable>(to type: T.Type, decoder: DecoderProtocol) -> Observable<T> {
    return map {
      return try decoder.decode(type, from: $0)
    }
  }
}

extension ObservableType {
  func unwrap<T>() -> Observable<T> where Element == T? {
    return flatMap { Observable.from(optional: $0) }
  }
}

#endif
