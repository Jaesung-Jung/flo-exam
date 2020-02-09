//
//  MusicSpec.swift
//  FloTests
//
//  Created by 정재성 on 2020/02/01.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Quick
import Nimble
import Stubber
import RxSwift
import RxBlocking

@testable import Flo

// swiftlint:disable force_unwrapping
class MusicSpec: QuickSpec {
  override func spec() {
    let musicRepository = MusicRepositoryStub()
    Stubber.register(musicRepository.fetchMusic) {
      let json =
        """
        {
          "singer": "챔버오케스트라",
          "album": "캐롤 모음",
          "title": "We Wish You A Merry Christmas",
          "duration": 198,
          "image": "cover.jpg",
          "file": "music.mp3",
          "lyrics": "[00:16:200]we wish you a merry christmas"
        }
        """.data(using: .utf8)!
      return Observable.just(json)
        .decode(to: Music.self, decoder: JSONDecoder())
        .asSingle()
    }

    describe("a Music") {
      context("when decoded") {
        it("is values equals to json string") {
          let music = try? musicRepository.fetchMusic().toBlocking().single()
          expect(music?.singer) == "챔버오케스트라"
          expect(music?.album) == "캐롤 모음"
          expect(music?.title) == "We Wish You A Merry Christmas"
          expect(music?.duration) == 198
          expect(music?.image.url?.absoluteString) == "cover.jpg"
          expect(music?.file.absoluteString) == "music.mp3"
          expect(music?.lyrics.contents.count) == 1
        }
      }
    }
  }
}
// swiftlint:enable force_unwrapping
