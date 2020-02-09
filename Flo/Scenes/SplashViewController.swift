//
//  SplashViewController.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

import RxSwift
import Cartography

final class SplashViewController: UIViewController, HasDisposeBag {
  private let titleLabel = UILabel().then {
    $0.text = "지금, 당신의 음악"
    $0.font = .boldSystemFont(ofSize: 30)
  }

  private let logoImageView = UIImageView(image: #imageLiteral(resourceName: "flo"))

  var didFinishLoading: (() -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    view.addSubview(titleLabel)
    view.addSubview(logoImageView)
    constrain(titleLabel, logoImageView, view) { title, logo, view in
      title.bottom == logo.top - 16
      title.centerX == logo.centerX
      logo.center == view.center
    }

    rx.didAppear
      .delay(.seconds(2), scheduler: MainScheduler.instance)
      .take(1)
      .map { _ in }
      .subscribe(onNext: { [weak self] in
        self?.didFinishLoading?()
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - SplashViewControllerPreview

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct SplashViewControllerPreview: PreviewProvider {
  static var previews: some SwiftUI.View {
    UIViewControllerPreview {
      SplashViewController()
    }
  }
}

#endif
