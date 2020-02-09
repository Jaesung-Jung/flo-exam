//
//  AudioPlayer.swift
//  Flo
//
//  Created by 정재성 on 2020/02/08.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import AVFoundation
import MediaPlayer

class AudioPlayer {
  private var player: AVPlayer?

  private var bufferingProgressHandler: ((TimeProgress) -> Void)?

  private var playerItemObservations: Set<NSKeyValueObservation>?

  private(set) var state: State = .stopped

  var currentTime: TimeProgress? {
    guard let currentItem = player?.currentItem else {
      return nil
    }
    return TimeProgress(current: CMTimeGetSeconds(currentItem.currentTime()), total: CMTimeGetSeconds(currentItem.duration))
  }

  func prepare(item: Item) {
    unregisterObservers()

    let playerItem = AVPlayerItem(url: item.url)
    playerItemObservations = registerObservers(for: playerItem)
    player = AVPlayer(playerItem: playerItem)
  }

  func play() {
    self.state = .playing
    if let status = player?.currentItem?.status, status == .readyToPlay {
      player?.play()
      try? AVAudioSession.sharedInstance().setCategory(.playback)
      try? AVAudioSession.sharedInstance().setActive(true)
    }
  }

  func pause() {
    self.state = .paused
    player?.pause()
  }

  @discardableResult
  func seek(fraction: Float) -> TimeProgress {
    guard let currentItem = player?.currentItem else {
      return TimeProgress(current: 0, total: 0)
    }
    let time = CMTime(value: CMTimeValue(Double(currentItem.duration.value) * Double(fraction)), timescale: currentItem.duration.timescale)
    currentItem.seek(to: time)
    return TimeProgress(current: CMTimeGetSeconds(time), total: CMTimeGetSeconds(currentItem.duration))
  }

  @discardableResult
  func seek(time: TimeInterval) -> TimeProgress {
    guard let currentItem = player?.currentItem else {
      return TimeProgress(current: 0, total: 0)
    }
    let seekTime = CMTime(value: Int64(time * 1000), timescale: 1000)
    currentItem.seek(to: seekTime)
    return TimeProgress(current: time, total: CMTimeGetSeconds(currentItem.duration))
  }

  func subscribeBufferingProgress(_ handler: @escaping (TimeProgress) -> Void) {
    self.bufferingProgressHandler = handler
  }

  func subscribePlaybackProgress(_ handler: @escaping (TimeProgress) -> Void) -> PlaybackProgressObservation? {
    guard let player = player else {
      return nil
    }
    let observer = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 5), queue: .main) { time in
      guard let currentItem = player.currentItem else {
        return
      }
      let progress = TimeProgress(current: CMTimeGetSeconds(time), total: CMTimeGetSeconds(currentItem.duration))
      handler(progress)
    }
    return PlaybackProgressObservation {
      player.removeTimeObserver(observer)
    }
  }
}

extension AudioPlayer {
  private func registerObservers(for item: AVPlayerItem) -> Set<NSKeyValueObservation> {
    var observations: Set<NSKeyValueObservation> = []
    observations.insert(item.observe(\.loadedTimeRanges, options: .new) { [weak self] item, _ in
      guard let `self` = self, let timeRange = item.loadedTimeRanges.first?.timeRangeValue else {
        return
      }
      let progress = TimeProgress(current: CMTimeGetSeconds(timeRange.duration), total: CMTimeGetSeconds(item.duration))
      self.bufferingProgressHandler?(progress)
    })
    observations.insert(item.observe(\.status, options: .new) { [weak self] item, _ in
      if item.status == .readyToPlay {
        if let state = self?.state, state == .playing {
          self?.play()
        }
      }
    })
    return observations
  }

  private func unregisterObservers() {
    playerItemObservations?.removeAll()
    playerItemObservations = nil
  }
}

extension AudioPlayer {
  class PlaybackProgressObservation {
    fileprivate var disposeHandler: (() -> Void)?

    init(_ disposeHandler: @escaping () -> Void) {
      self.disposeHandler = disposeHandler
    }

    deinit {
      dispose()
    }

    fileprivate func dispose() {
      disposeHandler?()
      disposeHandler = nil
    }
  }
}

#if canImport(RxSwift)

import RxSwift

extension AudioPlayer: ReactiveCompatible {
}

extension Reactive where Base: AudioPlayer {
  var bufferProgress: Observable<TimeProgress> {
    return Observable.create { [base] observer in
      base.subscribeBufferingProgress { progress in
        observer.on(.next(progress))
        if progress.isFinished {
          observer.on(.completed)
        }
      }
      return Disposables.create()
    }
  }

  var playbackProgress: Observable<TimeProgress> {
    return Observable.create { [base] observer in
      let observation = base.subscribePlaybackProgress { progress in
        observer.on(.next(progress))
      }
      return Disposables.create {
        observation?.dispose()
      }
    }
  }

  var didPlayToEndTime: Observable<Void> {
    return NotificationCenter.default.rx
      .notification(.AVPlayerItemDidPlayToEndTime).map { _ in }
  }
}

#endif
