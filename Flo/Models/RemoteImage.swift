//
//  RemoteImage.swift
//  Flo
//
//  Created by 정재성 on 2020/02/03.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Foundation

import RxSwift

struct RemoteImage {
  let url: URL?

  func image() -> Single<UIImage?> {
    guard let url = url else {
      return .just(nil)
    }
    return URLSession.shared.rx
      .data(request: URLRequest(url: url))
      .map { UIImage(data: $0) }
      .catchErrorJustReturn(nil)
      .asSingle()
  }
}

extension RemoteImage: Hashable {
}
