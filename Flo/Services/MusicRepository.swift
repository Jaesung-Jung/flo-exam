//
//  MusicRepository.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import RxSwift

final class MusicRepository: MusicRepositoryProtocol {
  private let baseURL: URL
  private let session: URLSession
  private let decoder: DecoderProtocol

  init(baseURL: URL, session: URLSession, decoder: DecoderProtocol) {
    self.baseURL = baseURL
    self.session = session
    self.decoder = decoder
  }

  func fetchMusic() -> Single<Music> {
    let request = URLRequest(url: baseURL.appendingPathComponent("2020-flo").appendingPathComponent("song.json"))
    return session.rx
      .data(request: request)
      .decode(to: Music.self, decoder: JSONDecoder())
      .asSingle()
  }
}
