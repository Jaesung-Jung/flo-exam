//
//  LyricsSpec.swift
//  FloTests
//
//  Created by 정재성 on 2020/02/05.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Quick
import Nimble
@testable import Flo

class LyricsSpec: QuickSpec {
  override func spec() {
    describe("a Lyrics") {
      context("when initialized") {
        it("is parsed") {
          let lyrics = Lyrics(string: "[00:16:200]we wish you a merry christmas\n[01:25:300]So bring some out here\n[02:16:500]good tidings for christmas")
          expect(lyrics.contents.count) == 3
          expect(lyrics.contents[0].timeInterval) == 16.2
          expect(lyrics.contents[0].text) == "we wish you a merry christmas"
          expect(lyrics.contents[1].timeInterval) == 85.3
          expect(lyrics.contents[1].text) == "So bring some out here"
          expect(lyrics.contents[2].timeInterval) == 136.5
          expect(lyrics.contents[2].text) == "good tidings for christmas"
        }

        it("is parsed without time") {
          let lyrics = Lyrics(string: "we wish you a merry christmas\nSo bring some out here\ngood tidings for christmas")
          expect(lyrics.contents.count) == 3
          expect(lyrics.contents[0].timeInterval) == 0
          expect(lyrics.contents[0].text) == "we wish you a merry christmas"
          expect(lyrics.contents[1].timeInterval) == 0
          expect(lyrics.contents[1].text) == "So bring some out here"
          expect(lyrics.contents[2].timeInterval) == 0
          expect(lyrics.contents[2].text) == "good tidings for christmas"
        }

        it("is parsed wrong time format") {
          let lyrics = Lyrics(string: "[00:00.500]we wish you a merry christmas\n[00:05.200]So bring some out here\n[00:10.300]good tidings for christmas")
          expect(lyrics.contents.count) == 3
          expect(lyrics.contents[0].timeInterval) == 0
          expect(lyrics.contents[0].text) == "[00:00.500]we wish you a merry christmas"
          expect(lyrics.contents[1].timeInterval) == 0
          expect(lyrics.contents[1].text) == "[00:05.200]So bring some out here"
          expect(lyrics.contents[2].timeInterval) == 0
          expect(lyrics.contents[2].text) == "[00:10.300]good tidings for christmas"
        }
      }
    }
  }
}
