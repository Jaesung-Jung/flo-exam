//
//  LyricsViewReactor.swift
//  Flo
//
//  Created by 정재성 on 2020/02/09.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import RxSwift
import ReactorKit

final class LyricsViewReactor: Reactor {
  private let disposeBag = DisposeBag()
  private let player: AudioPlayer

  let initialState: State

  init(player: AudioPlayer, lyrics: Lyrics) {
    self.player = player
    self.initialState = State(lyrics: lyrics)
    self.player.rx.playbackProgress
      .map { Action.updatePlaybackProgress($0) }
      .bind(to: action)
      .disposed(by: disposeBag)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .toggleTracking:
      return .just(.setUseTracking(!currentState.useTracking))
    case .updatePlaybackProgress(let progress):
      return .just(.setPlaybackProgress(progress))
    case .seek(let seek):
      _ = player.seek(time: seek)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setUseTracking(let useTracking):
      return state.with { $0.useTracking = useTracking }
    case .setPlaybackProgress(let progress):
      return state.with { $0.playbackProgress = progress }
    }
  }
}

extension LyricsViewReactor {
  struct State: Then {
    let lyrics: Lyrics
    var useTracking: Bool = false
    var playbackProgress: TimeProgress?
  }
}

extension LyricsViewReactor {
  enum Action {
    case toggleTracking
    case seek(TimeInterval)
    case updatePlaybackProgress(TimeProgress)
  }
}

extension LyricsViewReactor {
  enum Mutation {
    case setUseTracking(Bool)
    case setPlaybackProgress(TimeProgress)
  }
}
