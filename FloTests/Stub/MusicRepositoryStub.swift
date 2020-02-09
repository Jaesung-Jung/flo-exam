//
//  MusicRepositoryStub.swift
//  FloTests
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import RxSwift
import Stubber

@testable import Flo

final class MusicRepositoryStub: MusicRepositoryProtocol {
  func fetchMusic() -> Single<Music> {
    return Stubber.invoke(fetchMusic, args: ())
  }
}
