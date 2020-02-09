//
//  PlayerViewReactor.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import Foundation

import RxSwift
import ReactorKit

final class PlayerViewReactor: Reactor {
  private var playToEndTimeDisposeBag = DisposeBag()
  private var playbackDisposeBag = DisposeBag()

  private let repository: MusicRepositoryProtocol
  private let player: AudioPlayer

  let initialState = State()

  init(repository: MusicRepositoryProtocol, player: AudioPlayer) {
    self.repository = repository
    self.player = player
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchMusic:
      let fetchMusic = repository
        .fetchMusic()
        .do(onSuccess: { [weak self, player] music in
          player.prepare(item: .init(url: music.file))
          self?.subscribePlaybackProgress()
        })
        .asObservable()

      // URL fetch를 위한 Observable은 Loading state와 순차적으로 일어나야 하기에
      // concat으로 이벤트를 합성하고, Buffering Progress를 나타내기 위한 이벤트는
      // concat으로 합성 된 이벤트들과 별개로 동작하기 위해 merge로 이벤트를 합성
      return .merge(
        .concat(
          .just(.setLoading(true)),
          fetchMusic.map { .setMusic($0) },
          .just(.setLoading(false))
        ),
        fetchMusic
          .flatMap { [player] _ in player.rx.bufferProgress }
          .map { .setBufferProgress($0) }
      )

    case .play:
      guard currentState.playerState != .playing else {
        return .empty()
      }
      player.play()
      subscribeDidPlayToEndTime()
      return .just(.setPlayerState(.playing))
    case .pause:
      player.pause()
      return .just(.setPlayerState(.paused))

    case .beginSeeking:
      unsubscribePlaybackProgress()
      return .just(.setSeeking(true))
    case .endSeeking:
      subscribePlaybackProgress()
      return .just(.setSeeking(false))
    case .seek(let seek):
      let estimatedProgress = player.seek(fraction: seek)
      return .just(.setPlaybackProgress(estimatedProgress))

    case .updatePlaybackProgress(let progress):
      return .just(.setPlaybackProgress(progress))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setMusic(let music):
      return state.with { $0.music = music }
    case .setBufferProgress(let progress):
      return state.with { $0.bufferProgress = progress }
    case .setPlaybackProgress(let progress):
        return state.with { $0.playbackProgress = progress }

    case .setPlayerState(let playerState):
      return state.with { $0.playerState = playerState }

    case .setLoading(let isLoading):
      return state.with { $0.isLoading = isLoading }
    case .setSeeking(let isSeeking):
      return state.with { $0.isSeeking = isSeeking }
    }
  }
}

extension PlayerViewReactor {
  private func subscribePlaybackProgress() {
    playbackDisposeBag = DisposeBag()
    player.rx.playbackProgress
      .delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
      .map { Action.updatePlaybackProgress($0) }
      .bind(to: action)
      .disposed(by: playbackDisposeBag)
  }

  private func unsubscribePlaybackProgress() {
    playbackDisposeBag = DisposeBag()
  }

  private func subscribeDidPlayToEndTime() {
    playToEndTimeDisposeBag = DisposeBag()
    player.rx.didPlayToEndTime
      .do(onNext: { [player] in
        player.seek(time: 0)
        player.pause()
      })
      .map { Action.pause }
      .bind(to: action)
      .disposed(by: playToEndTimeDisposeBag)
  }
}

extension PlayerViewReactor {
  struct State: Then {
    var music: Music?
    var bufferProgress: TimeProgress?
    var playbackProgress: TimeProgress?

    var playerState: PlayerState = .paused

    var isLoading: Bool = false
    var isSeeking: Bool = false

    enum PlayerState {
      case playing
      case paused
    }
  }
}

extension PlayerViewReactor {
  enum Action {
    case fetchMusic
    case play
    case pause

    case beginSeeking
    case seek(Float)
    case endSeeking

    case updatePlaybackProgress(TimeProgress)
  }
}

extension PlayerViewReactor {
  enum Mutation {
    case setMusic(Music)
    case setBufferProgress(TimeProgress)
    case setPlaybackProgress(TimeProgress)

    case setPlayerState(State.PlayerState)

    case setLoading(Bool)
    case setSeeking(Bool)
  }
}
