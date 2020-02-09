//
//  DecoderProtocol.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Foundation

protocol DecoderProtocol {
  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

extension JSONDecoder: DecoderProtocol {
}

extension PropertyListDecoder: DecoderProtocol {
}
