//
//  String+Extension.swift
//  Flo
//
//  Created by 정재성 on 2020/02/05.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

extension String {
  static let empty = ""
}

extension String {
  subscript<R>(range: R) -> Substring where R: RangeExpression, R.Bound == Int {
    let relativeRange = range.relative(to: 0..<count)
    return self [index(startIndex, offsetBy: relativeRange.lowerBound)..<index(startIndex, offsetBy: relativeRange.upperBound)]
  }
}
