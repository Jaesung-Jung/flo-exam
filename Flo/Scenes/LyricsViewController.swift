//
//  LyricsViewController.swift
//  Flo
//
//  Created by 정재성 on 2020/02/09.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import ReactorKit
import Cartography

final class LyricsViewController: UIViewController, ReactorKit.View, HasDisposeBag, LayoutGuideSupporting {
  fileprivate let closeButton = UIButton(type: .system).then {
    $0.setImage(#imageLiteral(resourceName: "close"), for: .normal)
    $0.tintColor = .darkGray
    $0.imageEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
  }

  fileprivate let trackingButton = UIButton(type: .custom).then {
    $0.setImage(#imageLiteral(resourceName: "tracking-off"), for: .normal)
    $0.setImage(#imageLiteral(resourceName: "tracking-on"), for: .selected)
    $0.imageEdgeInsets = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
  }

  fileprivate let lyricsView = LyricsView().then {
    $0.autoScrolling = false
    $0.textAlignment = .left
    $0.textInsets = UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 20)
  }

  override func loadView() {
    super.loadView()
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    _installConstrains()
  }

  func bind(reactor: LyricsViewReactor) {
    reactor.state.map { $0.lyrics }
      .take(1)
      .bind(to: lyricsView.rx.lyrics)
      .disposed(by: disposeBag)

    reactor.state.map { $0.useTracking }
      .distinctUntilChanged()
      .bind(to: trackingButton.rx.isSelected)
      .disposed(by: disposeBag)

    reactor.state.map { $0.playbackProgress }
      .unwrap()
      .map { $0.current }
      .bind(to: lyricsView.rx.playbackTime)
      .disposed(by: disposeBag)

    // useTracking true 일 때는 해당 시간으로 seek
    lyricsView.rx.didSelectText
      .filter { [reactor] _ in reactor.currentState.useTracking }
      .map { Reactor.Action.seek($0.time) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // useTracking false 일 때는 화면을 닫음
    lyricsView.rx.didSelectText
      .filter { [reactor] _ in !reactor.currentState.useTracking }
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)

    trackingButton.rx.tap
      .map { Reactor.Action.toggleTracking }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
  }
}

extension LyricsViewController {
  private func _installConstrains() {
    // views
    let layoutGuide = self.layoutGuide(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    let stackView = UIStackView(arrangedSubviews: [closeButton, trackingButton]).then {
      $0.axis = .vertical
      $0.spacing = 10
      $0.alignment = .fill
      $0.distribution = .fillEqually
    }
    view.addSubview(stackView)
    constrain(stackView, closeButton, trackingButton) { stack, close, tracking in
      stack.top == layoutGuide.top + 30
      stack.right == layoutGuide.right

      close.width == 48
      close.height == close.width

      tracking.width == 48
      tracking.height == close.height
    }

    view.addSubview(lyricsView)
    constrain(view, lyricsView, stackView) { view, lyrics, stack in
      lyrics.top == view.top
      lyrics.bottom == view.bottom
      lyrics.left == layoutGuide.left
      lyrics.right == stack.left
    }
  }
}

// MARK: - LyricsViewControllerPreview

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct LyricsViewControllerPreview: PreviewProvider {
  static var previews: some SwiftUI.View {
    UIViewControllerPreview {
      LyricsViewController().then {
        $0.lyricsView.lyrics = Lyrics(string: "[00:16:200]we wish you a merry christmas\n[00:18:300]we wish you a merry christmas\n[00:21:100]we wish you a merry christmas\n[00:23:600]and a happy new year\n[00:26:300]we wish you a merry christmas\n[00:28:700]we wish you a merry christmas\n[00:31:400]we wish you a merry christmas\n[00:33:600]and a happy new year\n[00:36:500]good tidings we bring\n[00:38:900]to you and your kin\n[00:41:500]good tidings for christmas\n[00:44:200]and a happy new year\n[00:46:600]Oh, bring us some figgy pudding\n[00:49:300]Oh, bring us some figgy pudding\n[00:52:200]Oh, bring us some figgy pudding\n[00:54:500]And bring it right here\n[00:57:000]Good tidings we bring \n[00:59:700]to you and your kin\n[01:02:100]Good tidings for Christmas \n[01:04:800]and a happy new year\n[01:07:400]we wish you a merry christmas\n[01:10:000]we wish you a merry christmas\n[01:12:500]we wish you a merry christmas\n[01:15:000]and a happy new year\n[01:17:700]We won't go until we get some\n[01:20:200]We won't go until we get some\n[01:22:800]We won't go until we get some\n[01:25:300]So bring some out here\n[01:29:800]연주\n[02:11:900]Good tidings we bring \n[02:14:000]to you and your kin\n[02:16:500]good tidings for christmas\n[02:19:400]and a happy new year\n[02:22:000]we wish you a merry christmas\n[02:24:400]we wish you a merry christmas\n[02:27:000]we wish you a merry christmas\n[02:29:600]and a happy new year\n[02:32:200]Good tidings we bring \n[02:34:500]to you and your kin\n[02:37:200]Good tidings for Christmas \n[02:40:000]and a happy new year\n[02:42:400]Oh, bring us some figgy pudding\n[02:45:000]Oh, bring us some figgy pudding\n[02:47:600]Oh, bring us some figgy pudding\n[02:50:200]And bring it right here\n[02:52:600]we wish you a merry christmas\n[02:55:300]we wish you a merry christmas\n[02:57:900]we wish you a merry christmas\n[03:00:500]and a happy new year") // swiftlint:disable:this line_length
        $0.lyricsView.playbackTime = 17
      }
    }
  }
}

#endif
