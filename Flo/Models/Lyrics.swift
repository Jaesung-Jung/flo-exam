//
//  Lyrics.swift
//  Flo
//
//  Created by 정재성 on 2020/02/05.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Foundation

struct Lyrics {
  private let hash: Int
  let contents: [Content]

  init(string: String) {
    self.hash = string.hash

    guard let regex = try? NSRegularExpression(pattern: "\\[([0-9]+):([0-9]+):([0-9]+)\\]", options: []) else {
      self.contents = string.components(separatedBy: "\n").map { Content(timeInterval: 0, text: $0) }
      return
    }
    self.contents = string.components(separatedBy: "\n")
      .map { line in
        if let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
          let minute = Int(line[match.range(at: 1).lowerBound..<match.range(at: 1).upperBound]) ?? 0
          let second = Int(line[match.range(at: 2).lowerBound..<match.range(at: 2).upperBound]) ?? 0
          let millisecond = Int(line[match.range(at: 3).lowerBound..<match.range(at: 3).upperBound]) ?? 0
          let text = line[match.range.upperBound...]
          return Content(
            timeInterval: TimeInterval(minute * 60 + second) + TimeInterval(millisecond) / 1000,
            text: String(text)
          )
        } else {
          return Content(timeInterval: 0, text: line)
        }
      }
  }
}

extension Lyrics {
  struct Content: Hashable {
    let timeInterval: TimeInterval
    let text: String
  }
}

extension Lyrics: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(hash)
  }
}
