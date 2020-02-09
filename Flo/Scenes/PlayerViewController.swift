//
//  PlayerViewController.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import ReactorKit
import Cartography

final class PlayerViewController: UIViewController, ReactorKit.View, HasDisposeBag, LayoutGuideSupporting {
  private var portraitConstraints = ConstraintSet()
  private var landscapeConstraints = ConstraintSet()

  fileprivate let coverImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 20
    $0.clipsToBounds = true
  }

  fileprivate let titleLabel = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = .black
    $0.numberOfLines = 2
    $0.font = .systemFont(ofSize: 27, weight: .heavy)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  fileprivate let singerLabel = UILabel().then {
    $0.textColor = .darkGray
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 15)
  }

  fileprivate let albumLabel = UILabel().then {
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 15)
    $0.textColor = .lightGray
  }

  fileprivate let lyricsView = LyricsView()

  fileprivate let likeButton = LikeButton().then {
    $0.contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  fileprivate let seekSlider = SeekSlider().then {
    $0.tintColor = .darkGray
  }

  fileprivate let playButton = UIButton(type: .system).then {
    $0.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    $0.tintColor = .darkGray
    $0.imageView?.contentMode = .scaleAspectFit
  }

  fileprivate let pauseButton = UIButton(type: .system).then {
    $0.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    $0.tintColor = .darkGray
    $0.imageView?.contentMode = .scaleAspectFit
  }

  fileprivate let previousButton = UIButton(type: .system).then {
    $0.setImage(#imageLiteral(resourceName: "next"), for: .normal)
    $0.tintColor = .darkGray
    $0.imageView?.contentMode = .scaleAspectFit
    $0.transform = $0.transform.rotated(by: .pi)
  }

  fileprivate let nextButton = UIButton(type: .system).then {
    $0.setImage(#imageLiteral(resourceName: "next"), for: .normal)
    $0.tintColor = .darkGray
    $0.imageView?.contentMode = .scaleAspectFit
  }

  var lyricsViewFactory: Factory<Lyrics, UIViewController>?

  override func loadView() {
    super.loadView()
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    _installConstraints()
  }

  func bind(reactor: PlayerViewReactor) {
    Observable.just(Reactor.Action.fetchMusic)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // Title
    reactor.state.map { $0.music?.title }
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)

    // Singer
    reactor.state.map { $0.music?.singer }
      .bind(to: singerLabel.rx.text)
      .disposed(by: disposeBag)

    // Album
    reactor.state.map { $0.music?.album }
      .bind(to: albumLabel.rx.text)
      .disposed(by: disposeBag)

    // Cover Image
    reactor.state.map { $0.music }
      .distinctUntilChanged()
      .map { $0?.image }
      .flatMap { remoteImage -> Observable<UIImage> in
        guard let remoteImage = remoteImage?.image().asObservable() else {
          return .just(#imageLiteral(resourceName: "cover-placeholder")) // cover image가 없으면 placeholder
        }
        return .concat(.just(#imageLiteral(resourceName: "cover-placeholder")), remoteImage.map { $0 ?? #imageLiteral(resourceName: "cover-placeholder") }) // placeholder를 표시 후 cover image fetch
      }
      .bind(to: coverImageView.rx.image)
      .disposed(by: disposeBag)

    // Lyrics
    reactor.state.map { $0.music?.lyrics }
      .distinctUntilChanged()
      .bind(to: lyricsView.rx.lyrics)
      .disposed(by: disposeBag)

    // Buffer Progress
    reactor.state.map { $0.bufferProgress }
      .unwrap()
      .map { Float($0.progress) }
      .bind(to: seekSlider.rx.progress)
      .disposed(by: disposeBag)

    // Playback Progress
    reactor.state.map { $0.playbackProgress }
      .unwrap()
      .map { Float($0.progress) }
      .bind(to: seekSlider.rx.sliderValue)
      .disposed(by: disposeBag)

    reactor.state.map { $0.playbackProgress }
      .unwrap()
      .map { $0.current }
      .bind(to: lyricsView.rx.playbackTime)
      .disposed(by: disposeBag)

    // Play Button
    reactor.state.map { $0.playerState }
      .map { $0 == .playing }
      .bind(to: playButton.rx.isHidden)
      .disposed(by: disposeBag)

    // Pause Button
    reactor.state.map { $0.playerState }
      .map { $0 != .playing }
      .bind(to: pauseButton.rx.isHidden)
      .disposed(by: disposeBag)

    // Lyrics View Delegate Event
    lyricsView.rx.didSelectText
      .map { _ in }
      .subscribe(onNext: { [weak self, reactor] in
        guard let lyrics = reactor.currentState.music?.lyrics, let lyricsView = self?.lyricsViewFactory?.create(lyrics) else {
          return
        }
        self?.present(lyricsView, animated: true)
      })
      .disposed(by: disposeBag)

    // Play
    playButton.rx.tap
      .map { Reactor.Action.play }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // Pause
    pauseButton.rx.tap
      .map { Reactor.Action.pause }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // Begin Seeking
    seekSlider.rx.beginEditing
      .map { Reactor.Action.beginSeeking }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // End Seeking
    seekSlider.rx.endEditing
      .map { Reactor.Action.endSeeking }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // Seek
    seekSlider.rx.sliderValue
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .map { Reactor.Action.seek($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    _layout(traitCollection: traitCollection)
  }
}

extension PlayerViewController {
  private func _layout(traitCollection: UITraitCollection) {
    switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      landscapeConstraints.deactive()
      portraitConstraints.active()
    case (_, .compact):
      portraitConstraints.deactive()
      landscapeConstraints.active()
    case (.regular, .regular):
      portraitConstraints.deactive()
      landscapeConstraints.active()
    default:
      break
    }
  }

  private func _installConstraints() {
    view.addSubview(coverImageView)
    view.addSubview(titleLabel)
    view.addSubview(singerLabel)
    view.addSubview(albumLabel)
    view.addSubview(lyricsView)
    view.addSubview(likeButton)
    view.addSubview(seekSlider)
    view.addSubview(previousButton)
    view.addSubview(nextButton)
    view.addSubview(playButton)
    view.addSubview(pauseButton)

    _installConstraintsForPortrait()
    _installConstraintsForLandscape()

    _layout(traitCollection: traitCollection)
  }

  private func _installConstraintsForPortrait() {
    let layoutGuide = self.layoutGuide(insets: UIEdgeInsets(top: 30, left: 50, bottom: 20, right: 50))
    constrain(
      coverImageView,
      titleLabel,
      singerLabel,
      albumLabel,
      lyricsView,
      likeButton
    ) { cover, title, singer, album, lyrics, like in
      title.top == layoutGuide.top
      title.left == layoutGuide.left
      title.right == layoutGuide.right

      singer.top == title.bottom + 8
      singer.left == layoutGuide.left
      singer.right == layoutGuide.right

      album.top == singer.bottom + 2
      album.left == layoutGuide.left
      album.right == layoutGuide.right

      cover.top == album.bottom + 20
      cover.left == layoutGuide.left
      cover.right == layoutGuide.right
      cover.width == cover.height

      lyrics.top == cover.bottom + 20
      lyrics.left == layoutGuide.left
      lyrics.right == layoutGuide.right
      lyrics.height == 70

      like.top == lyrics.bottom + 10
      like.centerX == lyrics.centerX
    }
    .store(in: portraitConstraints)

    constrain(
      playButton,
      pauseButton,
      previousButton,
      nextButton,
      seekSlider
    ) { play, pause, prev, next, seek in
      play.bottom == layoutGuide.bottom - 10
      play.centerX == play.superview!.centerX // swiftlint:disable:this force_unwrapping
      play.width == 50
      play.height == play.width

      pause.center == play.center
      pause.width == 50
      pause.height == pause.width

      prev.right == play.left - 40
      prev.centerY == play.centerY
      prev.width == 35
      prev.height == prev.width

      next.left == play.right + 40
      next.centerY == play.centerY
      next.width == 35
      next.height == next.width

      seek.left == layoutGuide.left
      seek.right == layoutGuide.right
      seek.bottom == play.top - 40
    }.store(in: portraitConstraints)

    portraitConstraints.deactive()
  }

  private func _installConstraintsForLandscape() {
    let layoutGuide = self.layoutGuide(insets: UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20))
    coverImageView.backgroundColor = .systemGray
    constrain(
      coverImageView,
      seekSlider,
      titleLabel,
      singerLabel,
      albumLabel,
      lyricsView,
      likeButton
    ) { cover, seek, title, singer, album, lyrics, like in
      cover.top == layoutGuide.top
      cover.left == layoutGuide.left
      cover.height == cover.width

      seek.top == cover.bottom + 50
      seek.bottom == layoutGuide.bottom - 10
      seek.left == cover.left
      seek.right == cover.right

      title.top == layoutGuide.top
      title.left == cover.right + 50

      like.left == title.right + 12
      like.right <= layoutGuide.right
      like.centerY == title.centerY

      singer.top == title.bottom + 8
      singer.left == lyrics.left
      singer.right == lyrics.right

      album.top == singer.bottom + 2
      album.left == lyrics.left
      album.right == lyrics.right

      lyrics.top == album.bottom + 20
      lyrics.bottom == cover.bottom
      lyrics.left == title.left
      lyrics.right == layoutGuide.right
    }
    .store(in: landscapeConstraints)

    constrain(
      seekSlider,
      lyricsView,
      playButton,
      pauseButton,
      previousButton,
      nextButton
    ) { seek, lyrics, play, pause, prev, next in
      play.centerX == lyrics.centerX
      play.centerY == seek.centerY
      play.width == 50
      play.height == play.width

      pause.center == play.center
      pause.width == 50
      pause.height == pause.width

      prev.right == play.left - 80
      prev.centerY == play.centerY
      prev.width == 35
      prev.height == prev.width

      next.left == play.right + 80
      next.centerY == play.centerY
      next.width == 35
      next.height == next.width
    }
    .store(in: landscapeConstraints)

    landscapeConstraints.deactive()
  }
}

// MARK: - PlayerViewControllerPreview

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct PlayerViewPreview: PreviewProvider {
  static var previews: some SwiftUI.View {
    UIViewControllerPreview {
      PlayerViewController().then {
        $0.coverImageView.image = #imageLiteral(resourceName: "cover-placeholder")
        $0.singerLabel.text = "SINGER"
        $0.titleLabel.text = "TITLE"
        $0.albumLabel.text = "ALBUM"
        $0.lyricsView.lyrics = Lyrics(string: "Lyrics 1\nLyrics 2")
      }
    }
  }
}

#endif
