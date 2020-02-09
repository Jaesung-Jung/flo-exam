//
//  MusicRepositoryProtocol.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import RxSwift

protocol MusicRepositoryProtocol {
  func fetchMusic() -> Single<Music>
}
