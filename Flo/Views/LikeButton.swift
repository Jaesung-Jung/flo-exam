//
//  LikeButton.swift
//  Flo
//
//  Created by 정재성 on 2020/02/01.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

final class LikeButton: UIControl {
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = #imageLiteral(resourceName: "unliked")
  }

  var isLiked: Bool = false {
    didSet {
      imageView.image = isLiked ? #imageLiteral(resourceName: "liked") : #imageLiteral(resourceName: "unliked")
    }
  }

  var contentInsets: UIEdgeInsets = .zero {
    didSet {
      invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 40, height: 40)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    _setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    _setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    imageView.frame = bounds.inset(by: contentInsets)
  }
}

extension LikeButton {
  private func _setup() {
    backgroundColor = .clear
    addSubview(imageView)
    addTarget(self, action: #selector(_touchUpInsideControl), for: .touchUpInside)
  }

  @objc private func _touchUpInsideControl() {
    isLiked.toggle()
  }
}

// MARK: - LikeButton+ReactiveExtension

#if canImport(RxSwift) && canImport(RxCocoa)

import RxSwift
import RxCocoa

extension Reactive where Base: LikeButton {
}

#endif

// MARK: - LikeButtonPreview

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct LikeButtonPreview: PreviewProvider {
  static var previews: some View {
    Group {
      UIViewPreview {
        LikeButton()
      }
      .previewDisplayName("Unliked")
      .previewLayout(.sizeThatFits)

      UIViewPreview {
        LikeButton().then {
          $0.isLiked = true
        }
      }
      .previewDisplayName("Liked")
      .previewLayout(.sizeThatFits)

      UIViewPreview {
        LikeButton().then {
          $0.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
      }
      .previewDisplayName("With content insets")
      .previewLayout(.sizeThatFits)
    }
  }
}

#endif
