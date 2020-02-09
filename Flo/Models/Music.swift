//
//  Music.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Foundation

struct Music: Decodable {
  let singer: String
  let album: String
  let title: String
  let duration: Int
  let image: RemoteImage
  let file: URL
  let lyrics: Lyrics

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    singer = try container.decode(String.self, forKey: .singer)
    album = try container.decode(String.self, forKey: .album)
    title = try container.decode(String.self, forKey: .title)
    duration = try container.decode(Int.self, forKey: .duration)
    image = RemoteImage(url: try container.decode(URL.self, forKey: .image))
    file = try container.decode(URL.self, forKey: .file)
    lyrics = Lyrics(string: try container.decode(String.self, forKey: .lyrics))
  }

  enum CodingKeys: String, CodingKey {
    case singer
    case album
    case title
    case duration
    case image
    case file
    case lyrics
  }
}

extension Music: Hashable {
}
