//
//  UIKitPreviewSupport.swift
//  Flo
//
//  Created by 정재성 on 2020/02/01.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

#if canImport(SwiftUI) && DEBUG

import UIKit
import SwiftUI

// MARK: - UIViewPreview

struct UIViewPreview<View: UIView>: UIViewRepresentable {
  let view: View

  init(_ builder: @escaping () -> View) {
    view = builder()
  }

  func makeUIView(context: Context) -> View {
    return view
  }

  func updateUIView(_ view: View, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}

// MARK: - UIViewControllerPreview

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
  let viewController: ViewController

  init(_ builder: @escaping () -> ViewController) {
    viewController = builder()
  }

  func makeUIViewController(context: Context) -> ViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: ViewController, context: Context) {
  }
}

#endif
